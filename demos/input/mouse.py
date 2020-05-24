from kaa.engine import Engine, Scene
from kaa.geometry import Vector
from kaa.input import Keycode, ControllerButton, ControllerAxis

class MyScene(Scene):

    def __init__(self):
        self.connected_controller_ids = []

    def update(self, dt):
        for event in self.input.events():
            if event.mouse_motion:
                print(
                    "Mouse motion occurred. New pos is: {}, relative pos is {}".format(
                        event.mouse_motion.position, event.mouse_motion.motion
                    )
                )
            elif event.mouse_wheel:
                print("Mouse wheel event ocurred: Wheel scrolled by {}".format(event.mouse_wheel.scroll))
            elif event.mouse_button:
                print("Mouse button event ocurred. Button={}, is down={}, is up={}".format(
                    str(event.mouse_button.button), event.mouse_button.is_button_down, event.mouse_button.is_button_up))
            elif event.keyboard_key:
                if event.keyboard_key.key_down == Keycode.c:
                    self.input.mouse.relative_mode = not self.input.mouse.relative_mode

            if event.system and event.system.quit:
                self.engine.quit()


with Engine(virtual_resolution=Vector(400, 200)) as engine:
    scene = MyScene()
    engine.window.size = Vector(400, 200)
    engine.window.center()
    engine.run(scene)