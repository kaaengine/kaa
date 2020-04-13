import os
from kaa.sprites import Sprite
from kaa.engine import Engine, Scene
from kaa.geometry import Vector
from kaa.nodes import Node

class MyScene(Scene):

    def __init__(self):
        self.root.add_child(Node(position=Vector(100, 100),
                                 sprite=Sprite(os.path.join('demos', 'assets', 'python_small.png'))))

    def update(self, dt):

        for event in self.input.events():
            if event.system and event.system.quit:
                self.engine.quit()

with Engine(virtual_resolution=Vector(400, 200)) as engine:
    scene = MyScene()
    engine.window.size = Vector(400, 200)
    engine.window.center()

    engine.run(scene)