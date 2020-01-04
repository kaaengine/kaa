from kaa.engine import Engine, Scene, get_engine
from kaa.input import Keycode, KeyboardEvent
from kaa.fonts import TextNode, Font
from kaa.geometry import Alignment, Vector


def handle_quit(event):
    if event.keyboard and event.keyboard.is_pressing(Keycode.q):
        get_engine().quit()
    return True

class FontDemoScene(Scene):
    def __init__(self):
        self.camera.position = Vector(0., 0.)
        self.my_font = Font("kaacore/demos/assets/fonts/Roboto/Roboto-Regular.ttf")

        self.text_node = TextNode(font=self.my_font, content="Hello World", font_size=1.)
        self.root.add_child(self.text_node)
        self.text_buffer = []
        self.input_manager.register_callback(KeyboardEvent.key, handle_quit)

    def update(self, dt):
        for event in self.input.events():
            keyboard = event.keyboard
            if keyboard:
                if keyboard.text_input:
                    self.text_buffer.append(keyboard.text)
                    print('Text: {}'.format(''.join(self.text_buffer)))
                elif keyboard.is_pressing(Keycode.backspace):
                    if self.text_buffer:
                        self.text_buffer.pop()
                        print('Text: {}'.format(''.join(self.text_buffer)))
                elif keyboard.is_pressing(Keycode.l):
                    self.text_node.content += "!"
                elif keyboard.is_pressing(Keycode.kp_7):
                    self.text_node.origin_alignment = Alignment.top_left
                elif keyboard.is_pressing(Keycode.kp_8):
                    self.text_node.origin_alignment = Alignment.top
                elif keyboard.is_pressing(Keycode.kp_9):
                    self.text_node.origin_alignment = Alignment.top_right
                elif keyboard.is_pressing(Keycode.kp_4):
                    self.text_node.origin_alignment = Alignment.left
                elif keyboard.is_pressing(Keycode.kp_5):
                    self.text_node.origin_alignment = Alignment.center
                elif keyboard.is_pressing(Keycode.kp_6):
                    self.text_node.origin_alignment = Alignment.right
                elif keyboard.is_pressing(Keycode.kp_1):
                    self.text_node.origin_alignment = Alignment.bottom_left
                elif keyboard.is_pressing(Keycode.kp_2):
                    self.text_node.origin_alignment = Alignment.bottom
                elif keyboard.is_pressing(Keycode.kp_3):
                    self.text_node.origin_alignment = Alignment.bottom_right
                elif keyboard.is_pressing(Keycode.w):
                    self.camera.position += Vector(0., -0.3)
                elif keyboard.is_pressing(Keycode.s):
                    self.camera.position += Vector(0., 0.3)
                elif keyboard.is_pressing(Keycode.a):
                    self.camera.position += Vector(-0.3, 0.)
                elif keyboard.is_pressing(Keycode.d):
                    self.camera.position += Vector(0.3, 0.)
                elif keyboard.is_pressing(Keycode.i):
                    self.camera.scale += Vector(0.05, 0.05)
                elif keyboard.is_pressing(Keycode.o):
                    self.camera.scale += Vector(-0.05, -0.05)
                elif keyboard.is_pressing(Keycode.r):
                    self.camera.rotation_degrees += 5.
                elif keyboard.is_pressing(Keycode.f):
                    self.camera.position = self.text_node.position


if __name__ == '__main__':
    with Engine(virtual_resolution=Vector(10, 10)) as engine:
        engine.window.show()
        engine.run(FontDemoScene())
