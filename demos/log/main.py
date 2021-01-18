from kaa.log import (
    get_core_logging_level, set_core_logging_level, CoreLogLevel,
)

from kaa.engine import Engine, Scene
from kaa.geometry import Vector

class MyScene(Scene):

    def update(self, dt):

        for event in self.input.events():

            if event.system and event.system.quit:
                self.engine.quit()

with Engine(virtual_resolution=Vector(400, 200)) as engine:
    scene = MyScene()
    engine.window.size = Vector(400, 200)
    engine.window.center()

    print(get_core_logging_level("renderer"))

    engine.run(scene)
