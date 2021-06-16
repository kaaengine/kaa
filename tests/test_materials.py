import pytest

from kaa.images import Texture
from kaa.shaders import Program
from kaa.exceptions import KaacoreError
from kaa.materials import Uniform, UniformType, Material


def test_uniforms():
    number_of_elements = 11
    uniform = Uniform(UniformType.vec4, number_of_elements)
    assert uniform.type == UniformType.vec4
    assert uniform.number_of_elements == number_of_elements


@pytest.mark.usefixtures('test_engine')
def test_materials(program, texture):
    # single element
    vec4 = Uniform(UniformType.vec4, number_of_elements=1)
    sampler = Uniform(UniformType.sampler)
    uniforms = {'vec4': vec4, 'sampler': sampler}
    material = Material(program, uniforms)

    assert material.uniforms == uniforms
    assert material.get_uniform_value('vec4') is None
    assert material.get_uniform_texture('sampler') is None

    value = (1., 1., 1., 1.)
    material.set_uniform_value('vec4', value)
    material.set_uniform_texture('sampler', texture=texture, stage=1, flags=11)

    assert material.get_uniform_value('vec4') == value
    sampler_value = material.get_uniform_texture('sampler')
    assert sampler_value.texture == texture
    assert sampler_value.stage == 1
    assert sampler_value.flags == 11

    # multiple elements
    uniforms = {
        'vec4': Uniform(UniformType.vec4, number_of_elements=2),
        'mat3': Uniform(UniformType.mat3, number_of_elements=2),
        'mat4': Uniform(UniformType.mat4, number_of_elements=2)
    }
    material = Material(program, uniforms)

    assert material.get_uniform_value('vec4') is None
    assert material.get_uniform_value('mat3') is None
    assert material.get_uniform_value('mat4') is None

    vec4 = (
        (1., 1., 1., 1.),
        (0, 0, 0, 0)
    )
    material.set_uniform_value('vec4', vec4)

    mat3 = (
        (
            1., 1., 1.,
            1., 1., 1.,
            1., 1., 1.
        ),
        (
            0, 0, 0,
            0, 0, 0,
            0, 0, 0
        ),
    )
    material.set_uniform_value('mat3', mat3)

    mat4 = (
        (
            1., 1., 1., 1.,
            1., 1., 1., 1.,
            1., 1., 1., 1.,
            1., 1., 1., 1.
        ),
        (
            0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0
        ),
    )
    material.set_uniform_value('mat4', mat4)

    assert material.get_uniform_value('vec4') == vec4
    assert material.get_uniform_value('mat3') == mat3
    assert material.get_uniform_value('mat4') == mat4


@pytest.mark.usefixtures('test_engine')
def test_materials_cloning(program, texture):
    vec4 = Uniform(UniformType.vec4, number_of_elements=1)
    material = Material(program, {'vec4': vec4})

    value = (1., 1., 1., 1.)
    material.set_uniform_value('vec4', value)
    material2 = material.clone()

    assert material != material2
    assert material.uniforms == material2.uniforms
    assert material.get_uniform_value('vec4') == material2.get_uniform_value('vec4')

    value2 = (0, 0, 0, 0)
    material2.set_uniform_value('vec4', value2)

    assert material.get_uniform_value('vec4') == value
    assert material2.get_uniform_value('vec4') == value2


@pytest.mark.usefixtures('test_engine')
def test_materials_invalid_usage(program: Program, texture: Texture):
    vec4 = Uniform(UniformType.vec4, number_of_elements=1)
    sampler = Uniform(UniformType.sampler)
    uniforms = {'vec4': vec4, 'sampler': sampler}
    material = Material(program, uniforms)

    # non-existing  uniforms
    with pytest.raises(KaacoreError):
        material.get_uniform_texture('foo')

    with pytest.raises(KaacoreError):
        material.get_uniform_value('foo')

    with pytest.raises(KaacoreError):
        material.set_uniform_value('foo', (0, 0, 0, 0))

    with pytest.raises(KaacoreError):
        material.set_uniform_texture('foo', texture, 1, 1)

    # invalud values
    with pytest.raises(AssertionError):
        # invalid number of elements in vector
        material.set_uniform_value('vec4', (0, 0, 0))

    with pytest.raises(AssertionError):
        # invalid number of vectors
        material.set_uniform_value('vec4', ((0, 0, 0, 0), (0, 0, 0, 0)))

    vec4 = Uniform(UniformType.vec4, number_of_elements=2)
    uniforms = {'vec4': vec4}
    material = Material(program, uniforms)

    with pytest.raises(AssertionError):
        # invalid number of elements in nested value
        material.set_uniform_value('vec4', ((0, 0, 0, 0), (0, 0, 0)))
