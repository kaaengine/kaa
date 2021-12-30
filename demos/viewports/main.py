import os
import random

from kaa.nodes import Node
from kaa.colors import Color
from kaa.images import Sprite
from kaa.input import Keycode
from kaa.engine import Engine, Scene
from kaa.geometry import Vector, Polygon

PYTHON_IMAGE_PATH = os.path.join('demos', 'assets', 'python_small.png')


class MainScene(Scene):

    def __init__(self):
        snake_image = Sprite(PYTHON_IMAGE_PATH)
        self.camera.position = Vector.xy(0)
        self.viewports[1].camera.position = Vector.xy(0)
        self.viewports[1].origin = Vector(600, 0)
        self.viewports[1].dimensions = Vector(200, 600)

        self.root.add_child(
            Node(
                shape=Polygon.from_box(Vector(800, 600 * 800 / 200)),
                color=Color(0.5, 0.5, 0.5, 0.95),
                viewports={1}
            )
        )

        for _ in range(100):
            x = random.randrange(-400, 400)
            y = random.randrange(-1200, 1200)
            self.root.add_child(
                Node(
                    sprite=snake_image,
                    viewports={0, 1},
                    position=Vector(x, y),
                    z_index=1
                )
            )

        self.viewport = Node(
            shape=Polygon.from_box(Vector(800, 600)),
            color=Color(1, 0, 0, 0.2),
            viewports={1},
        )
        self.root.add_child(self.viewport)

    def update(self, dt):
        for event in self.input.events():
            if event.keyboard_key and event.keyboard_key.is_key_down:
                if event.keyboard_key.key == Keycode.q:
                    self.engine.quit()
                elif event.keyboard_key.key == Keycode.w:
                    self.camera.position += Vector(0, -20)
                    self.viewport.position += Vector(0, -20)
                elif event.keyboard_key.key == Keycode.s:
                    self.camera.position += Vector(0, 20)
                    self.viewport.position += Vector(0, 20)


if __name__ == '__main__':
    with Engine(Vector(800, 600)) as engine:
        engine.run(MainScene())
