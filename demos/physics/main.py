import os
import enum

from kaa.colors import Color
from kaa.images import Sprite
from kaa.input import Keycode
from kaa.engine import Engine, Scene
from kaa.geometry import Vector, Segment, Circle, Polygon
from kaa.physics import SpaceNode, BodyNode, HitboxNode, BodyNodeType


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
        self.camera.position = Vector(0., 0.)
        self.python_img = Sprite(PYTHON_IMAGE_PATH)
        self.collisions_enabled = True

        self.space = self.root.add_child(SpaceNode(
            position=Vector(0, 0),
        ))
        self.box = self.space.add_child(BodyNode(
            body_type=BodyNodeType.kinematic,
            angular_velocity=0.3,
        ))
        # create bounding collision box with segments
        self.box_seg1 = self.box.add_child(HitboxNode(
            shape=Segment(Vector(-4, -4), Vector(-4, 4)),
            mask=HitboxMask.side,
            collision_mask=HitboxMask.all,
            color=Color(0.5, 0.5, 0.5),
        ))
        self.box_seg2 = self.box.add_child(HitboxNode(
            shape=Segment(Vector(-4, 4), Vector(4, 4)),
            mask=HitboxMask.side,
            collision_mask=HitboxMask.all,
            color=Color(0.5, 0.5, 0.5),
        ))
        self.box_seg3 = self.box.add_child(HitboxNode(
            shape=Segment(Vector(4, 4), Vector(4, -4)),
            mask=HitboxMask.side,
            collision_mask=HitboxMask.all,
            color=Color(0.5, 0.5, 0.5),
        ))
        self.box_seg4 = self.box.add_child(HitboxNode(
            shape=Segment(Vector(4, -4), Vector(-4, -4)),
            mask=HitboxMask.side,
            collision_mask=HitboxMask.all,
            color=Color(0.5, 0.5, 0.5),
        ))

        self.obj1 = self.space.add_child(BodyNode(
            mass=1e10,
            position=Vector(0, -2),
            velocity=Vector(-3.0, 0.5),  # * 10,
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
            if event.keyboard_key and event.keyboard_key.is_key_down:
                if event.keyboard_key.key == Keycode.c:
                    self.collisions_enabled = not self.collisions_enabled
                    if not self.collisions_enabled:
                        self.obj1_hitbox.collision_mask = HitboxMask.side
                        self.obj2_hitbox.collision_mask = HitboxMask.side
                        print("Objects will NOT collide")
                    else:
                        self.obj1_hitbox.collision_mask = HitboxMask.all
                        self.obj2_hitbox.collision_mask = HitboxMask.all
                        print("Objects will collide")
                if event.keyboard_key.key == Keycode.f:
                    self.engine.window.fullscreen = not self.engine.window.fullscreen
                if event.keyboard_key.key == Keycode.l:
                    self.engine.window.size = self.engine.window.size + Vector(20, 20)
                if event.keyboard_key.key == Keycode.v:
                    self.engine.window.center()

        if self.input.keyboard.is_pressed(Keycode.q):
            print("q Pressed - Exiting")
            self.engine.quit()
        elif self.input.keyboard.is_pressed(Keycode.x) and self.space:
            self.space.delete()
            self.space = None


if __name__ == '__main__':
    engine = Engine(virtual_resolution=Vector(10, 10))
    engine.window.title = engine.window.title + "Test 123"
    engine.window.size = Vector(800, 600)
    engine.window.center()
    engine.run(MyScene())
