from libcpp cimport bool
from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.unordered_map cimport unordered_map
from libc.stdint cimport uint8_t, uint16_t, uint32_t

from ..extra.optional cimport optional

from .images cimport CImage
from .shaders cimport CProgram
from .exceptions cimport raise_py_error
from .resources cimport CResourceReference


cdef extern from "kaacore/materials.h" namespace "kaacore" nogil:

    cdef enum CUniformType "kaacore::UniformType":
        sampler "kaacore::UniformType::sampler"
        vec4 "kaacore::UniformType::vec4"
        mat3 "kaacore::UniformType::mat3"
        mat4 "kaacore::UniformType::mat4"

    cdef cppclass CUniformSpecification "kaacore::UniformSpecification":
        CUniformSpecification();
        CUniformSpecification(
            const CUniformType type, const uint16_t number_of_elements
        ) except +raise_py_error
        bool operator==(const CUniformSpecification& other)
        CUniformType type() except +raise_py_error
        uint16_t number_of_elements() except +raise_py_error

    cdef cppclass CSamplerValue "kaacore::SamplerValue":
        uint8_t stage
        uint32_t flags
        CResourceReference[CImage] texture

    cdef cppclass CUniformValue "kaacore::UniformValue"[T] :
        CUniformValue()
        CUniformValue(const T value)
        CUniformValue(const vector[T] values)
        CUniformValue(const CUniformValue& other)
        CUniformValue(CUniformValue&& other)
        CUniformValue& operator=(const CUniformValue& other)
        CUniformValue& operator=(CUniformValue&& other)

    ctypedef unordered_map[string, CUniformSpecification] CUniformSpecificationMap \
        "kaacore::UniformSpecificationMap"

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
