import random
import itertools
import math
import enum

from kaa.engine import Engine, Scene
from kaa.geometry import Vector, Segment, Circle, Polygon
from kaa.nodes import Node
from kaa.physics import SpaceNode, BodyNode, HitboxNode
from kaa.timers import Timer
from kaa.input import Keycode, MouseButton
from kaa.colors import Color
from kaa.log import (
    set_core_logging_level, CoreLogLevel, CoreLogCategory
)


POINTER_COLOR_NORMAL = Color(1., 1., 1., 0.3)
POINTER_COLOR_ACTIVE = Color(1., 1., 1., 0.7)

set_core_logging_level(CoreLogCategory.physics, CoreLogLevel.debug)

PIECE_SHAPES = [
    Polygon.from_box(Vector(10, 10)),
    Polygon.from_box(Vector(15, 5)),
    Circle(8.),
    Polygon([Vector(0, 0), Vector(10, 0), Vector(0, 10)]),
]

POINTER_SHAPES = [
    Polygon.from_box(Vector(40, 30)),
    Circle(10.), Circle(25.),
    Polygon([Vector(-35, -35), Vector(0, -40), Vector(35, -35),
            Vector(40, 0), Vector(35, 35)]),
]


class QueryMask(enum.IntFlag):
    clickable = enum.auto()
    not_clickable = enum.auto()


class FallingPiece(BodyNode):
    def __init__(self, position):
        super().__init__(
            position=position,
            velocity=Vector(random.uniform(-20, 20), 0.),
            rotation_degrees=random.uniform(0, 360),
            scale=Vector(0.2, 0.2) + Vector.xy(
                math.fabs(random.gauss(0.0, 1.0)),
            ),
            lifetime=60000.,  # 60 seconds
        )

        self.hitbox = self.add_child(HitboxNode(
            shape=random.choice(PIECE_SHAPES),
        ))

        if random.randint(0, 1):
            self.hitbox.color = Color(0.0, 1.0, 0.0, 1.)
            self.hitbox.mask = QueryMask.clickable
        else:
            self.hitbox.color = Color(1.0, 1.0, 0.0, 1.)
            self.hitbox.mask = QueryMask.not_clickable


class DemoScene(Scene):
    def __init__(self):
        self.space = self.root.add_child(SpaceNode(
            gravity=Vector(0., 15.),
            sleeping_threshold=1.,
        ))

        self.pointer_shapes_gen = itertools.cycle(POINTER_SHAPES)
        self.pointer = self.root.add_child(Node(
            position=Vector(-500, -500),  # start offscreen
            shape=next(self.pointer_shapes_gen),
            color=POINTER_COLOR_NORMAL,
            z_index=10,
        ))

        self.spawn_timer = Timer(self._spawn_heartbeat, 20,
                                 single_shot=False)
        self.spawn_timer.start()

    def _spawn_heartbeat(self):
        if random.random() > 0.8:
            initial_position = Vector(
                random.uniform(0, 300), -20.
            )
            self.space.add_child(
                FallingPiece(initial_position)
            )

    def _perform_query(self):
        results = self.space.query_shape_overlaps(
            self.pointer.shape, self.pointer.position,
            collision_mask=QueryMask.clickable,
        )
        print("Results count: {}".format(len(results)))
        for r in results:
            r.hitbox.color = Color(0., 1., 1., 1.)
            r.body.velocity = Vector(0, 0)
            for cp in r.contact_points:
                self.space.add_child(Node(
                    position=cp.point_b,
                    shape=Circle(0.5),
                    color=Color(1., 0., 0., 1.),
                    lifetime=200,
                    z_index=3,
                ))

    def update(self, dt):
        for event in self.input.events():
            if event.keyboard_key and event.keyboard_key.is_key_down:
                key = event.keyboard_key.key
                if key == Keycode.q:
                    self.engine.quit()
                elif key == Keycode.x:
                    self.pointer.shape = next(self.pointer_shapes_gen)
            elif event.mouse_motion:
                self.pointer.position = event.mouse_motion.position
            elif (
                event.mouse_button and event.mouse_button.button == MouseButton.left
            ):
                if event.mouse_button.is_button_down:
                    self.pointer.color = POINTER_COLOR_ACTIVE
                    self._perform_query()
                else:
                    self.pointer.color = POINTER_COLOR_NORMAL


if __name__ == '__main__':
    with Engine(virtual_resolution=Vector(300, 300)) as engine:
        engine.run(DemoScene())
