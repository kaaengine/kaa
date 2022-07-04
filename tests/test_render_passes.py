import pytest

from kaa.exceptions import KaacoreError
from kaa.render_passes import RenderTarget, Effect
from kaa.materials import Uniform, UniformType, Material


@pytest.mark.usefixtures('test_engine')
def test_render_target(image_path):
    target = RenderTarget()
    assert target.texture == target.texture


@pytest.mark.usefixtures('test_engine')
def test_effects(fragment_shader_effect, texture):
    vec4 = Uniform(UniformType.vec4, number_of_elements=1)
    sampler = Uniform(UniformType.sampler)
    uniforms = {'vec4': vec4, 'sampler': sampler}
    effect = Effect(fragment_shader_effect, uniforms)

    assert effect.uniforms == uniforms
    assert effect.get_uniform_value('vec4') is None
    assert effect.get_uniform_texture('sampler') is None

    value = (1., 1., 1., 1.)
    effect.set_uniform_value('vec4', value)
    effect.set_uniform_texture('sampler', texture=texture, stage=1, flags=11)

    assert effect.get_uniform_value('vec4') == value
    sampler_value = effect.get_uniform_texture('sampler')
    assert sampler_value.texture == texture
    assert sampler_value.stage == 1
    assert sampler_value.flags == 11


@pytest.mark.usefixtures('test_engine')
def test_materials_invalid(fragment_shader):
    with pytest.raises(KaacoreError):
        Effect(fragment_shader, {})


@pytest.mark.usefixtures('test_engine')
def test_effects_cloning(fragment_shader_effect, texture):
    vec4 = Uniform(UniformType.vec4, number_of_elements=1)
    effect = Effect(fragment_shader_effect, {'vec4': vec4})

    value = (1., 1., 1., 1.)
    effect.set_uniform_value('vec4', value)
    effect2 = effect.clone()

    assert effect != effect2
    assert effect.uniforms == effect2.uniforms
    assert effect.get_uniform_value('vec4') == effect2.get_uniform_value('vec4')

    value2 = (0, 0, 0, 0)
    effect2.set_uniform_value('vec4', value2)

    assert effect.get_uniform_value('vec4') == value
    assert effect2.get_uniform_value('vec4') == value2
