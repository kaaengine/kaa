from kaa.engine import Engine, Scene
from kaa.input import Keycode
from kaa.fonts import TextNode, Font
from kaa.geometry import Alignment


class FontDemoScene(Scene):
    def __init__(self):
        self.my_font = Font("kaacore/demos/assets/fonts/Roboto/Roboto-Regular.ttf")

        self.text_node = TextNode(font=self.my_font, content="Hello World", font_size=1.)
        self.root.add_child(self.text_node)

    def update(self, dt):
        for event in self.input.events():
            if event.is_quit():
                self.engine.quit()
            elif event.is_pressing(Keycode.q):
                self.engine.quit()
            elif event.is_pressing(Keycode.l):
                self.text_node.content += "!"
            elif event.is_pressing(Keycode.kp_7):
                self.text_node.origin_alignment = Alignment.top_left
            elif event.is_pressing(Keycode.kp_8):
                self.text_node.origin_alignment = Alignment.top
            elif event.is_pressing(Keycode.kp_9):
                self.text_node.origin_alignment = Alignment.top_right
            elif event.is_pressing(Keycode.kp_4):
                self.text_node.origin_alignment = Alignment.left
            elif event.is_pressing(Keycode.kp_5):
                self.text_node.origin_alignment = Alignment.center
            elif event.is_pressing(Keycode.kp_6):
                self.text_node.origin_alignment = Alignment.right
            elif event.is_pressing(Keycode.kp_1):
                self.text_node.origin_alignment = Alignment.bottom_left
            elif event.is_pressing(Keycode.kp_2):
                self.text_node.origin_alignment = Alignment.bottom
            elif event.is_pressing(Keycode.kp_3):
                self.text_node.origin_alignment = Alignment.bottom_right

        print("Mouse position: {}".format(self.input.get_mouse_position()))


if __name__ == '__main__':
    engine = Engine()
    engine.window.show()
    engine.run(FontDemoScene())

    print(" * Deleting engine")
    del engine
    print(" * Ending script")
