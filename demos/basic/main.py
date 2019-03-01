from kaa import (
    Scene, start_game, quit_game, Node, Segment, Circle, Vector,
    Keycode, Mousecode
)


class DemoScene(Scene):
    def __init__(self):
        self.seg_node = Node()
        self.seg_node.shape = Segment(Vector(-2., -2.),
                                      Vector(2., 2.,))

        self.circle_node = Node()
        self.circle_node.shape = Circle(Vector(2., 2.), 2.)

        self.root.add_child(self.seg_node)
        self.root.add_child(self.circle_node)

    def update(self, dt):
        for event in self.input.events():
            if event.is_quit():
                self.quit()
            elif event.is_pressing(Keycode.q):
                self.quit()

        # if self.time > 1000:
        #     self.quit()


start_game(DemoScene)
