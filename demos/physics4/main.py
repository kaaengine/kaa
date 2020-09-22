import os
import math
import random

from kaa.colors import Color
from kaa.input import Keycode
from kaa.images import Sprite
from kaa.engine import Engine, Scene
from kaa.geometry import Vector, Polygon, Circle
from kaa.physics import SpaceNode, BodyNode, BodyNodeType, HitboxNode

PYTHON_IMAGE_PATH = os.path.join('demos', 'assets', 'python_small.png')


class MainScene(Scene):

    def __init__(self):
        self.gravity_strength = 5.e6
        self.camera.position = Vector(0, 0)
        self.space = self.root.add_child(SpaceNode(position=Vector(0, 0)))
        image = Sprite(PYTHON_IMAGE_PATH)

        self.attractor = self.space.add_child(
            BodyNode(
                shape=Circle(50),
                body_type=BodyNodeType.static,
                color = Color.from_int(196, 196, 196, 255)
            )
        )
        self.attractor.add_child(HitboxNode(shape=self.attractor.shape))

        self.nodes = []
        for _ in range(200):
            offset = Vector(random.randrange(1, 100), random.randrange(1, 100))
            node = BodyNode(
                sprite=image,
                angular_velocity=5,
                velocity=Vector(30, 15),
                position = Vector(-512, -384) + offset,
                shape=Polygon.from_box(Vector(10, 10)),
            )
            node.add_child(HitboxNode(shape=node.shape))
            self.space.add_child(node)
            self.nodes.append(node)

        
    def update(self, dt):
        for event in self.input.events():
            if event.keyboard_key:
                if event.keyboard_key.key_down == Keycode.q:
                    self.engine.quit()
        
        for node in self.nodes:
            distance_vector = self.attractor.position - node.position
            distance = distance_vector.length()
            if distance < 75:
                node.damping = 0.9
            direction = distance_vector.normalize()
            node.gravity = direction * self.gravity_strength / math.pow(distance, 2)


if __name__ == '__main__':
    with Engine(virtual_resolution=Vector(1024, 768)) as engine:
        engine.run(MainScene())
