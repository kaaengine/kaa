import itertools
from kaa.colors import Color

from kaa.engine import Engine, Scene
from kaa.fonts import TextNode
from kaa.geometry import Alignment, Circle, Polygon, Vector
from kaa.nodes import Node
from kaa.input import Keycode
from kaa.stencil import StencilMode, StencilTest, StencilOp
from kaa.transitions import AttributeTransitionMethod, NodePositionTransition


SAMPLE_TEXT = """
Beautiful is better than ugly.
Explicit is better than implicit.
Simple is better than complex.
Complex is better than complicated.
Flat is better than nested.
Sparse is better than dense.
Readability counts.
Special cases aren't special enough to break the rules.
Although practicality beats purity.
Errors should never pass silently.
Unless explicitly silenced.
In the face of ambiguity, refuse the temptation to guess.
There should be one-- and preferably only one --obvious way to do it.
Although that way may not be obvious at first unless you're Dutch.
Now is better than never.
Although never is often better than *right* now.
If the implementation is hard to explain, it's a bad idea.
If the implementation is easy to explain, it may be a good idea.
Namespaces are one honking great idea -- let's do more of those!
""".strip()

class StencilDemoScene(Scene):
    def __init__(self):
        self.frame_shapes_gen = itertools.cycle([
            Polygon.from_box(Vector(600, 400)),
            Circle(230.),
            Polygon([Vector(0, -200), Vector(350, 200), Vector(-350, 200)]),
        ])

        self.camera.position = Vector(0., 0.)
        self.frame_node = self.root.add_child(
            Node(
                position=Vector(0, 0),
                shape=next(self.frame_shapes_gen),
                color=Color(1., 0., 0., 0.2),
                stencil_mode=StencilMode(
                    value=42, test=StencilTest.always, pass_op=StencilOp.replace,
                ),
            )
        )
        self.text_node = self.root.add_child(
            TextNode(
                position=Vector(0, 400),
                font_size=21.,
                text=SAMPLE_TEXT,
                line_width=600,
                transition=NodePositionTransition(
                    Vector(0, -800), duration=15.,
                    advance_method=AttributeTransitionMethod.add, loops=0,
                ),
                stencil_mode=StencilMode(
                    value=42, test=StencilTest.equal,
                ),
            )
        )
        self.help_node = self.root.add_child(
            TextNode(
                position=Vector(-380, -280),
                origin_alignment=Alignment.top_left,
                text="Stencil Demo, keys:\nC - Toggle frame shape",
            )
        )

    def cycle_frame_shape(self):
        self.frame_node.shape = next(self.frame_shapes_gen)

    def update(self, dt: float):
        for event in self.input.events():
            if event.keyboard_key:
                if event.keyboard_key.key_down == Keycode.Q:
                    self.engine.quit()
                if event.keyboard_key.key_down == Keycode.C:
                    self.cycle_frame_shape()

if __name__ == '__main__':
    with Engine(virtual_resolution=Vector(800, 600)) as engine:
        engine.window.size = Vector(800, 600)
        engine.run(StencilDemoScene())
