import os
import math

from kaa.nodes import Node
from kaa.colors import Color
from kaa.input import Keycode
from kaa.images import Sprite
from kaa.engine import Engine, Scene
from kaa.geometry import Polygon, Vector
from kaa.render_passes import RenderTarget
from kaa.transitions import (
    NodeTransition, NodeTransitionsParallel, NodeTransitionsSequence,
    NodeTransitionCallback, NodeTransitionDelay
)


SCENES = None

BOX_IMAGE_PATH = os.path.join('demos', 'assets', 'box.png')
PYTHON_IMAGE_PATH = os.path.join('demos', 'assets', 'python_small.png')


class SceneTransitionNode(Node):

    def __init__(self, resolution, source_pass, target_pass, **kwargs):
        self.target = RenderTarget()
        self.source_pass = source_pass

        transition = kwargs.get('transition')
        if transition is None:
            transition = NodeTransitionDelay(0)

        kwargs['transition'] = NodeTransitionsSequence([
            transition,
            NodeTransitionCallback(lambda n: n.delete())
        ])

        super().__init__(
            **kwargs,
            render_passes={target_pass},
            shape=Polygon.from_box(resolution),
            sprite=Sprite.from_texture(self.target.texture)
        )

    def on_attach(self):
        self.target.clear_color = self.scene.clear_color
        self.scene.render_passes[self.source_pass].render_targets = (self.target, )

    def on_detach(self):
        self.scene.render_passes[self.source_pass].render_targets = None


class MainScene(Scene):

    def __init__(self):
        self.scene_transition = None
        self.camera.position = Vector.xy(0)
        self.root.add_child(
            Node(
                sprite=Sprite(PYTHON_IMAGE_PATH),
                shape=Polygon.from_box(Vector.xy(50))
            )
        )

    def on_enter(self):
        print(f'{self.__class__.__name__} on_enter')
        self.clear_color = Color(1, 0, 0, 1)

        transition = NodeTransitionsParallel([
            NodeTransition(Node.position, Vector(0, 0), 1.),
            NodeTransition(Node.color, Color(1., 1., 1., 1), 1.)
        ])
        self.scene_transition = self.root.add_child(
            SceneTransitionNode(
                resolution=Vector(800, 600), source_pass=0,
                target_pass=1, transition=transition,
                position=Vector(-800, 0), color=Color(1, 1, 1, 0),
            )
        )

    def change_scene(self):
        if self.scene_transition:
            return

        def _callback(node):
            self.engine.change_scene(SCENES['second'])

        transition = NodeTransitionsSequence([
            NodeTransitionsParallel([
                NodeTransition(Node.position, Vector(800, 0), 1.),
                NodeTransition(Node.color, Color(0, 0, 0, 0), 1.)
            ]),
            NodeTransitionCallback(_callback)
        ])

        self.scene_transition = self.root.add_child(
            SceneTransitionNode(
                resolution=Vector(800, 600), source_pass=0,
                target_pass=1, transition=transition
            )
        )

    def update(self, dt):
        for event in self.input.events():
            if event.keyboard_key and event.keyboard_key.is_key_down:
                if event.keyboard_key.key == Keycode.q:
                    self.engine.quit()
                elif event.keyboard_key.key == Keycode.c:
                    self.change_scene()

    def on_exit(self):
        print(f'{self.__class__.__name__} on_exit')


class SecondScene(Scene):

    def __init__(self):
        self.scene_transition = None
        self.camera.position = Vector.xy(0)
        self.root.add_child(
            Node(
                sprite=Sprite(PYTHON_IMAGE_PATH),
                shape=Polygon.from_box(Vector.xy(50))
            )
        )

    def on_enter(self):
        print(f'{self.__class__.__name__} on_enter')
        self.clear_color = Color(0, 1, 0, 1)

        transition = NodeTransitionsParallel([
            NodeTransition(Node.scale, Vector(1., 1.), 1.),
            NodeTransition(Node.rotation, math.pi * 2., 1.),
            NodeTransition(Node.color, Color(1., 1., 1., 1), 1.)
        ])
        self.scene_transition = self.root.add_child(
            SceneTransitionNode(
                resolution=Vector(800, 600), source_pass=0,
                target_pass=1, transition=transition,
                scale=Vector(0.01, 0.01), color=Color(1., 1., 1., 0),
            )
        )

    def change_scene(self):
        if self.scene_transition:
            return

        def _callback(node):
            self.engine.change_scene(SCENES['main'])

        transition = NodeTransitionsSequence([
            NodeTransitionsParallel([
                NodeTransition(Node.scale, Vector(0.01, 0.01), 1.),
                NodeTransition(Node.rotation, -math.pi * 2., 1.),
                NodeTransition(Node.color, Color(1., 1., 1., 0), 1.)
            ]),
            NodeTransitionCallback(_callback)
        ])

        self.scene_transition = self.root.add_child(
            SceneTransitionNode(
                resolution=Vector(800, 600), source_pass=0,
                target_pass=1, transition=transition
            )
        )

    def update(self, dt):
        for event in self.input.events():
            if event.keyboard_key and event.keyboard_key.is_key_down:
                if event.keyboard_key.key == Keycode.q:
                    self.engine.quit()
                elif event.keyboard_key.key == Keycode.c:
                    self.change_scene()

    def on_exit(self):
        print(f'{self.__class__.__name__} on_exit')


if __name__ == '__main__':
    with Engine(virtual_resolution=Vector(800, 600)) as engine:
        main_scene = MainScene()
        SCENES = {'main': main_scene, 'second': SecondScene()}
        engine.run(main_scene)
