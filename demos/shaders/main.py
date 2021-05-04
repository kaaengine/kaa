import os

from kaa.nodes import Node
from kaa.input import Keycode
from kaa.images import Sprite
from kaa.geometry import Vector
from kaa.engine import Engine, Scene
from kaa.materials import UniformType, Uniform, Material
from kaa.shaders import Program, Varying, VaryingType, AttributeLocation

PYTHON_IMAGE_PATH = os.path.join('demos', 'assets', 'python_powered.png')


class MainScene(Scene):

    def __init__(self):
        in_out_layout = {
            AttributeLocation.texcoord0: Varying('v_texcoord0', VaryingType.vec2)
        }
        program = Program.from_files(
            'demos/assets/shaders/vs_default.sc', 'demos/assets/shaders/fs_default.sc',
            in_out_layout
        )
        uniforms = {'u_blur': Uniform(UniformType.vec4)}
        self.blur_quality = 20.
        self.material = Material(program, uniforms)
        self.material.set_uniform_value('u_blur', (self.blur_quality, 0, 0, 0))
        self.node = self.root.add_child(
            Node(
                sprite=Sprite(PYTHON_IMAGE_PATH),
                position=Vector(400, 300),
                scale=Vector.xy(2),
                material=self.material
            )
        )

    def update(self, dt):
        for event in self.input.events():
            if event.keyboard_key:
                if event.keyboard_key.key_down == Keycode.q:
                    self.engine.quit()
                elif event.keyboard_key.key_down == Keycode.c:
                    if self.node.material:
                        self.node.material = None
                    else:
                        self.node.material = self.material
                elif event.keyboard_key.key_down == Keycode.a:
                    self.blur_quality = min(self.blur_quality + 1., 100.)
                    self.material.set_uniform_value(
                        'u_blur', (self.blur_quality, 0, 0, 0)
                    )
                elif event.keyboard_key.key_down == Keycode.z:
                    self.blur_quality = max(self.blur_quality - 1., 0)
                    self.material.set_uniform_value(
                        'u_blur', (self.blur_quality, 0, 0, 0)
                    )


if __name__ == '__main__':
    with Engine(Vector(800, 600)) as engine:
        engine.run(MainScene())
