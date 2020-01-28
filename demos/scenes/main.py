import os

from kaa.nodes import Node
from kaa.colors import Color
from kaa.input import Keycode
from kaa.images import Sprite
from kaa.engine import Engine, Scene
from kaa.geometry import Polygon, Vector


SCENES = None

BOX_IMAGE_PATH = os.path.join('demos', 'assets', 'box.png')
PYTHON_IMAGE_PATH = os.path.join('demos', 'assets', 'python_small.png')


class MainScene(Scene):

    def __init__(self):
        self.camera.position = Vector(0., 0.)
        python_image = Sprite(PYTHON_IMAGE_PATH,)
        self.root.add_child(
            Node(
                sprite=python_image,
                shape=Polygon.from_box(Vector(1, 1))
            )
        )

    def on_enter(self):
        print(f'{self.__class__.__name__} on_enter')
        self.engine.renderer.clear_color=Color(0.5, 0.75, 0.25, 1)

    def update(self, dt):
        for event in self.input.events():
            if event.keyboard_key and event.keyboard_key.is_key_down:
                if event.keyboard_key.key == Keycode.q:
                    self.engine.quit()
                elif event.keyboard_key.key == Keycode.c:
                    self.engine.change_scene(SCENES['second'])

    def on_exit(self):
        print(f'{self.__class__.__name__} on_exit')


class SecondScene(Scene):

    def __init__(self):
        self.camera.position = Vector(0., 0.)
        box_image = Sprite(BOX_IMAGE_PATH)
        self.root.add_child(
            Node(
                sprite=box_image,
                shape=Polygon.from_box(Vector(10, 10))
            )
        )

    def on_enter(self):
        print(f'{self.__class__.__name__} on_enter')
        self.engine.renderer.clear_color=Color(0.5, 0.25, 0.75, 1)

    def update(self, dt):
        for event in self.input.events():
            if event.keyboard_key:
                if event.keyboard_key.key == Keycode.q:
                    self.engine.quit()
                elif event.keyboard_key.key == Keycode.c:
                    self.engine.change_scene(SCENES['main'])

    def on_exit(self):
        print(f'{self.__class__.__name__} on_exit')


if __name__ == '__main__':
    with Engine(virtual_resolution=Vector(10, 10)) as engine:
        main_scene = MainScene()
        SCENES = {'main': main_scene, 'second': SecondScene()}
        engine.run(main_scene)
