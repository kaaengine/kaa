import os
import random

from kaa.input import Keycode
from kaa.images import Sprite
from kaa.engine import Engine, Scene
from kaa.geometry import Vector, Polygon
from kaa.physics import SpaceNode, BodyNode, BodyNodeType

PYTHON_IMAGE_PATH = os.path.join('demos', 'assets', 'python_small.png')


def update_velocity(node, gravity, damping, dt):
    # reimplements default velocity function
    if node.body_type == BodyNodeType.kinematic:
        return

    assert node.mass > 0 and node.moment > 0

    f = node.force
    v = node.velocity
    m_inv = node.mass_inverse
    node.velocity = (v * damping) + ((gravity + (f * m_inv)) * dt)

    t = node.torque
    w = node.angular_velocity
    node.angular_velocity = (w * damping) + (t * m_inv * dt)

    node.force = Vector.xy(0)
    node.torque = 0


def update_position(node, dt):
    # reimplements default position function
    node.position += (node.velocity + node._velocity_bias) * dt
    node.rotation += (node.angular_velocity + node._angular_velocity_bias) * dt

    node._velocity_bias = Vector.xy(0)
    node._angular_velocity_bias = 0


class MainScene(Scene):

    def __init__(self):
        self.camera.position = Vector(0., 0.)
        self.space = self.root.add_child(
            SpaceNode(position=Vector(0, 0), gravity=Vector(0, 20), damping=0.9)
        )
        image = Sprite(PYTHON_IMAGE_PATH)

        random_angle = random.randrange(225, 315)
        self.node = self.space.add_child(
            BodyNode(
                mass=100,
                sprite=image,
                angular_velocity=10,
                shape=Polygon.from_box(Vector(20, 20)),
                velocity=Vector.from_angle_degrees(random_angle) * 100
            )
        )

        self.node.set_position_update_callback(update_position)
        self.node.set_velocity_update_callback(update_velocity)

    def update(self, dt):
        for event in self.input.events():
            if event.keyboard_key:
                if event.keyboard_key.key_down == Keycode.q:
                    self.engine.quit()


if __name__ == '__main__':
    with Engine(virtual_resolution=Vector(1024, 768)) as engine:
        engine.run(MainScene())
