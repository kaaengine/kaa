import os
import re
import zlib
import platform
import tempfile
import subprocess
import dataclasses
import pkg_resources
from pathlib import Path
from typing import List, Tuple, Set, Dict, Union

import parsy

import kaa


SHADERC_DIR = pkg_resources.resource_filename(__name__, 'shaderc')
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


class EnsurePathMeta(type):
    def __new__(mcls, name, bases, attrs):
        for name, value in attrs.items():
            if isinstance(value, Path):
                value.mkdir(parents=True, exist_ok=True)
        return super().__new__(mcls, name, bases, attrs)


class ShaderCompiler(metaclass=EnsurePathMeta):
    ATTRIBUTES = (
        Attribute('vec3', 'a_position', 'POSITION'),
        Attribute('vec4', 'a_color0', 'COLOR0'),
        Attribute('vec2', 'a_texcoord0', 'TEXCOORD0'),
        Attribute('vec2', 'a_texcoord1', 'TEXCOORD1')
    )
    SUPPORTED_TYPES: Set[str] = {'vertex', 'fragment'}
    SUPPORTED_PLATFORMS: Set[str] = {'linux', 'osx', 'windows'}
    CACHE_DIR: Path = Path(tempfile.gettempdir()) / f'kaa-{kaa.__version__}' \
        / 'cache' / 'shaders'

    def __init__(self, raise_on_compilation_error=True):
        self.raise_on_error = raise_on_compilation_error
        self.shaderc = os.path.join(SHADERC_DIR, 'shaderc')
        self.includes = [os.path.join(SHADERC_DIR, 'include')]

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

    def compile_for_platforms(
        self,
        platforms: List[str],
        source_path: Path,
        type_: str,
        output_dir: Path = None
    ) -> Tuple[List[Varying], Dict[str, str]]:

        diff = set(platforms).difference(self.SUPPORTED_PLATFORMS)
        if diff:
            raise RuntimeError(f'Unsupported platforms: {diff}.')

        if 'windows' in platforms and self.current_platform != 'windows':
            raise RuntimeError(
                'DirectX shaders can be only compiled on Windows.'
            )

        source_bytes = source_path.read_bytes()
        crc32 = zlib.crc32(source_bytes)
        try:
            varying_definition, parsed_source = self._parse_shader_source(
                type_, source_bytes.decode()
            )
        except parsy.ParseError as e:
            error_message = f'Encountered error while parsing {source_path} file.'
            raise ShaderCompilationError(error_message) from e

        varying_path = self.CACHE_DIR / f'varying-{crc32}.def.sc'
        if not varying_path.is_file():
            varying_path.write_text(self._render_varyingdef(varying_definition))

        parsed_source_path = self.CACHE_DIR / f'{source_path.stem}-{crc32}.sc'
        if not parsed_source_path.is_file():
            parsed_source_path.write_text(parsed_source)

        result = {}
        output_dir = output_dir or source_path.parent
        compilation_config = get_compilation_flags(platforms, type_)
        for platform_name, model, flags in compilation_config:
            output_path = output_dir / f'{source_path.stem}-{model}-{crc32}.bin'
            try:
                self.compile_model(
                    type_, model, flags['profile'], flags['target_platform'],
                    parsed_source_path, output_path, varying_path
                )
            except subprocess.CalledProcessError as e:
                error_message = (
                    '\nVarying.def.sc:\n'
                    '---\n'
                    f'{varying_path.read_text()}\n\n'
                    '\nParsed source:\n'
                    '---\n'
                    f'{parsed_source}\n\n'
                    f'{e.stdout.decode()}\n'
                    '---\n'
                )
                raise ShaderCompilationError(error_message) from e

            result[model] = output_path
        return result

    def compile_model(
        self,
        type_: str,
        model: str,
        profile: str,
        target_platform: str,
        source_path: Path,
        output_path: Path,
        varyingdef_path: Path
    ) -> None:
        self.compile(
            '-f', str(source_path), '-o', str(output_path),
            '--type', type_, '--varyingdef', str(varyingdef_path),
            '--platform', target_platform, '--profile', profile,
        )

    def _parse_shader_source(self, type_: str, source: str) -> Tuple[List[Varying], str]:
        if type_ == 'vertex':
            varying_definition, source = parse_shader('output', source)
            varying_names = ', '.join(
                attribute.identifier for attribute in self.ATTRIBUTES
            )
            header = f'$input {varying_names}\n'
            return varying_definition, header + source
        else:
            return parse_shader('input', source)

    def _render_varyingdef(self, varyings: List[Varying]) -> str:
        lines = [f'{varying};' for varying in varyings]
        lines.append('')
        lines.extend(f'{attribute};' for attribute in self.ATTRIBUTES)
        return '\n'.join(lines)


class AutoShaderCompiler(ShaderCompiler):
    BIN_DIR = ShaderCompiler.CACHE_DIR / 'bin'

    def auto_compile(
        self,
        source_path: Path,
        type_: str
    ) -> Tuple[List[Varying], Dict[str, str]]:
        return self.compile_for_platforms(
            [self.current_platform], source_path, type_, self.BIN_DIR
        )


def get_compilation_flags(
    platform_names: List[str],
    type_: str
) -> Tuple[str, str, dict]:
    seen_models = set()
    for platform_name in platform_names:
        for model in _choose_models_for_platform(platform_name):
            if model in seen_models:
                continue

            flags = COMPILATION_FLAGS[model, type_]
            yield platform_name, model, flags
            seen_models.add(model)


def _choose_models_for_platform(platform_name):
    if platform_name == 'linux':
        return ('glsl', 'spirv')
    elif platform_name == 'osx':
        return ('metal', 'glsl', 'spirv')
    elif platform_name == 'windows':
        return ('hlsl_dx9', 'hlsl_dx11', 'glsl', 'spirv')
