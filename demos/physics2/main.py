import os
import random

from kaa.colors import Color
from kaa.input import Keycode
from kaa.sprites import Sprite
from kaa.engine import Engine, Scene
from kaa.geometry import Vector, Segment, Circle
from kaa.physics import BodyNodeType, CollisionPhase
from kaa.nodes import SpaceNode, BodyNode, HitboxNode


BOX_IMAGE_PATH = os.path.join('demos', 'assets', 'box.png')
PYTHON_IMAGE_PATH = os.path.join('demos', 'assets', 'python_small.png')


COLLISION_TRIGGER = 1


def random_color():
    return Color.from_int(
        r=random.randint(0, 255),
        g=random.randint(0, 255),
        b=random.randint(0, 255),
        a=255
    )


class FlyingBall(BodyNode):
    pass


class MyScene(Scene):
    def __init__(self):
        self.python_img = Sprite(PYTHON_IMAGE_PATH)
        self.box_img = Sprite(BOX_IMAGE_PATH)

        self.objects = []
        self.random_collisions = False
        self.collision_spawning = False

        self.space = self.root.add_child(SpaceNode(
            scale=Vector(0.01, 0.01),
            # position=Vector(400, 300),
        ))
        self.box = self.space.add_child(BodyNode(
            sprite=self.box_img,
            body_type=BodyNodeType.kinematic,
            # rotation=45.,
            # angular_velocity_degrees=30.,
        ))
        # create bounding collision box with segments
        self.box_seg1 = self.box.add_child(HitboxNode(
            shape=Segment(Vector(-143, -143), Vector(-143, 143)),
        ))
        self.box_seg2 = self.box.add_child(HitboxNode(
            shape=Segment(Vector(-143, 143), Vector(143, 143)),
        ))
        self.box_seg3 = self.box.add_child(HitboxNode(
            shape=Segment(Vector(143, 143), Vector(143, -143)),
        ))
        self.box_seg4 = self.box.add_child(HitboxNode(
            shape=Segment(Vector(143, -143), Vector(-143, -143)),
        ))

        for i in range(5):
            self.spawn_object()

        def _timer_callback(timer):
            self.spawn_object()
            timer.restart()

        # self.timer = self.add_callback_timer(_timer_callback, 1500)

        self.space.set_collision_handler(
            COLLISION_TRIGGER, COLLISION_TRIGGER,
            self.on_collision,
            phases_mask=(CollisionPhase.begin |
                         CollisionPhase.separate),
        )

    def on_collision(self, arbiter, obj_a, obj_b):
        print("COLLISION")
        if arbiter.phase == CollisionPhase.begin:
            if self.random_collisions:
                return random.randint(0, 1)
        elif arbiter.phase == CollisionPhase.separate:
            obj_a.hitbox.color = random_color()
            obj_b.hitbox.color = random_color()
            if self.collision_spawning:
                self.collision_spawning = False
                self.spawn_object()

    def spawn_object(self):
        obj = self.space.add_child(FlyingBall(
            sprite=self.python_img,
            body_type=BodyNodeType.dynamic,
            position=Vector(random.randint(-100, 100), random.randint(-100, 100)),
            velocity=Vector(random.gauss(0, 0.1), random.gauss(0, 0.1) * 100),
            angular_velocity_degrees=random.gauss(0., 50.),
        ))
        obj_hitbox = obj.add_child(HitboxNode(
            shape=Circle(10.),
            trigger_id=COLLISION_TRIGGER,
        ))
        self.objects.append(obj)

    def delete_object(self):
        all_balls = self.find_nodes(filter_class=FlyingBall)
        if all_balls:
            obj = random.choice(all_balls)
            obj.delete()

    def update(self, dt):
        for event in self.input.events():
            if event.is_quit():
                self.engine.quit()
            elif event.is_pressing(Keycode.n):
                self.spawn_object()
            elif event.is_pressing(Keycode.d):
                self.delete_object()
            elif event.is_pressing(Keycode.r):
                self.random_collisions = not self.random_collisions
                print("Random collisions: {}".format(self.random_collisions))
            elif event.is_pressing(Keycode.t):
                if self.timer.is_running:
                    print("Stopping timer")
                    self.timer.cancel()
                else:
                    print("Restarting timer")
                    self.timer.restart()
            elif event.is_pressing(Keycode.c):
                self.collision_spawning = not self.collision_spawning
                if self.collision_spawning:
                    print("Collision spawning enabled (for one collision)")

        if self.input.is_pressed(Keycode.q):
            print("q Pressed - Exiting")
            self.engine.quit()


print("Press N to spawn more objects")
print("Press D to delete random object")
print("Press R to toggle random collisions")
print("Press T to stop/restart timer")
print("Press C to toggle collision spawning")


if __name__ == '__main__':
    with Engine(virtual_resolution=Vector(10, 10)) as engine:
        engine.run(MyScene())
