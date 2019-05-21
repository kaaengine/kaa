from kaa.engine import Engine, Scene
from kaa.nodes import Node
from kaa.geometry import Vector
from kaa.input import Keycode
from kaa.fonts import TextNode, Font


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

        print("Mouse position: {}".format(self.input.get_mouse_position()))


if __name__ == '__main__':
    engine = Engine()
    engine.window.show()
    engine.run(FontDemoScene())

    print(" * Deleting engine")
    del engine
    print(" * Ending script")
