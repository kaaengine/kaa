cimport cython
import os
import zlib
import logging
import tempfile
import platform
import subprocess
import pkg_resources
from typing import List, Dict
from enum import IntEnum, Enum
from pathlib import Path, PurePath

from libc.stdint cimport uint32_t

import kaa
from .kaacore.hashing cimport c_calculate_hash
from .kaacore.resources cimport CResourceReference
from .kaacore.shaders cimport (
    CShaderType, CShader, CProgram, CShaderModel, CShaderModelMap
)

DEF SHADER_FREELIST_SIZE = 8
DEF PROGRAM_FREELIST_SIZE = 8
ctypedef CShader* CShader_ptr
ctypedef CProgram* CProgram_ptr

logger = logging.getLogger(__name__)
_SHADERC_DIR = pkg_resources.resource_filename(__name__, 'shaderc')


class ShaderType(IntEnum):
    vertex = <uint32_t>(CShaderType.vertex)
    fragment = <uint32_t>(CShaderType.fragment)


class AttributeLocation(Enum):
    position = 'POSITION'
    normal = 'NORMAL'
    tangent = 'TANGENT'
    bitangent = 'BITANGENT'
    color0 = 'COLOR0'
    color1 = 'COLOR1'
    color2 = 'COLOR2'
    color3 = 'COLOR3'
    indices = 'INDICES'
    weight = 'WEIGHT'
    texcoord0 = 'TEXCOORD0'
    texcoord1 = 'TEXCOORD1'
    texcoord2 = 'TEXCOORD2'
    texcoord3 = 'TEXCOORD3'
    texcoord4 = 'TEXCOORD4'
    texcoord5 = 'TEXCOORD5'
    texcoord6 = 'TEXCOORD6'
    texcoord7 = 'TEXCOORD7'


class VaryingType(Enum):
    vec2 = 'vec2'
    vec3 = 'vec3'
    vec4 = 'vec4'


@cython.final
cdef class Varying:
    cdef:
        readonly str name
        readonly object type

    def __cinit__(self, str name, object type_ not None):
        if not isinstance(type_, VaryingType):
            raise TypeError('type_ must be instance of VaryingType.')

        self.name = name
        self.type = type_

    def __str__(self):
        return f'{self.type.value} {self.name}'


@cython.freelist(SHADER_FREELIST_SIZE)
cdef class _ShaderBase:
    cdef CResourceReference[CShader] c_shader

    def __eq__(self, _ShaderBase other):
        if other is None:
            return False

        return self.c_shader == other.c_shader

    def __hash__(self):
        return c_calculate_hash[CShader_ptr](self.c_shader.get())

    @property
    def type(self):
        return ShaderType(<uint32_t>(self.c_shader.get().type()))

    cdef CResourceReference[CShader] _load(
        self,
        str path,
        CShaderType type_,
        dict varyings
    ) except *:
        cdef str shader_type = (
            'vertex' if type_ == CShaderType.vertex else 'fragment'
        )
        compiler = _AutoShaderCompiler()
        result = compiler.auto_compile(Path(path), shader_type, varyings)

        cdef:
            str shader_model
            CShaderModel c_model
            CShaderModelMap c_model_map

        for shader_model, output_path in result.items():
            c_model = _translate_shader_model(shader_model)
            c_model_map[c_model] = str(output_path).encode()
        return CShader.load(type_, c_model_map)


@cython.final
cdef class VertexShader(_ShaderBase):
    def __init__(self, str path, dict output_layout not None):
        super().__init__()
        self.c_shader = self._load(path, CShaderType.vertex, output_layout)

    @staticmethod
    cdef VertexShader create(const CResourceReference[CShader]& c_shader):
        cdef VertexShader instance = VertexShader.__new__(VertexShader)
        instance.c_shader = c_shader
        return instance


@cython.final
cdef class FragmentShader(_ShaderBase):
    def __init__(self, str path, dict input_layout not None):
        super().__init__()
        self.c_shader = self._load(path, CShaderType.fragment, input_layout)

    @staticmethod
    cdef FragmentShader create(const CResourceReference[CShader]& c_shader):
        cdef FragmentShader instance = FragmentShader.__new__(FragmentShader)
        instance.c_shader = c_shader
        return instance


cdef CShaderModel _translate_shader_model(str model_name):
    if model_name == 'hlsl_dx9':
        return CShaderModel.hlsl_dx9
    elif model_name == 'hlsl_dx11':
        return CShaderModel.hlsl_dx11
    elif model_name == 'glsl':
        return CShaderModel.glsl
    elif model_name == 'spriv':
        return CShaderModel.spriv
    elif model_name == 'metal':
        return CShaderModel.metal
    return CShaderModel.unknown


@cython.final
@cython.freelist(PROGRAM_FREELIST_SIZE)
cdef class Program:
    cdef CResourceReference[CProgram] c_program

    def __init__(
        self,
        VertexShader vertex_shader not None,
        FragmentShader fragment_shader not None
    ):
        self.c_program = CProgram.create(
            vertex_shader.c_shader, fragment_shader.c_shader
        )

    def __eq__(self, Program other):
        if other is None:
            return False

        return self.c_program == other.c_program

    def __hash__(self):
        return c_calculate_hash[CProgram_ptr](self.c_program.get())

    @property
    def vertex_shader(self):
        return VertexShader.create(self.c_program.get().vertex_shader)

    @property
    def fragment_shader(self):
        return FragmentShader.create(self.c_program.get().fragment_shader)

    @staticmethod
    cdef Program create(CResourceReference[CProgram]& program):
        cdef Program instance = Program.__new__(Program)
        instance.c_program = program
        return instance

    @classmethod
    def from_files(
        cls,
        str vertex_shader_path not None,
        str fragment_shader_path not None,
        dict input_output_layout not None,
    ):
        return cls(
            VertexShader(vertex_shader_path, input_output_layout),
            FragmentShader(fragment_shader_path, input_output_layout)
        )


class ShaderCompilationError(Exception):
    pass


class ShaderCompiler:
    SUPPORTED_TYPES :set = {'vertex', 'fragment'}
    SUPPORTED_PLATFORMS: set = {'linux', 'osx', 'windows'}

    def __init__(self, bool raise_on_error=False):
        self.raise_on_error = raise_on_error
        self.shaderc = os.path.join(_SHADERC_DIR, 'shaderc')
        self.includes = [os.path.join(_SHADERC_DIR, 'include')]

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

        try:
            return subprocess.run(cmd, **kwargs).returncode
        except subprocess.CalledProcessError as e:
            raise ShaderCompilationError(f'\n{e.stdout.decode()}') from e

    def compile_for_platforms(
        self,
        platforms: List[str],
        source_path: Path,
        type_: str,
        varyingdef_path: Path,
        output_dir: Path = None
    ):
        diff = set(platforms).difference(self.SUPPORTED_PLATFORMS)
        if diff:
            raise RuntimeError(f'Unsupported platforms: {diff}.')

        if 'windows' in platforms and self.current_platform != 'windows':
            raise RuntimeError(
                'DirectX shaders can be only compiled on Windows.'
            )

        result = {}
        seen_models = set()
        output_dir = output_dir or source_path.parent
        for platform_name in platforms:
            for model in _choose_models_for_platform(platform_name):
                if model in seen_models:
                    continue

                result[model] = self.compile_model(
                    model, platform_name, source_path, output_dir,
                    type_, varyingdef_path
                )
                seen_models.add(model)
        return result

    def compile_model(
        self,
        model: str,
        platform_name: str,
        source_path: Path,
        output_dir: Path,
        type_: str,
        varyingdef_path: Path
    ):
        output_path = output_dir / f'{source_path.stem}-{model}.bin'
        profile = _choose_shader_profile(model, type_)
        self.compile(
            '-f', source_path, '-o', output_path,
            '--platform', platform_name, '--type', type_,
            '--profile', profile, '--varyingdef', varyingdef_path
        )
        return output_path


def _choose_models_for_platform(platform_name):
    if platform_name == 'linux':
        return ('glsl', 'spirv')
    elif platform_name == 'osx':
        return ('metal', 'glsl', 'spirv')
    elif platform_name == 'windows':
        return ('hlsl_dx9', 'hlsl_dx11', 'glsl', 'spirv')


def _choose_shader_profile(model: str, type_: str):
    if model == 'glsl':
        return '120'
    elif model == 'metal':
        return 'metal'
    elif model == 'hlsl_dx9':
        if type_ == 'vertex':
            return 'vs_3_0'
        return 'ps_3_0'
    elif model == 'hlsl_dx11':
        if type_ == 'vertex':
            return 'vs_5_0'
        return 'ps_5_0'
    elif model == 'spirv':
        return 'spirv'


class _AutoShaderCompiler(ShaderCompiler):
    BIN_DIR = Path(tempfile.gettempdir()) / f'kaa-{kaa.__version__}' \
        / 'shaders' / 'bin'

    def __init__(self, bin_dir: Path = None):
        super().__init__(raise_on_error=True)

        self.bin_dir = bin_dir or self.BIN_DIR
        self.bin_dir.mkdir(parents=True, exist_ok=True)

    def auto_compile(
        self,
        source_path: Path,
        type_: ShaderType,
        varyings: Dict[AttributeLocation, Varying]
    ):
        varyingdef_content = _render_varyingdef(varyings)
        crc32 = zlib.crc32(varyingdef_content.encode())
        varyingdef_path = self.bin_dir / f'varying-{crc32}.def.sc'
        if not varyingdef_path.is_file():
            varyingdef_path.write_text(varyingdef_content)
        platforms = [self.current_platform]
        return self.compile_for_platforms(
            platforms, source_path, type_, varyingdef_path, self.bin_dir
        )

    def compile_model(
        self,
        model: str,
        platform_name: str,
        source_path: Path,
        output_dir: Path,
        type_: str,
        varyingdef_path: Path
    ):
        crc32 = zlib.crc32(source_path.read_bytes())
        output_path = output_dir / f'{source_path.stem}-{model}-{crc32}.bin'
        if not output_path.is_file():
            profile = _choose_shader_profile(model, type_)
            self.compile(
                '-f', source_path, '-o', output_path,
                '--platform', platform_name, '--type', type_,
                '--profile', profile, '--varyingdef', varyingdef_path
            )
        return output_path


cdef _render_varyingdef(varyings: Dict[AttributeLocation, Varying]):
    lines = []
    for location, varying in varyings.items():
        lines.append(f'{varying} : {location.value};')

    if lines:
        lines.append('')

    lines.append('vec3 a_position : POSITION;')
    lines.append('vec4 a_color0 : COLOR0;')
    lines.append('vec2 a_texcoord0 : TEXCOORD0;')
    lines.append('vec2 a_texcoord1 : TEXCOORD1;')
    return '\n'.join(lines)
