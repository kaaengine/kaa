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
        self.camera.position = Vector(0., 0.)
        snake_image = Sprite(PYTHON_IMAGE_PATH)

        minimap_view = self.views[1]
        minimap_view.origin = Vector(600, 0)
        minimap_view.dimensions = Vector(200, 600)
        minimap_view.camera.position = Vector.xy(0)
        minimap_view.camera.scale = Vector.xy(200 / 800)
        minimap_view.clear_color = Color(0.5, 0.5, 0.5, 1)

        for _ in range(100):
            x = random.randrange(-400, 400)
            y = random.randrange(-1200, 1200)
            self.root.add_child(
                Node(sprite=snake_image, views={0, 1}, position=Vector(x, y))
            )

        self.viewport = Node(
            color=Color(1, 0, 0, 0.1),
            views={1},
            shape=Polygon.from_box(Vector(800, 600))
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
