import os
import random

from kaa.colors import Color
from kaa.input import Keycode, MouseButton
from kaa.sprites import Sprite
from kaa.engine import Engine, Scene
from kaa.geometry import Vector, Segment, Circle, Transformation
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
        self.camera.position = Vector(0., 0.)
        self.python_img = Sprite(PYTHON_IMAGE_PATH)
        self.box_img = Sprite(BOX_IMAGE_PATH)

        self.objects = []
        self.random_collisions = False
        self.collision_spawning = False

        self.space = self.root.add_child(SpaceNode())
        self.box = self.space.add_child(BodyNode(
            sprite=self.box_img,
            body_type=BodyNodeType.kinematic,
            angular_velocity_degrees=30.,
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

        self.space.set_collision_handler(
            COLLISION_TRIGGER, COLLISION_TRIGGER,
            self.on_collision,
            phases_mask=(CollisionPhase.begin |
                         CollisionPhase.separate),
        )

        self.observed_ball = [
            n for n in self.space.children if isinstance(n, FlyingBall)
        ][0]

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

    def spawn_object(self, position=None, velocity=None):
        if position is None:
            position = Vector(random.randint(-100, 100), random.randint(-100, 100))
        if velocity is None:
            velocity = Vector(random.gauss(0, 0.1), random.gauss(0, 0.1) * 100) * 10.

        obj = self.space.add_child(FlyingBall(
            sprite=self.python_img,
            body_type=BodyNodeType.dynamic,
            position=position,
            velocity=velocity,
            angular_velocity_degrees=random.gauss(0., 50.),
        ))
        obj.add_child(HitboxNode(
            shape=Circle(10.),
            trigger_id=COLLISION_TRIGGER,
        ))
        self.objects.append(obj)

    def update(self, dt):
        for event in self.input.events():
            if event.keyboard_key and event.keyboard_key.is_key_down:
                if event.keyboard_key.key == Keycode.n:
                    self.spawn_object()
                elif event.keyboard_key.key == Keycode.r:
                    self.random_collisions = not self.random_collisions
                    print("Random collisions: {}".format(self.random_collisions))
                elif event.keyboard_key.key == Keycode.c:
                    self.collision_spawning = not self.collision_spawning
                    if self.collision_spawning:
                        print("Collision spawning enabled (for one collision)")
                elif event.keyboard_key.key == Keycode.s:
                    self.observed_ball.velocity *= 1.5
                elif event.keyboard_key.key == Keycode.t:
                    print(self.observed_ball.transformation)
                    print(self.observed_ball.transformation.decompose())
                    self.observed_ball.transformation = \
                        (
                            Transformation(scale=Vector(2., 2.))
                            | Transformation(translate=Vector(100., 100.))
                        )
                elif event.keyboard_key.key == Keycode.l:
                    all_balls = [
                        n for n in self.space.children if isinstance(n, FlyingBall)
                    ]
                    if all_balls:
                        target_ball = random.choice(all_balls)
                        target_ball.lifetime = 1500

            if (
                event.mouse_button
                and event.mouse_button.is_button_down
                and event.mouse_button.button == MouseButton.left
            ):
                self.spawn_object(
                    position=self.camera.unproject_position(
                        event.mouse_button.position,
                    ),
                    velocity=Vector(0., 0.),
                )

        if self.input.keyboard.is_pressed(Keycode.q):
            print("q Pressed - Exiting")
            self.engine.quit()

        self.camera.position = self.observed_ball.position


print("Press N to spawn more objects")
print("Press D to delete random object")
print("Press R to toggle random collisions")
print("Press C to toggle collision spawning")


if __name__ == '__main__':
    with Engine(virtual_resolution=Vector(300, 300)) as engine:
        engine.window.size = Vector(800, 600)
        engine.window.center()
        engine.run(MyScene())
