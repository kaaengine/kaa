from kaa.engine import Engine, Scene
from kaa.geometry import Vector, Polygon, Transformation
from kaa.nodes import Node
from kaa.input import Keycode
from kaa.colors import Color

class MyNode(Node):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        print(self.position)
        print(self.views)


class DemoScene(Scene):
    def __init__(self):
        self.square_1 = Node(shape=Polygon.from_box(Vector(100, 100)), color=Color(1, 0, 0, 1))
        self.square_2 = Node(shape=Polygon.from_box(Vector(100, 100)), color=Color(0, 1, 0, 1))
        self.square_3 = Node(shape=Polygon.from_box(Vector(100, 100)), color=Color(0, 0, 1, 1))

        common_trasformation = Transformation.rotate_degrees(45)| Transformation.translate(Vector(300, 300))

        self.square_1.transformation = Transformation.translate(Vector(-100, 0)) | common_trasformation
        self.square_2.transformation = Transformation.translate(Vector(0, 0)) | common_trasformation
        self.square_3.transformation = Transformation.translate(Vector(100, 0)) | common_trasformation

        self.root.add_child(self.square_1)
        self.root.add_child(self.square_2)
        self.root.add_child(self.square_3)

        MyNode(views={1}, position=Vector(200,200))

    def update(self, dt):
        for event in self.input.events():
            if event.keyboard_key and event.keyboard_key.is_key_down:
                key = event.keyboard_key.key
                if key == Keycode.q:
                    self.engine.quit()

if __name__ == '__main__':
    with Engine(virtual_resolution=Vector(1000, 800)) as engine:
        engine.run(DemoScene())
