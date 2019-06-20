import os

from kaa.nodes import Node
from kaa.input import Keycode
from kaa.images import Sprite
from kaa.engine import Engine, Scene
from kaa.geometry import Polygon, Vector


SCENES = None

BOX_IMAGE_PATH = os.path.join('demos', 'assets', 'box.png')
PYTHON_IMAGE_PATH = os.path.join('demos', 'assets', 'python_small.png')


class MainScene(Scene):

    def __init__(self):
        python_image = Sprite(PYTHON_IMAGE_PATH,)
        self.root.add_child(
            Node(
                sprite=python_image,
                shape=Polygon.from_box(Vector(1, 1))
            )
        )

    def on_enter(self):
        print(f'{self.__class__.__name__} on_enter')

    def update(self, dt):
        for event in self.input.events():
            if event.is_quit():
                self.engine.quit()
            elif event.is_pressing(Keycode.q):
                self.engine.quit()
            elif event.is_pressing(Keycode.c):
                self.engine.change_scene(SCENES['second'])

    def on_exit(self):
        print(f'{self.__class__.__name__} on_exit')


class SecondScene(Scene):

    def __init__(self):
        box_image = Sprite(BOX_IMAGE_PATH)
        self.root.add_child(
            Node(
                sprite=box_image,
                shape=Polygon.from_box(Vector(10, 10))
            )
        )

    def on_enter(self):
        print(f'{self.__class__.__name__} on_enter')

    def update(self, dt):
        for event in self.input.events():
            if event.is_quit():
                self.engine.quit()
            elif event.is_pressing(Keycode.q):
                self.engine.quit()
            elif event.is_pressing(Keycode.c):
                self.engine.change_scene(SCENES['main'])

    def on_exit(self):
        print(f'{self.__class__.__name__} on_exit')


if __name__ == '__main__':
    engine = Engine()
    main_scene = MainScene()
    SCENES = {'main': main_scene, 'second': SecondScene()}
    engine.run(main_scene)
