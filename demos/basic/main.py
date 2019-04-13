from kaa.game import Scene
from kaa.nodes import Node
from kaa.input import Keycode
from kaa.engine import Engine
from kaa.geometry import Vector, Segment, Circle, Polygon


class DemoScene(Scene):
    def __init__(self):
        self.seg_node = Node()
        self.seg_node.shape = Segment(Vector(-2., -2.), Vector(2., 2.))

        self.circle_node = Node()
        self.circle_node.shape = Circle(2., Vector(2., 2.))

        self.box_node = Node()
        self.box_node.shape = Polygon.from_box(Vector(1.5, 1.5))

        self.root.add_child(self.seg_node)
        self.root.add_child(self.circle_node)
        self.root.add_child(self.box_node)

    def update(self, dt):
        for event in self.input.events():
            if event.is_quit():
                self.engine.quit()
            elif event.is_pressing(Keycode.q):
                self.engine.quit()

        print("Mouse position: {}".format(self.input.get_mouse_position()))


if __name__ == '__main__':
    engine = Engine()
    engine.window.show()
    engine.run(DemoScene())
