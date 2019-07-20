import sys
import itertools

from kaa.nodes import Node
from kaa.input import Keycode
from kaa.audio import Music, Sound
from kaa.engine import Engine, Scene, VirtualResolutionMode
from kaa.geometry import Segment, Circle, Polygon, Vector


class DemoScene(Scene):
    def __init__(self, sound_path, music_path):
        self.camera.position = Vector(0., 0.)
        self.seg_node = Node()
        self.seg_node.shape = Segment(Vector(-2., -2.),
                                      Vector(2., 2.,))

        self.circle_node = Node()
        self.circle_node.shape = Circle(2., Vector(2., 2.))

        self.box_node = Node()
        self.box_node.shape = Polygon.from_box(Vector(1.5, 1.5))

        print("Node scene before adding to tree: {}".format(self.seg_node.scene))
        self.root.add_child(self.seg_node)
        self.root.add_child(self.circle_node)
        self.root.add_child(self.box_node)
        print("Node scene after adding to tree: {}".format(self.seg_node.scene))

        if sound_path:
            self.sound = Sound(sound_path)
        else:
            self.sound = None

        if music_path:
            self.music = Music(music_path)
            self.music.play()
        else:
            self.music = None

        self.virtual_resolutions_cycle = itertools.cycle(
            [Vector(10, 10), Vector(20, 20), Vector(5, 15), Vector(15, 5)]
        )
        self.virtual_resolution_modes_cycle = itertools.cycle(
            [VirtualResolutionMode.aggresive_stretch,
             VirtualResolutionMode.no_stretch,
             VirtualResolutionMode.adaptive_stretch]
        )

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
            elif event.is_pressing(Keycode.n):
                self.engine.virtual_resolution = \
                    next(self.virtual_resolutions_cycle)
                print("Current virtual resolution: {} {!r}"
                      .format(self.engine.virtual_resolution,
                              self.engine.virtual_resolution_mode))
            elif event.is_pressing(Keycode.m):
                self.engine.virtual_resolution_mode = \
                    next(self.virtual_resolution_modes_cycle)
                print("Current virtual resolution: {} {!r}"
                      .format(self.engine.virtual_resolution,
                              self.engine.virtual_resolution_mode))
            elif event.is_pressing(Keycode.p):
                print("Mouse position: {}".format(self.input.get_mouse_position()))


if __name__ == '__main__':
    with Engine(virtual_resolution=Vector(5, 5)) as engine:
        scene = DemoScene(
            sound_path=len(sys.argv) >= 2 and sys.argv[1],
            music_path=len(sys.argv) >= 3 and sys.argv[2],
        )

        engine.run(scene)

    print(" * Ending script")
