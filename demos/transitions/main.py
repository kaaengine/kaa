import os
import random

from kaa.engine import Engine, Scene
from kaa.input import Keycode
from kaa.geometry import Vector, Circle
from kaa.sprites import Sprite, split_spritesheet
from kaa.nodes import Node
from kaa.physics import SpaceNode, BodyNode
from kaa.colors import Color
from kaa.transitions import (
    NodeTransitionsSequence, NodeTransitionsParallel, AttributeTransitionMethod,
    NodePositionTransition, NodeRotationTransition, NodeScaleTransition,
    NodeColorTransition, NodeCustomTransition, BodyNodeVelocityTransition,
    NodeTransitionDelay, NodeTransitionCallback, NodeSpriteTransition,
)
from kaa.easings import Easing


PYTHON_IMAGE_PATH = os.path.join('demos', 'assets', 'python_small.png')
EXPLOSION_IMAGE_PATH = os.path.join('demos', 'assets', 'explosion.png')


class DemoTransitionsScene(Scene):
    def __init__(self):
        self.camera.position = Vector(0., 0.)
        self.python_img = Sprite(PYTHON_IMAGE_PATH)

        self.transition = NodeTransitionsSequence([
            NodePositionTransition(Vector(-100., -100.), 3000.,
                                   advance_method=AttributeTransitionMethod.add,
                                   loops=3,
                                   easing=Easing.elastic_in_out),
            NodePositionTransition(Vector(100., 0.), 3000.,
                                   advance_method=AttributeTransitionMethod.add,
                                   easing=Easing.back_in_out),
            NodeTransitionDelay(1500.),
            NodeTransitionCallback(
                lambda node: setattr(node, 'sprite', None)
            ),
            NodeTransitionsParallel([
                NodePositionTransition(Vector(-50., 100.), 3000.,
                                       advance_method=AttributeTransitionMethod.add),
                NodeRotationTransition(1., 5000.),
                NodeScaleTransition(Vector(2., 2.), 3000.),
                NodeColorTransition(Color(0., 1., 0., 0.5), 4000.),
            ], back_and_forth=True),
        ])

        self.custom_transition = NodeCustomTransition(
            lambda node: {'positions': [
                Vector(random.uniform(-100, 100), random.uniform(-100, 100))
                for _ in range(10)
            ]},
            lambda state, node, t: setattr(
                node, 'position',
                state['positions'][min(int(t * 10), 9)],
            ),
            10000.,
            loops=5,
        )

        spritesheet_frames = split_spritesheet(
            Sprite(EXPLOSION_IMAGE_PATH), Vector(64, 64),
        )
        self.sprite_transition = NodeSpriteTransition(
            spritesheet_frames, 1000., loops=0, back_and_forth=True,
            easing=Easing.quartic_out,
        )

        self.space = self.root.add_child(
            SpaceNode()
        )

        self.obj = self.space.add_child(
            Node(
                position=Vector(50., 50.),
                sprite=self.python_img,
                transition=self.transition,
            )
        )

        self.custom_obj = self.space.add_child(
            Node(
                color=Color(1., 0., 0.),
                sprite=self.python_img,
                transition=self.custom_transition,
            )
        )

        self.phys_obj = self.space.add_child(
            BodyNode(
                color=Color(0., 1., 1.),
                position=Vector(-50., 50.),
                sprite=self.python_img,
                velocity=Vector(0., 30.),
                transition=BodyNodeVelocityTransition(Vector(0., -30.), 10000.),
            )
        )

        self.animated_obj = self.space.add_child(
            Node(
                position=Vector(-20., 10.),
                transition=self.sprite_transition,
            )
        )

    def update(self, dt):
        if self.input.keyboard.is_pressed(Keycode.q):
            print("q Pressed - Exiting")
            self.engine.quit()


if __name__ == '__main__':
    with Engine(virtual_resolution=Vector(300, 300)) as engine:
        engine.window.size = Vector(800, 600)
        engine.window.center()
        engine.run(DemoTransitionsScene())
