import sys
import itertools
import logging

from kaa.nodes import Node
from kaa.input import Keycode
from kaa.audio import Music, Sound
from kaa.engine import Engine, Scene, VirtualResolutionMode
from kaa.geometry import Segment, Circle, Polygon, Vector
from kaa.log import (
    set_core_logging_level, CoreLogLevel, CoreLogCategory
)


logger = logging.getLogger('kaa.demos.basic')


class DemoScene(Scene):
    def __init__(self, sound_path, music_path):
        logger.info("Initializing scene: demo/basic.")
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

        print("Displays info:")
        for display in self.engine.get_displays():
            print("* {!r}".format(display))

    def update(self, dt):
        for event in self.input.events():
            if event.keyboard_key and event.keyboard_key.is_key_down:
                if event.keyboard_key.key == Keycode.q:
                    self.engine.quit()
                elif event.keyboard_key.key == Keycode.s:
                    if self.sound:
                        self.sound.play(0.5)
                    else:
                        print("No sound loaded!")
                elif event.keyboard_key.key == Keycode.n:
                    self.engine.virtual_resolution = \
                        next(self.virtual_resolutions_cycle)
                    print("Current virtual resolution: {} {!r}"
                        .format(self.engine.virtual_resolution,
                                self.engine.virtual_resolution_mode))
                elif event.keyboard_key.key == Keycode.m:
                    self.engine.virtual_resolution_mode = \
                        next(self.virtual_resolution_modes_cycle)
                    print("Current virtual resolution: {} {!r}"
                        .format(self.engine.virtual_resolution,
                                self.engine.virtual_resolution_mode))
                elif event.keyboard_key.key == Keycode.p:
                    print("Mouse position: {}".format(self.input.mouse.get_position()))
                elif event.keyboard_key.key == Keycode.num_9:
                    print("Decreasing master volume")
                    self.engine.audio.master_volume -= 0.1
                    print("Master volume: {}".format(self.engine.audio.master_volume))
                elif event.keyboard_key.key == Keycode.num_0:
                    print("Increasing master volume")
                    self.engine.audio.master_volume += 0.1
                    print("Master volume: {}".format(self.engine.audio.master_volume))
                elif event.keyboard_key.key == Keycode.num_7:
                    print("Decreasing master music volume")
                    self.engine.audio.master_music_volume -= 0.1
                    print("Master music volume: {}".format(self.engine.audio.master_music_volume))
                elif event.keyboard_key.key == Keycode.num_8:
                    print("Increasing master music volume")
                    self.engine.audio.master_music_volume += 0.1
                    print("Master music volume: {}".format(self.engine.audio.master_music_volume))
                elif event.keyboard_key.key == Keycode.num_5:
                    print("Decreasing master sound volume")
                    self.engine.audio.master_sound_volume -= 0.1
                    print("Master sound volume: {}".format(self.engine.audio.master_sound_volume))
                elif event.keyboard_key.key == Keycode.num_6:
                    print("Increasing master sound volume")
                    self.engine.audio.master_sound_volume += 0.1
                    print("Master sound volume: {}".format(self.engine.audio.master_sound_volume))
                elif event.keyboard_key.key == Keycode.x:
                    self.music.play()
                    print("Playing music")
                elif event.keyboard_key.key == Keycode.c:
                    ret = self.music.pause()
                    print("Pausing music, success: {}".format(ret))
                elif event.keyboard_key.key == Keycode.v:
                    ret = self.music.resume()
                    print("Resuming music, success: {}".format(ret))
                elif event.keyboard_key.key == Keycode.b:
                    ret = self.music.stop()
                    print("Stopping music, success: {}".format(ret))
            elif event.audio and  event.audio.music_finished:
                print("Music finished!")


if __name__ == '__main__':
    with Engine(virtual_resolution=Vector(5, 5)) as engine:
        set_core_logging_level(CoreLogCategory.engine, CoreLogLevel.debug)
        scene = DemoScene(
            sound_path=len(sys.argv) >= 2 and sys.argv[1],
            music_path=len(sys.argv) >= 3 and sys.argv[2],
        )
        engine.window.size = Vector(800, 600)
        engine.window.center()
        engine.run(scene)

    print(" * Ending script")
