from kaa.engine import Engine, Scene, get_engine
from kaa.input import Event, Keycode
from kaa.fonts import TextNode, Font
from kaa.geometry import Alignment, Vector


def handle_quit(event):
    if event.keyboard_key.key == Keycode.q:
        get_engine().quit()
    return True

class FontDemoScene(Scene):
    def __init__(self):
        self.camera.position = Vector(0., 0.)
        self.my_font = Font("kaacore/demos/assets/fonts/Roboto/Roboto-Regular.ttf")

        self.text_node = TextNode(font=self.my_font, content="Hello World", font_size=1.)
        self.root.add_child(self.text_node)
        self.text_buffer = []
        self.input_manager.register_callback(Event.keyboard_key, handle_quit)

    def update(self, dt):
        for event in self.input.events():
            if event.keyboard_text:
                self.text_buffer.append(event.keyboard_text.text)
                print('Text: {}'.format(''.join(self.text_buffer)))
            elif event.keyboard_key and event.keyboard_key.is_key_down:
                if event.keyboard_key.key == Keycode.backspace:
                    if self.text_buffer:
                        self.text_buffer.pop()
                        print('Text: {}'.format(''.join(self.text_buffer)))
                elif event.keyboard_key.key == Keycode.l:
                    self.text_node.content += "!"
                elif event.keyboard_key.key == Keycode.kp_7:
                    self.text_node.origin_alignment = Alignment.top_left
                elif event.keyboard_key.key == Keycode.kp_8:
                    self.text_node.origin_alignment = Alignment.top
                elif event.keyboard_key.key == Keycode.kp_9:
                    self.text_node.origin_alignment = Alignment.top_right
                elif event.keyboard_key.key == Keycode.kp_4:
                    self.text_node.origin_alignment = Alignment.left
                elif event.keyboard_key.key == Keycode.kp_5:
                    self.text_node.origin_alignment = Alignment.center
                elif event.keyboard_key.key == Keycode.kp_6:
                    self.text_node.origin_alignment = Alignment.right
                elif event.keyboard_key.key == Keycode.kp_1:
                    self.text_node.origin_alignment = Alignment.bottom_left
                elif event.keyboard_key.key == Keycode.kp_2:
                    self.text_node.origin_alignment = Alignment.bottom
                elif event.keyboard_key == Keycode.kp_3:
                    self.text_node.origin_alignment = Alignment.bottom_right
                elif event.keyboard_key.key == Keycode.w:
                    self.camera.position += Vector(0., -0.3)
                elif event.keyboard_key.key == Keycode.s:
                    self.camera.position += Vector(0., 0.3)
                elif event.keyboard_key.key == Keycode.a:
                    self.camera.position += Vector(-0.3, 0.)
                elif event.keyboard_key.key == Keycode.d:
                    self.camera.position += Vector(0.3, 0.)
                elif event.keyboard_key.key == Keycode.i:
                    self.camera.scale += Vector(0.05, 0.05)
                elif event.keyboard_key.key == Keycode.o:
                    self.camera.scale += Vector(-0.05, -0.05)
                elif event.keyboard_key.key == Keycode.r:
                    self.camera.rotation_degrees += 5.
                elif event.keyboard_key.key == Keycode.f:
                    self.camera.position = self.text_node.position


if __name__ == '__main__':
    with Engine(virtual_resolution=Vector(10, 10)) as engine:
        engine.window.show()
        engine.run(FontDemoScene())
