import os
import random

from kaa.engine import Engine, Scene
from kaa.input import Keycode
from kaa.geometry import Vector, Circle
from kaa.sprites import Sprite
from kaa.nodes import Node
from kaa.physics import SpaceNode, BodyNode
from kaa.colors import Color
from kaa.transitions import (
    NodeTransitionsSequence, NodeTransitionsParallel, AttributeTransitionMethod,
    NodePositionTransition, NodeRotationTransition, NodeScaleTransition,
    NodeColorTransition, NodeCustomTransition, BodyNodeVelocityTransition,
    NodeTransitionDelay, NodeTransitionCallback,
)


PYTHON_IMAGE_PATH = os.path.join('demos', 'assets', 'python_small.png')


def random_color():
    return Color(random.random(), random.random(), random.random())


class DemoTransitionsScene(Scene):
    def __init__(self):
        self.camera.position = Vector(0., 0.)
        self.python_img = Sprite(PYTHON_IMAGE_PATH)

        self.obj = self.root.add_child(Node(
            position=Vector(-50, 0),
            shape=Circle(10.),
            color=random_color(),
        ))

        self.obj.transitions_manager.set(
            'movement',
            NodePositionTransition(
                Vector(100, 30), 3000.,
                advance_method=AttributeTransitionMethod.add,
                loops=0, back_and_forth=True,
            )
        )

    def _randomize_color_transition(self):
        return NodeColorTransition(
            random_color(), 2000.,
            loops=0, back_and_forth=True,
        )

    def update(self, dt):
        for event in self.input.events():
            if event.keyboard_key and event.keyboard_key.is_key_down:
                pressed_key = event.keyboard_key.key
                if pressed_key == Keycode.q:
                    self.engine.quit()
                elif pressed_key == Keycode.num_1:
                    self.obj.transitions_manager.set(
                        'color', self._randomize_color_transition()
                    )
                elif pressed_key == Keycode.num_2:
                    self.obj.transitions_manager.set(
                        'pseudo_timer',
                        NodeTransitionsSequence([
                            NodeTransitionDelay(1000.),
                            NodeTransitionCallback(
                                lambda node: node.transitions_manager.set(
                                    'color', self._randomize_color_transition(),
                                )
                            )
                        ])
                    )
                elif pressed_key == Keycode.num_0:
                    self.obj.transitions_manager.set(
                        'color', None
                    )
                    self.obj.transitions_manager.set(
                        'pseudo_timer', None
                    )


if __name__ == '__main__':
    with Engine(virtual_resolution=Vector(300, 300)) as engine:
        engine.window.size = Vector(800, 600)
        engine.window.center()
        engine.run(DemoTransitionsScene())
