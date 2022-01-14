import os

from kaa.nodes import Node
from kaa.input import Keycode
from kaa.images import Sprite
from kaa.geometry import Vector
from kaa.shaders import FragmentShader
from kaa.engine import Engine, Scene
from kaa.colors import Color
from kaa.audio import Sound, SoundPlayback
from kaa.materials import UniformType, Uniform
from kaa.render_passes import Effect, RenderTarget

PYTHON_IMAGE_PATH = os.path.join('demos', 'assets', 'python_powered.png')
PROJECTOR_SOUND = os.path.join('demos', 'assets', 'sounds', 'projector.ogg')


class MainScene(Scene):
    def __init__(self):
        clear_color = Color(1., 1., 1., 1.)
        fragment_shader = FragmentShader('demos/assets/shaders/fs_old_movie.sc')
        self.render_target = RenderTarget(clear_color)
        uniforms = {'s_target': Uniform(UniformType.sampler)}
        self.camera.position = Vector.xy(0)
        self.clear_color = clear_color
        self.effect = Effect(fragment_shader, uniforms)
        self.effect.set_uniform_texture(
            's_target', self.render_target.texture, 1
        )
        self.node = self.root.add_child(Node(sprite=Sprite(PYTHON_IMAGE_PATH)))
        self.sound = SoundPlayback(Sound(PROJECTOR_SOUND), volume=0.4)

        self.toggle_effect()

    def toggle_effect(self):
        if self.render_passes[1].effect:
            self.render_passes[1].effect = None
            self.render_passes[0].render_targets = None
            self.sound.stop()
        else:
            self.render_passes[1].effect = self.effect
            self.render_passes[0].render_targets = (self.render_target, )
            self.sound.play(loops=0)

    def update(self, dt):
        for event in self.input.events():
            if event.keyboard_key:
                if event.keyboard_key.key_down == Keycode.q:
                    self.engine.quit()
                elif event.keyboard_key.key_down == Keycode.e:
                    self.toggle_effect()


if __name__ == '__main__':
    with Engine(Vector(800, 600)) as engine:
        engine.run(MainScene())
