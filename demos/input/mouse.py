from kaa.engine import Engine, Scene
from kaa.geometry import Vector
from kaa.input import Keycode, ControllerButton, ControllerAxis

class MyScene(Scene):

    def __init__(self):
        self.connected_controller_ids = []

    def update(self, dt):
        for event in self.input.events():
            if event.mouse:
                if event.mouse.motion:
                    print("Mouse motion: {}. Pos is: {}. Scroll is: {}".format(event.mouse.motion, event.mouse.position, event.mouse.scroll))
                if event.mouse.wheel:
                    print("Mouse wheel: {}. Pos is: {}. Scroll is: {}".format(event.mouse.wheel, event.mouse.position, event.mouse.scroll))
                if event.mouse.button:
                    print("Mouse button: {}".format(event.mouse.button))

            if event.system and event.system.quit:
                self.engine.quit()


with Engine(virtual_resolution=Vector(400, 200)) as engine:
    scene = MyScene()
    engine.window.size = Vector(400, 200)
    engine.window.center()
    engine.run(scene)