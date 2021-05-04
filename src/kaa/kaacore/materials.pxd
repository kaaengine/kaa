from libcpp.string cimport string
from libcpp.vector cimport vector
from libc.stdint cimport uint8_t, uint32_t

from ..extra.optional cimport optional

from .images cimport CImage
from .shaders cimport CProgram
from .exceptions cimport raise_py_error
from .resources cimport CResourceReference
from .uniforms cimport CUniformSpecificationMap, CSamplerValue, CUniformValue


cdef extern from "kaacore/materials.h" namespace "kaacore" nogil:

    cdef cppclass CMaterial "kaacore::Material":
        @staticmethod
        CResourceReference[CMaterial] create(
            const CResourceReference[CProgram]& program,
            const CUniformSpecificationMap& uniforms
        ) except +raise_py_error
        CResourceReference[CMaterial] clone() except +raise_py_error
        CUniformSpecificationMap uniforms() except +raise_py_error
        void set_uniform_texture(
            const string& name, const CResourceReference[CImage]& image,
            const uint8_t stage, const uint32_t flags
        ) except +raise_py_error
        optional[CSamplerValue] get_uniform_texture(const string& name) \
            except +raise_py_error
        vector[T] get_uniform_value[T](const string& name) \
            except +raise_py_error
        void set_uniform_value[T](const string& name, CUniformValue[T]&& value) \
            except +raise_py_error
