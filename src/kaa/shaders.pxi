cimport cython
import logging
from pathlib import Path
from enum import IntEnum, Enum

from libc.stdint cimport uint32_t

import kaa
from .shader_tools import AutoShaderCompiler
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


class ShaderType(IntEnum):
    vertex = <uint32_t>(CShaderType.vertex)
    fragment = <uint32_t>(CShaderType.fragment)


@cython.freelist(SHADER_FREELIST_SIZE)
cdef class _ShaderBase:
    cdef:
        set varyings
        CResourceReference[CShader] c_shader

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
        CShaderType type_
    ) except *:
        cdef str shader_type = (
            'vertex' if type_ == CShaderType.vertex else 'fragment'
        )
        compiler = AutoShaderCompiler()
        result = compiler.auto_compile(Path(path), shader_type)

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
    def __init__(self, str path):
        super().__init__()
        self.c_shader = self._load(path, CShaderType.vertex)

    @staticmethod
    cdef VertexShader create(const CResourceReference[CShader]& c_shader):
        cdef VertexShader instance = VertexShader.__new__(VertexShader)
        instance.c_shader = c_shader
        return instance


@cython.final
cdef class FragmentShader(_ShaderBase):
    def __init__(self, str path):
        super().__init__()
        self.c_shader = self._load(path, CShaderType.fragment)

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
    elif model_name == 'spirv':
        return CShaderModel.spirv
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
        str fragment_shader_path not None
    ):
        return cls(
            VertexShader(vertex_shader_path),
            FragmentShader(fragment_shader_path)
        )
