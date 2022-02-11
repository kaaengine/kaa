cimport cython
from enum import IntEnum
from libcpp.pair cimport pair
from libcpp.string cimport string
from libcpp.vector cimport vector
from libc.stdint cimport uint16_t, uint32_t, UINT32_MAX
from libcpp.unordered_map cimport unordered_map

from cymove cimport cymove as cmove

from .extra.optional cimport optional
from .kaacore.materials cimport CMaterial
from .kaacore.hashing cimport c_calculate_hash
from .kaacore.vectors cimport CFVec4, CFMat3, CFMat4
from .kaacore.uniforms cimport (
    CUniformType, CUniformSpecification, CSamplerValue, CUniformValue,
    CUniformSpecificationMap
)


DEF UNIFORM_FREELIST_SIZE = 8
DEF MATERIAL_FREELIST_SIZE = 8
ctypedef CMaterial* CMaterial_ptr


class UniformType(IntEnum):
    sampler = <uint32_t>CUniformType.sampler
    vec4 = <uint32_t>CUniformType.vec4
    mat3 = <uint32_t>CUniformType.mat3
    mat4 = <uint32_t>CUniformType.mat4


@cython.final
@cython.freelist(UNIFORM_FREELIST_SIZE)
cdef class Uniform:
    cdef:
        CUniformSpecification c_specification

    def __init__(self, object type_ not None, uint16_t number_of_elements=1):
        super().__init__()
        self.c_specification = CUniformSpecification(
            <CUniformType>(<uint32_t>(type_.value)), number_of_elements
        )

    def __eq__(self, Uniform other):
        if other is None:
            return False

        return self.c_specification == other.c_specification

    @staticmethod
    cdef Uniform create(CUniformSpecification& c_specification):
        cdef Uniform instance =  Uniform.__new__(Uniform)
        instance.c_specification = c_specification
        return instance

    @property
    def type(self):
        return UniformType(<uint32_t>(self.c_specification.type()))

    @property
    def number_of_elements(self):
        return self.c_specification.number_of_elements()


@cython.freelist(MATERIAL_FREELIST_SIZE)
cdef class _ReadonlyMaterial:
    cdef CResourceReference[CMaterial] c_material

    def __init__(self, Program program, dict uniforms=None):
        super().__init__()

        cdef:
            str name
            Uniform uniform
            CUniformSpecificationMap c_uniforms

        uniforms = uniforms or {}
        c_uniforms.reserve(len(uniforms))
        for name, uniform in uniforms.items():
            c_uniforms[name.encode()] = uniform.c_specification

        self.c_material = CMaterial.create(program.c_program, c_uniforms)

    def __eq__(self, _ReadonlyMaterial other):
        if other is None:
            return False

        return self.c_material == other.c_material

    def __hash__(self):
        return c_calculate_hash[CMaterial_ptr](self.c_material.get())

    @property
    def uniforms(self):
        cdef:
            dict result = {}
            pair[string, CUniformSpecification] cursor

        for cursor in self.c_material.get().uniforms():
            result[cursor.first.c_str().decode()] = Uniform.create(
                cursor.second
            )

        return result

    def get_uniform_texture(self, str name not None):
        cdef optional[CSamplerValue] c_value = self.c_material.get() \
            .get_uniform_texture(name.encode())

        if c_value:
            return SamplerValue.create(c_value.value())

    def get_uniform_value(self, str name not None):
        cdef:
            CFVec4 vec4
            CFMat3 mat3
            CFMat4 mat4
            list result = []
            CUniformSpecification c_uniform = self.get_specification(name)

        if c_uniform.type() == CUniformType.vec4:
            for vec4 in self.c_material.get() \
                .get_uniform_value[CFVec4](name.encode()):
                result.append(
                    (vec4.x, vec4.y, vec4.z, vec4.w)
                )
        elif c_uniform.type() == CUniformType.mat3:
            for mat3 in self.c_material.get() \
                .get_uniform_value[CFMat3](name.encode()):
                result.append(
                    (
                        mat3[0].x, mat3[0].y, mat3[0].z,
                        mat3[1].x, mat3[1].y, mat3[1].z,
                        mat3[2].x, mat3[2].y, mat3[2].z
                    )
                )
        elif c_uniform.type() == CUniformType.mat4:
            for mat4 in self.c_material.get() \
                .get_uniform_value[CFMat4](name.encode()):
                result.append(
                    (
                        mat4[0].x, mat4[0].y, mat4[0].z, mat4[0].w,
                        mat4[1].x, mat4[1].y, mat4[1].z, mat4[1].w,
                        mat4[2].x, mat4[2].y, mat4[2].z, mat4[2].w,
                        mat4[3].x, mat4[3].y, mat4[3].z, mat4[3].w
                    )
                )

        if not result:
            return

        if c_uniform.number_of_elements() == 1 and len(result) == 1:
            return result[0]
        return tuple(result)

    cdef CUniformSpecification get_specification(self, str name) except *:
        cdef unordered_map[string, CUniformSpecification] uniforms
        uniforms = self.c_material.get().uniforms()
        if uniforms.find(name.encode()) == uniforms.end():
            raise KaacoreError(f'Unknown uniform: {name}.')

        return uniforms[name.encode()]


@cython.final
cdef class MaterialView(_ReadonlyMaterial):
    @staticmethod
    cdef MaterialView create(CResourceReference[CMaterial]& c_material):
        cdef MaterialView instance = MaterialView.__new__(MaterialView)
        instance.c_material = c_material
        return instance

    @property
    def source(self):
        return Material.create(self.c_material)


cdef class _Material(_ReadonlyMaterial):
    def set_uniform_texture(
        self,
        str name not None,
        Texture texture not None,
        uint8_t stage,
        uint32_t flags=UINT32_MAX
    ):
        self.c_material.get().set_uniform_texture(
            name.encode(), texture.c_texture, stage, flags
        )

    def set_uniform_value(self, str name not None, tuple value not None):
        cdef:
            CUniformSpecification c_uniform = self.get_specification(name)
            uint16_t elements_num = c_uniform.number_of_elements()

        if elements_num > 1:
            assert len(value) == c_uniform.number_of_elements(), (
                f'Invalid number of elements, expected {elements_num}, '
                f'got {len(value)}.'
            )
        else:
            value = (value, )

        cdef:
            vector[CFVec4] c_vec4
            vector[CFMat3] c_mat3
            vector[CFMat4] c_mat4

        for nested_value in value:
            if c_uniform.type() == CUniformType.vec4:
                assert len(nested_value) == 4, (
                    f'Invalid number of elements for {UniformType.vec4.name} '
                    f'(got {len(nested_value)}).'
                )

                c_vec4.push_back(
                    CFVec4(
                        nested_value[0], nested_value[1],
                        nested_value[2], nested_value[3]
                    )
                )
            elif c_uniform.type() == CUniformType.mat3:
                assert len(nested_value) == 9, \
                    f'Invalid number of elements for {UniformType.mat3.name}'

                c_mat3.push_back(
                    CFMat3(
                        nested_value[0], nested_value[1], nested_value[2],
                        nested_value[3], nested_value[4], nested_value[5],
                        nested_value[6], nested_value[7], nested_value[8]
                    )
                )
            elif c_uniform.type() == CUniformType.mat4:
                assert len(nested_value) == 16, \
                    f'Invalid number of elements for {UniformType.mat4.name}'

                c_mat4.push_back(
                    CFMat4(
                        nested_value[0], nested_value[1], nested_value[2],
                        nested_value[3], nested_value[4], nested_value[5],
                        nested_value[6], nested_value[7], nested_value[8],
                        nested_value[9], nested_value[10], nested_value[11],
                        nested_value[12], nested_value[13], nested_value[14],
                        nested_value[15]
                    )
                )
            else:
                raise Exception('Unsupported uniform type.')

        if c_uniform.type() == CUniformType.vec4:
            self.c_material.get().set_uniform_value[CFVec4](
                name.encode(), cmove(CUniformValue[CFVec4](c_vec4))
            )
        elif c_uniform.type() == CUniformType.mat3:
            self.c_material.get().set_uniform_value[CFMat3](
                name.encode(), cmove(CUniformValue[CFMat3](c_mat3))
            )
        elif c_uniform.type() == CUniformType.mat4:
            self.c_material.get().set_uniform_value[CFMat4](
                name.encode(), cmove(CUniformValue[CFMat4](c_mat4))
            )
        else:
            raise Exception('Unsupported uniform type.')


@cython.final
cdef class Material(_Material):
    @staticmethod
    cdef Material create(CResourceReference[CMaterial]& c_material):
        cdef Material instance = Material.__new__(Material)
        instance.c_material = c_material
        return instance

    def clone(self):
        return Material.create(self.c_material.get().clone())


@cython.final
cdef class SamplerValue:
    cdef CSamplerValue c_value

    @staticmethod
    cdef SamplerValue create(const CSamplerValue& c_value):
        cdef SamplerValue instance = SamplerValue.__new__(SamplerValue)
        instance.c_value = c_value
        return instance

    @property
    def stage(self):
        return self.c_value.stage

    @property
    def flags(self):
        return self.c_value.flags

    @property
    def texture(self):
        return Texture.create(self.c_value.texture)
