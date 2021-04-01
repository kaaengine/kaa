from libcpp.string cimport string
from libcpp.unordered_map cimport unordered_map

from .exceptions cimport raise_py_error
from .resources cimport CResourceReference


cdef extern from "kaacore/shaders.h" namespace "kaacore" nogil:

    cdef enum CShaderType "kaacore::ShaderType":
        vertex "kaacore::ShaderType::vertex"
        fragment "kaacore::ShaderType::fragment"

    cdef enum CShaderModel "kaacore::ShaderModel":
        hlsl_dx9 "kaacore::ShaderModel::hlsl_dx9"
        hlsl_dx11 "kaacore::ShaderModel::hlsl_dx11"
        glsl "kaacore::ShaderModel::glsl"
        spriv "kaacore::ShaderModel::spriv"
        metal "kaacore::ShaderModel::metal"
        unknown "kaacore::ShaderModel::unknown"

    ctypedef unordered_map[CShaderModel, string] CShaderModelMap \
        "kaacore::ShaderModelMap"

    cdef cppclass CShader "kaacore::Shader":
        @staticmethod
        CResourceReference[CShader] load(
            const CShaderType type_,
            const CShaderModelMap& model_map
        ) except +raise_py_error
        CShaderType type()

    cdef cppclass CProgram "kaacore::Program":
        CResourceReference[CShader] vertex_shader
        CResourceReference[CShader] fragment_shader

        @staticmethod
        CResourceReference[CProgram] create(
            const CResourceReference[CShader] vertex,
            const CResourceReference[CShader] fragment
        ) except +raise_py_error
