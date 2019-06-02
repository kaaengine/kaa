import sys

from kaa.nodes import Node
from kaa.input import Keycode
from kaa.audio import Music, Sound
from kaa.engine import Engine, Scene
from kaa.geometry import Segment, Circle, Polygon, Vector


class DemoScene(Scene):
    def __init__(self, sound_path, music_path):
        self.seg_node = Node()
        self.seg_node.shape = Segment(Vector(-2., -2.),
                                      Vector(2., 2.,))

        self.circle_node = Node()
        self.circle_node.shape = Circle(2., Vector(2., 2.))

        self.box_node = Node()
        self.box_node.shape = Polygon.from_box(Vector(1.5, 1.5))

        self.root.add_child(self.seg_node)
        self.root.add_child(self.circle_node)
        self.root.add_child(self.box_node)

        if sound_path:
            self.sound = Sound(sound_path)
        else:
            self.sound = None

        if music_path:
            self.music = Music(music_path)
            self.music.play()
        else:
            self.music = None

    def update(self, dt):
        for event in self.input.events():
            if event.is_quit():
                self.engine.quit()
            elif event.is_pressing(Keycode.q):
                self.engine.quit()
            elif event.is_pressing(Keycode.s):
                if self.sound:
                    self.sound.play(0.5)
                else:
                    print("No sound loaded!")

        print("Mouse position: {}".format(self.input.get_mouse_position()))


if __name__ == '__main__':
    with Engine() as engine:
        scene = DemoScene(
            sound_path=len(sys.argv) >= 2 and sys.argv[1],
            music_path=len(sys.argv) >= 3 and sys.argv[2],
        )

        engine.run(scene)

    print(" * Ending script")
