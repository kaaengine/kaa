from kaa.engine import Engine, Scene
from kaa.geometry import Vector
from kaa.input import ControllerButton, ControllerAxis

class MyScene(Scene):

    def __init__(self):
        self.connected_controller_ids = []

    def update(self, dt):
        for event in self.input.events():

            if event.controller_device:
                if event.controller_device.is_added:
                    print('New controller connected: id is {}'.format(event.controller_device.id))
                    self.connected_controller_ids.append(event.controller_device.id)
                elif event.controller_device.is_removed:
                    print('Controller disconnected: id is {}'.format(event.controller_device.id))
                    self.connected_controller_ids.remove(event.controller_device.id)
            elif event.controller_axis:
                print('Controller axis {} at state {}'.format(str(event.controller_axis.axis), event.controller_axis.motion))

            if event.system and event.system.quit:
                self.engine.quit()

        # Check a few properties of each connected controller:
        for controller_id in self.connected_controller_ids:
            a_button_pressed = self.input.controller.is_pressed(ControllerButton.a, controller_id)
            b_button_pressed = self.input.controller.is_pressed(ControllerButton.b, controller_id)
            left_stick_x = self.input.controller.get_axis_motion(ControllerAxis.left_x, controller_id)
            left_stick_y = self.input.controller.get_axis_motion(ControllerAxis.left_y, controller_id)
            print('Controller {}. A pressed:{}, B pressed:{}, left stick pos: {},{}'.format(controller_id,
                a_button_pressed, b_button_pressed, left_stick_x, left_stick_y))


with Engine(virtual_resolution=Vector(400, 200)) as engine:
    scene = MyScene()
    engine.window.size = Vector(400, 200)
    engine.window.center()
    engine.run(scene)
