import os
import re
import zlib
import logging
import platform
import tempfile
import subprocess
import dataclasses
from pathlib import Path
from typing import List, Tuple, Set, Dict, Union, Generator

import parsy

import kaa


logger = logging.getLogger(__name__)

SHADERC_DIR = os.path.join(os.path.dirname(__file__), 'shaderc')
TYPES = ('float', 'vec2', 'vec3', 'vec4', 'mat2', 'mat3', 'mat4')
SEMANTICS = (
    'POSITION', 'NORMAL', 'TANGENT', 'BITANGENT', 'COLOR0', 'COLOR1',
    'COLOR2', 'COLOR3', 'INDICES', 'WEIGHT', 'TEXCOORD0', 'TEXCOORD1',
    'TEXCOORD2', 'TEXCOORD3', 'TEXCOORD4', 'TEXCOORD5', 'TEXCOORD6',
    'TEXCOORD7'
)
COMPILATION_FLAGS = {
    ('glsl', 'vertex'): {
        'target_platform': 'linux', 'profile': '120'
    },
    ('glsl', 'fragment'): {
        'target_platform': 'linux', 'profile': '120'
    },
    ('spirv', 'vertex'): {
        'target_platform': 'linux', 'profile': 'spirv'
    },
    ('spirv', 'fragment'): {
        'target_platform': 'linux', 'profile': 'spirv'
    },
    ('metal', 'vertex'): {
        'target_platform': 'osx', 'profile': 'metal'
    },
    ('metal', 'fragment'): {
        'target_platform': 'osx', 'profile': 'metal'
    },
    ('hlsl_dx9', 'vertex'): {
        'target_platform': 'windows', 'profile': 'vs_3_0'
    },
    ('hlsl_dx9', 'fragment'): {
        'target_platform': 'windows', 'profile': 'ps_3_0'
    },
    ('hlsl_dx11', 'vertex'): {
        'target_platform': 'windows', 'profile': 'vs_5_0'
    },
    ('hlsl_dx11', 'fragment'): {
        'target_platform': 'windows', 'profile': 'ps_5_0'
    }
}


@dataclasses.dataclass(frozen=True)
class Float:
    value: str

    def __str__(self):
        # normalize value
        # 1. -> 1.0
        # .1 -> 0.1
        return str(float(self.value))


@dataclasses.dataclass(frozen=True)
class TypeConstructor:
    type: str
    args: List[Float]

    def __str__(self):
        formatted_args = ', '.join(map(str, self.args))
        return f'{self.type}({formatted_args})'


@dataclasses.dataclass(frozen=True)
class Attribute:
    type: str
    identifier: str
    semantic: str

    def __str__(self):
        return f'{self.type} {self.identifier} : {self.semantic}'


@dataclasses.dataclass(frozen=True)
class Varying(Attribute):
    default_value: Union[TypeConstructor, Float] = None

    def __str__(self):
        definition = super().__str__()
        if self.default_value:
            definition = f'{definition} = {self.default_value}'
        return definition


C_COMMENT_PATTERN = re.compile(r'\/\/.*$|\/\*.*?\*\/', re.MULTILINE)

EQ = parsy.char_from('=').desc('=')
COMMA = parsy.char_from(',').desc(',')
COLON = parsy.char_from(':').desc(':')
SEMICOLON = parsy.char_from(';').desc(';')
L_BRACE = parsy.char_from('{').desc('{')
R_BRACE = parsy.char_from('}').desc('}')
L_PARENTHESES = parsy.char_from('(').desc('(')
R_PARENTHESES = parsy.char_from(')').desc(')')

TYPE = parsy.string_from(*TYPES)
WHITESPACE = parsy.whitespace.desc('whitespace')
OPTIONAL_WHITESPACE = WHITESPACE.optional()
SEMANTIC = parsy.string_from(*SEMANTICS)
IDENTIFIER_CHARS = parsy.letter | parsy.decimal_digit | parsy.string("_")
IDENTIFIER = (parsy.letter + IDENTIFIER_CHARS.many().concat()).desc('identifier')
FLOAT = parsy.regex(r'[+-]?(?:\d+\.?\d*|\.\d+)').desc('float').map(Float)
ARGS = FLOAT.sep_by(
    OPTIONAL_WHITESPACE >> parsy.string(',') << OPTIONAL_WHITESPACE, min=1
)
TYPE_CONSTRUCTOR = parsy.seq(
    TYPE << OPTIONAL_WHITESPACE << L_PARENTHESES,
    OPTIONAL_WHITESPACE >> ARGS << OPTIONAL_WHITESPACE << R_PARENTHESES
).combine(TypeConstructor)
DEFAULT_VALUE = FLOAT | TYPE_CONSTRUCTOR
VARYING = (
    parsy.seq(
        TYPE << WHITESPACE,
        IDENTIFIER << OPTIONAL_WHITESPACE,
        COLON >> OPTIONAL_WHITESPACE >> SEMANTIC << OPTIONAL_WHITESPACE,
        (EQ >> OPTIONAL_WHITESPACE >> DEFAULT_VALUE << OPTIONAL_WHITESPACE).optional()
    ) << SEMICOLON << OPTIONAL_WHITESPACE
).combine(Varying).many()
BODY = L_BRACE >> OPTIONAL_WHITESPACE >> VARYING << OPTIONAL_WHITESPACE << R_BRACE


class ShaderCompilationError(Exception):
    pass


class UnsupportedPlatform(RuntimeError):
    pass


def parse_shader(varying_type: str, source: str) -> Tuple[List[Varying], str]:
    sentinel = parsy.string(f'@{varying_type}')
    definition = OPTIONAL_WHITESPACE >> sentinel >> OPTIONAL_WHITESPACE >> BODY
    varying_definition, source = definition.parse_partial(_strip_comments(source))
    varying_definition = sorted(varying_definition, key=lambda v: str(v))
    varying_names = ', '.join(varying.identifier for varying in varying_definition)
    header = f'${varying_type} {varying_names}\n'
    return varying_definition, header + source


def _strip_comments(source: str) -> str:
    return re.sub(C_COMMENT_PATTERN, '', source)


def parse_shader_source(
    shader_type: str,
    source: str,
    default_attrs: Tuple[Attribute, ...]
) -> Tuple[List[Varying], str]:

    if shader_type == 'vertex':
        varying_definition, source = parse_shader('output', source)
        attributes = ', '.join(
            attribute.identifier for attribute in default_attrs
        )
        header = f'$input {attributes}\n'
        return varying_definition, header + source
    else:
        return parse_shader('input', source)


class EnsurePathMeta(type):
    def __new__(mcls, name, bases, attrs):
        for name, value in attrs.items():
            if isinstance(value, Path):
                value.mkdir(parents=True, exist_ok=True)
        return super().__new__(mcls, name, bases, attrs)


class ShaderCompiler(metaclass=EnsurePathMeta):
    DEFAULT_ATTRIBUTES = (
        Attribute('vec3', 'a_position', 'POSITION'),
        Attribute('vec4', 'a_color0', 'COLOR0'),
        Attribute('vec2', 'a_texcoord0', 'TEXCOORD0'),
        Attribute('vec2', 'a_texcoord1', 'TEXCOORD1')
    )
    SUPPORTED_TYPES: Set[str] = {'vertex', 'fragment'}
    SUPPORTED_PLATFORMS: Set[str] = {'linux', 'osx', 'windows'}
    TMP_DIR: Path = Path(tempfile.gettempdir()) \
        / f'kaa-{kaa.__version__}' / 'shaders'
    OUTPUT_FILENAME_TEMPLATE = '{stem}-{model}-{checksum}.bin'

    def __init__(
            self,
            raise_on_compilation_error: bool = True,
            shaderc_dir: str = SHADERC_DIR
        ) -> None:
        self.raise_on_error = raise_on_compilation_error
        self.shaderc = os.path.join(shaderc_dir, 'shaderc')
        self.includes = [os.path.join(shaderc_dir, 'include')]

    @property
    def current_platform(self):
        platform_name = platform.system().lower()
        if platform_name == 'darwin':
            return 'osx'
        return platform_name

    def compile(self, *args: str):
        cmd = [self.shaderc]
        for include_dir in self.includes:
            cmd.extend(('-i', include_dir))
        cmd.extend(args)

        kwargs = {'check': self.raise_on_error}
        if self.raise_on_error:
            kwargs['stdout'] = subprocess.PIPE
            kwargs['stderr'] = subprocess.PIPE

        return subprocess.run(cmd, **kwargs).returncode

    def compile_model(
        self,
        shader_type: str,
        profile: str,
        target_platform: str,
        source_path: Path,
        output_path: Path,
        varyingdef_path: Path
    ) -> None:
        logger.info(f'Compiling %s', output_path)
        try:
            self.compile(
                '-f', str(source_path), '-o', str(output_path),
                '--type', shader_type, '--varyingdef', str(varyingdef_path),
                '--platform', target_platform, '--profile', profile,
            )
        except subprocess.CalledProcessError as e:
            error_message = (
                '\nVarying.def.sc:\n'
                '---\n'
                f'{varyingdef_path.read_text()}\n\n'
                '\nParsed source:\n'
                '---\n'
                f'{source_path.read_text()}\n\n'
                f'{e.stdout.decode()}\n'
                '---\n'
            )
            raise ShaderCompilationError(error_message) from e

    def compile_for_platform(
        self,
        platform: Union[str, Set[str]],
        source_file: Path,
        shader_type: str,
        output_dir: Path = None
    ) -> Dict[str, str]:

        if isinstance(platform, str):
            platform = set((platform, ))

        diff = platform.difference(self.SUPPORTED_PLATFORMS)
        if diff:
            raise UnsupportedPlatform(f'Unsupported platform: {diff}.')

        if 'windows' in platform and self.current_platform != 'windows':
            raise UnsupportedPlatform(
                'DirectX shaders can be only compiled on Windows.'
            )

        checksum, varyings, parsed_source = self.parse_source(shader_type, source_file)
        # store intermediate bgfx format that is going to be used with shaderc
        parsed_source_path = self.TMP_DIR / f'{source_file.stem}-{checksum}.sc'
        parsed_source_path.write_text(parsed_source)
        varyingdef_path = self.TMP_DIR / f'varying-{checksum}.def.sc'
        varyingdef_path.write_text(self.render_varyingdef(varyings))

        result = {}
        config = {
            model: flags
            for p in platform
            for model, flags in get_compilation_flags(p, shader_type)
        }
        for model, flags in config.items():
            output_filename = self.OUTPUT_FILENAME_TEMPLATE.format(
                stem=source_file.stem, model=model, checksum=checksum
            )
            output_path = output_dir / output_filename
            self.compile_model(
                shader_type, flags['profile'], flags['target_platform'],
                parsed_source_path, output_path, varyingdef_path
            )
            result[model] = output_path
        return result

    def parse_source(
        self,
        shader_type: str,
        source_file: Path
    ) -> Tuple[int, List[Varying], str]:
        source_bytes = source_file.read_bytes()
        try:
            varyings, parsed_source = parse_shader_source(
                shader_type, source_bytes.decode(), self.DEFAULT_ATTRIBUTES
            )
        except parsy.ParseError as e:
            error_message = f'Encountered error while parsing {source_file} file.'
            raise ShaderCompilationError(error_message) from e

        return zlib.crc32(source_bytes), varyings, parsed_source

    def render_varyingdef(self,varyings: List[Varying]) -> str:
        lines = [f'{varying};' for varying in varyings]
        lines.append('')
        lines.extend(f'{attribute};' for attribute in self.DEFAULT_ATTRIBUTES)
        return '\n'.join(lines)


class AutoShaderCompiler(ShaderCompiler):
    BIN_DIR = ShaderCompiler.TMP_DIR / 'bin'

    def auto_compile(self, source_file: Path, shader_type: str) -> Dict[str, str]:
        precompiled_models = {}
        required_models = _choose_models_for_platform(self.current_platform)
        for model in required_models:
            expected_path = source_file.parent / f'{source_file.stem}-{model}.bin'
            if expected_path.is_file():
                logger.info(
                    'Precompiled shader variant found in source directory: %s',
                    expected_path
                )
                precompiled_models[model] = expected_path

        if precompiled_models:
            if len(precompiled_models) == len(required_models):
                logger.info("Loading precompiled shader variants.")
                return precompiled_models
    
            diff = set(required_models).difference(precompiled_models.keys())
            logger.info(
                'Not all shader variants required for %s platform are present. '
                'Missing variants: %s.', self.current_platform, ', '.join(diff)
            )
            logger.info("Falling back to on-the-fly compilation.")

        return self.compile_for_platform(
            self.current_platform, source_file, shader_type, self.BIN_DIR
        )


class CliShaderCompiler(ShaderCompiler):
    OUTPUT_FILENAME_TEMPLATE = '{stem}-{model}.bin'


def get_compilation_flags(
    platform: str,
    type_: str
) -> Generator[Tuple[str, dict], None, None]:
    for model in _choose_models_for_platform(platform):
        flags = COMPILATION_FLAGS[model, type_]
        yield model, flags


def _choose_models_for_platform(platform_name):
    if platform_name == 'linux':
        return ('glsl', 'spirv')
    elif platform_name == 'osx':
        return ('metal', 'glsl', 'spirv')
    elif platform_name == 'windows':
        return ('hlsl_dx9', 'hlsl_dx11', 'glsl', 'spirv')
