import os

from kaa.engine import Engine, Scene
from kaa.fonts import TextNode, Font
from kaa.geometry import Alignment, Vector
from kaa.input import Keycode, ControllerButton, ControllerAxis
from kaa.nodes import Node

class ControllerStatsContainer(Node):

    def __init__(self, slot_index, font, controller_id, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.font = font
        self.slot_index = slot_index
        self.controller_id = controller_id
        self.events_count = 0

        self.controller_id_txt = TextNode(font=self.font, font_size=16, origin_alignment=Alignment.top_left,
                                position=Vector(0, 0))
        self.pressed_buttons_txt = TextNode(font=self.font, font_size=16, origin_alignment=Alignment.top_left,
                                            position=Vector(0, 20))
        self.axis_txt = TextNode(font=self.font, font_size=16, origin_alignment=Alignment.top_left,
                                 position=Vector(0, 40), text="AXIS STATUS:")
        self.axis_left_x_txt = TextNode(font=self.font, font_size=16, origin_alignment=Alignment.top_left,
                                 position=Vector(20, 60))
        self.axis_left_y_txt = TextNode(font=self.font, font_size=16, origin_alignment=Alignment.top_left,
                                 position=Vector(20, 80))
        self.axis_right_x_txt = TextNode(font=self.font, font_size=16, origin_alignment=Alignment.top_left,
                                 position=Vector(20, 100))
        self.axis_right_y_txt = TextNode(font=self.font, font_size=16, origin_alignment=Alignment.top_left,
                                 position=Vector(20, 120))
        self.axis_right_trigger_txt = TextNode(font=self.font, font_size=16, origin_alignment=Alignment.top_left,
                                 position=Vector(20, 140))
        self.axis_left_trigger_txt = TextNode(font=self.font, font_size=16, origin_alignment=Alignment.top_left,
                                 position=Vector(20, 160))
        self.events_logged_txt = TextNode(font=self.font, font_size=16, origin_alignment=Alignment.top_left,
                                 position=Vector(0, 180), text="")

        self.add_child(self.controller_id_txt)
        self.add_child(self.pressed_buttons_txt)
        self.add_child(self.axis_txt)
        self.add_child(self.axis_left_x_txt)
        self.add_child(self.axis_left_y_txt)
        self.add_child(self.axis_right_x_txt)
        self.add_child(self.axis_right_y_txt)
        self.add_child(self.axis_right_trigger_txt)
        self.add_child(self.axis_left_trigger_txt)
        self.add_child(self.events_logged_txt)



    def get_label_for_axes(self, controller_axes):
        if controller_axes == ControllerAxis.left_y:
            return self.axis_left_y_txt
        elif controller_axes == ControllerAxis.left_x:
            return self.axis_left_x_txt
        elif controller_axes == ControllerAxis.right_x:
            return self.axis_right_x_txt
        elif controller_axes == ControllerAxis.right_y:
            return self.axis_right_y_txt
        elif controller_axes == ControllerAxis.trigger_left:
            return self.axis_left_trigger_txt
        elif controller_axes == ControllerAxis.trigger_right:
            return self.axis_right_trigger_txt

    def update(self):
        if self.controller_id is not None:
            name = self.scene.input.controller.get_name(self.controller_id)
            self.controller_id_txt.text = f"Controller ID: {self.controller_id}, name: {name}"
            pressed_buttons = []
            for cb in list(ControllerButton):
                if self.scene.input.controller.is_pressed(cb, self.controller_id):
                    pressed_buttons.append(str(cb))
            self.pressed_buttons_txt.text = "Pressed buttons: {}".format(",".join(pressed_buttons))

            for axes in list(ControllerAxis):
                axes_label = str(axes).split(".")[1]
                motion = self.scene.input.controller.get_axis_motion(axes, self.controller_id)
                is_pressed = self.scene.input.controller.is_axis_pressed(axes, self.controller_id)
                is_released = self.scene.input.controller.is_axis_released(axes, self.controller_id)
                label = f"{axes_label}: {motion}, pressed: {is_pressed}, released: {is_released}"
                self.get_label_for_axes(axes).text = label


    def log_event(self, controller_event):
        self.events_count += 1
        self.events_logged_txt.text = f"EVENTS LOGGED: {self.events_count}"


class ControllerSlotInfoNode(Node):

    def __init__(self, slot_index, font, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.font = font
        self.slot_index = slot_index
        self.status_label = TextNode(font=self.font, font_size=16, origin_alignment=Alignment.top_left,
                                position=Vector(0, 0), text=f"Controller #{slot_index} not connected. Please connect a controller.")
        self.add_child(self.status_label)
        self.controller_stats_container = ControllerStatsContainer(slot_index, font, None, position=Vector(0,20))
        self.add_child(self.controller_stats_container)
        self.controller_stats_container.visible=False

    def on_controller_connected(self, controller_event):
        self.status_label.text = f"Controller #{self.slot_index} connected!"
        self.controller_stats_container.controller_id = controller_event.id
        self.controller_stats_container.visible = True

    def on_controller_disconnected(self):
        self.status_label.text = f"Controller #{self.slot_index} not connected. Please connect a controller."
        self.controller_stats_container.controller_id = None
        self.controller_stats_container.visible = False

    def update(self):
        self.controller_stats_container.update()


class MyScene(Scene):

    def __init__(self):
        self.font = Font(os.path.join('demos', 'assets', 'fonts', 'DejaVuSans.ttf'))
        self.controller_id_to_slot_index = {}  # key = controller id, value = index, between 0 to 3 indicating controller "slot"
        self.slot_nodes = []

        for i in range(0, 4):
            if i == 0:
                pos = Vector(10, 10)
            elif i == 1:
                pos = Vector(910, 10)
            elif i == 2:
                pos = Vector(10, 460)
            elif i == 3:
                pos = Vector(910, 460)
            controller_slot_info_node = ControllerSlotInfoNode(i, self.font, position=pos)
            self.slot_nodes.append(controller_slot_info_node)
            self.root.add_child(controller_slot_info_node)

    def find_lowest_controller_slot_index(self):
        slots = sorted(self.controller_id_to_slot_index.values())
        for i in range(0, 4):
            if i not in slots:
                return i
        raise Exception("This demo can handle max 4 connected controllers, and a fifth controller was connected...")

    def on_controller_connected(self, controller_event):
        slot_index = self.find_lowest_controller_slot_index()
        self.controller_id_to_slot_index[controller_event.id]=slot_index
        self.slot_nodes[slot_index].on_controller_connected(controller_event)
        print('Controller id {} assigned to slot {}'.format(controller_event.id, slot_index))

    def on_controller_disconnected(self, controller_event):
        slot_index = self.controller_id_to_slot_index[controller_event.id]
        self.slot_nodes[slot_index].on_controller_disconnected()
        del self.controller_id_to_slot_index[controller_event.id]

    def log_controller_event(self, controller_event):
        slot_index = self.controller_id_to_slot_index[controller_event.id]
        self.slot_nodes[slot_index].controller_stats_container.log_event(controller_event)

    def update(self, dt):

        for event in self.input.events():
            if event.keyboard_key :
                if event.keyboard_key.is_key_down(Keycode.q):
                    self.engine.quit()

            if event.controller_device:
                if event.controller_device.is_added:
                    self.on_controller_connected(event.controller_device)
                elif event.controller_device.is_removed:
                    self.on_controller_disconnected(event.controller_device)
                else:
                    self.log_controller_event(event.controller_device)

            if event.system and event.system.quit:
                self.engine.quit()

        # update the labels for all four controllers
        for i in range(0, 4):
            self.slot_nodes[i].update()


with Engine(virtual_resolution=Vector(1800, 900)) as engine:
    scene = MyScene()
    engine.window.size = Vector(1800, 900)
    engine.window.center()
    engine.run(scene)
