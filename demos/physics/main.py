import os
import enum

from kaa import SpaceNode, BodyNode, HitboxNode
from kaa import BodyNodeType
from kaa import Keycode
from kaa import Vector, Segment, Circle, Polygon
from kaa import Scene
from kaa import Color
from kaa import Engine


# BOX_IMAGE_PATH = os.path.join('demos', 'assets', 'box.png')
PYTHON_IMAGE_PATH = os.path.join('demos', 'assets', 'python_small.png')


class HitboxMask(enum.IntFlag):
    side = enum.auto()
    snake = enum.auto()
    box1 = enum.auto()
    box2 = enum.auto()
    all = side | snake | box1 | box2


class CollisionTrigger(enum.IntEnum):
    obj = 1


class MyScene(Scene):
    def __init__(self):
        self.python_img = self.assets.load_image(PYTHON_IMAGE_PATH)
        # self.box_img = self.game.assets.load_image(BOX_IMAGE_PATH)
        self.collisions_enabled = True

        self.space = self.root.add_child(SpaceNode(
            # scale=Vector(0.01, 0.01),
            position=Vector(0, 0),
        ))
        self.box = self.space.add_child(BodyNode(
            body_type=BodyNodeType.kinematic,
            # rotation=45.,
            angular_velocity=0.3,
        ))
        # create bounding collision box with segments
        self.box_seg1 = self.box.add_child(HitboxNode(
            shape=Segment(Vector(-4, -4), Vector(-4, 4)),
            mask=HitboxMask.side,
            collision_mask=HitboxMask.all,
        ))
        self.box_seg2 = self.box.add_child(HitboxNode(
            shape=Segment(Vector(-4, 4), Vector(4, 4)),
            mask=HitboxMask.side,
            collision_mask=HitboxMask.all,
        ))
        self.box_seg3 = self.box.add_child(HitboxNode(
            shape=Segment(Vector(4, 4), Vector(4, -4)),
            mask=HitboxMask.side,
            collision_mask=HitboxMask.all,
        ))
        self.box_seg4 = self.box.add_child(HitboxNode(
            shape=Segment(Vector(4, -4), Vector(-4, -4)),
            mask=HitboxMask.side,
            collision_mask=HitboxMask.all,
        ))

        self.obj1 = self.space.add_child(BodyNode(
            mass=1e10,
            position=Vector(0, -2),
            velocity=Vector(-3.0, 0.5),  # * 10,
            # angular_velocity=-160.,
            shape=Circle(0.2),
            sprite=self.python_img,
            color=Color(1., 0., 0., 1.),
        ))
        self.obj1_hitbox = self.obj1.add_child(HitboxNode(
            shape=Circle(0.2),
            mask=HitboxMask.snake,
            collision_mask=HitboxMask.all,
            trigger_id=CollisionTrigger.obj,
            visible=False,
        ))

        self.obj2 = self.space.add_child(BodyNode(
            mass=1e10,
            position=Vector(0, 2),
            velocity=Vector(4.0, -0.1),  # * 10,
            # angular_velocity=20.,
            shape=Circle(0.2),
            sprite=self.python_img,
        ))
        self.obj2_hitbox = self.obj2.add_child(HitboxNode(
            shape=Circle(0.2),
            mask=HitboxMask.snake,
            collision_mask=HitboxMask.all,
            trigger_id=CollisionTrigger.obj,
            visible=False,
        ))
        self.obj3 = self.space.add_child(BodyNode(
            mass=1e15,
            moment=1e20,
            position=Vector(-1.5, 0.1),
            velocity=Vector(-1.0, -2.0),
            angular_velocity_degrees=35.,
            shape=Polygon([Vector(-1, -1), Vector(1, -1),
                           Vector(1, 1), Vector(-1, 1)]),
        ))
        self.obj3_hitbox = self.obj3.add_child(HitboxNode(
            mask=HitboxMask.box1,
            collision_mask=HitboxMask.all,
            shape=self.obj3.shape,
            visible=False,
        ))
        self.obj4 = self.space.add_child(BodyNode(
            position=Vector(0, -2),
            velocity=Vector(1.0, 5.0),
            angular_velocity_degrees=-5.,
            shape=Polygon.from_box(Vector(0.5, 1.)),
        ))
        self.obj4_hitbox = self.obj4.add_child(HitboxNode(
            mask=HitboxMask.box2,
            collision_mask=HitboxMask.all,
            shape=self.obj4.shape,
            visible=False,
        ))

        self.space.set_collision_handler(CollisionTrigger.obj,
                                         CollisionTrigger.obj,
                                         self.handle_collision)

    def handle_collision(self, arbiter, p1, p2):
        p2.body.delete()

    def update(self, dt):
        for event in self.input.events():
            if event.is_quit():
                self.engine.quit()
            if event.is_pressing(Keycode.c):
                self.collisions_enabled = not self.collisions_enabled
                if not self.collisions_enabled:
                    self.obj1_hitbox.collision_mask = HitboxMask.side
                    self.obj2_hitbox.collision_mask = HitboxMask.side
                    # self.obj3_hitbox.collision_mask = HitboxMask.side
                    # self.obj4_hitbox.collision_mask = HitboxMask.side
                    print("Objects will NOT collide")
                else:
                    self.obj1_hitbox.collision_mask = HitboxMask.all
                    self.obj2_hitbox.collision_mask = HitboxMask.all
                    # self.obj3_hitbox.collision_mask = HitboxMask.all
                    # self.obj4_hitbox.collision_mask = HitboxMask.all
                    print("Objects will collide")

        if self.input.is_pressed(Keycode.q):
            print("q Pressed - Exiting")
            self.engine.quit()
        elif self.input.is_pressed(Keycode.x) and self.space:
            self.space.delete()
            self.space = None


if __name__ == '__main__':
    engine = Engine()
    engine.create_window('kaa', 800, 600)
    engine.run(MyScene())
