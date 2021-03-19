import itertools
import logging

from kaa.nodes import Node
from kaa.input import Keycode
from kaa.engine import Engine, Scene, VirtualResolutionMode
from kaa.geometry import Segment, Circle, Polygon, Vector
from kaa.log import (
    set_core_logging_level, CoreLogLevel
)


logger = logging.getLogger('kaa.demos.basic')


class DemoScene(Scene):
    def __init__(self):
        logger.info("Initializing scene: demo/basic.")
        self.camera.position = Vector(0., 0.)
        self.seg_node = Node()
        self.seg_node.shape = Segment(Vector(-2., -2.),
                                      Vector(2., 2.,))

        self.circle_node = Node()
        self.circle_node.shape = Circle(2., Vector(2., 2.))

        self.box_node = Node()
        self.box_node.shape = Polygon.from_box(Vector(1.5, 1.5))

        logger.info("Node scene before adding to tree: %s", self.seg_node.scene)
        self.root.add_child(self.seg_node)
        self.root.add_child(self.circle_node)
        self.root.add_child(self.box_node)
        logger.info("Node scene after adding to tree: %s", self.seg_node.scene)

        self.virtual_resolutions_cycle = itertools.cycle(
            [Vector(10, 10), Vector(20, 20), Vector(5, 15), Vector(15, 5)]
        )
        self.virtual_resolution_modes_cycle = itertools.cycle(
            [VirtualResolutionMode.aggresive_stretch,
             VirtualResolutionMode.no_stretch,
             VirtualResolutionMode.adaptive_stretch]
        )

        logger.info("Displays info:")
        for display in self.engine.get_displays():
            logger.info("* %r", display)

    def update(self, dt):
        for event in self.input.events():
            if event.keyboard_key and event.keyboard_key.is_key_down:
                if event.keyboard_key.key == Keycode.q:
                    self.engine.quit()
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


if __name__ == '__main__':
    with Engine(virtual_resolution=Vector(5, 5)) as engine:
        set_core_logging_level("engine", CoreLogLevel.debug)
        scene = DemoScene()
        engine.window.size = Vector(800, 600)
        engine.window.center()
        engine.run(scene)

    logger.info("Ending script")
