Part 7: Drawing text
====================

In this chapter we'll lear how to draw text in the game

Loading fonts from files
~~~~~~~~~~~~~~~~~~~~~~~~

In order to draw a text, we must first load a font from a file. Like with images or sounds, it's very easy:

.. code-block:: python

    from kaa.fonts import Font
    my_font = Font('/path/to/font.ttf')

Font formats currently supported by kaa:

* ttf

Drawing text
~~~~~~~~~~~~

To draw a text, create a :code:`TextNode` and add it to the scene. :code:`TextNode` extends
basic :code:`Node` and therefore inherits all its properties - position, rotation, scale, color, origin_alignment etc.
It adds the following new properties:

* :code:`font` - A font to use when rendering text. Pass a :code:`Font` instance.
* :code:`text` - a string. A text you want to draw.
* :code:`font_size` - an integer. Size of the text.
* :code:`line_width` - an integer. Width of the text, in pixels. If set, the text will wrap automatically to fit this width. If not set, text won't wrap.
* :code:`interline_spacing` - an integer. Space between lines of text in pixels. Used when the text wraps (due to line_width).
* :code:`first_line_indent` - an integer. Indentation for the first line. Useful when you have multiple line texts (due to line_width)

Full example
~~~~~~~~~~~~

Let's load a font from file and add some texts in the game.

.. code-block:: python
    :caption: controllers/assets_controller.py

    from kaa.fonts import Font

    class AssetsController:

        def __init__(self):
            # ... the rest of the function .....

            # Load all fonts
            self.font_1 = Font(os.path.join('assets', 'fonts', 'paladise-script.ttf'))
            self.font_2 = Font(os.path.join('assets', 'fonts', 'DejaVuSans.ttf'))


.. code-block:: python
    :caption: scenes/gameplay.py

    import registry
    import settings
    from kaa.geometry import Vector, Alignment
    from kaa.fonts import TextNode
    from kaa.colors import Color

    class GameplayScene(Scene):

        def __init__(self):
            super().__init__()
            self.frag_count = 0
            self.root.add_child(TextNode(font=registry.global_controllers.assets_controller.font_1,
                                origin_alignment=Alignment.left, position=Vector(10, 20), font_size=40, z_index=1,
                                text="WASD to move, mouse to rotate, left mouse button to shoot"))
            self.root.add_child(TextNode(font=registry.global_controllers.assets_controller.font_1,
                                origin_alignment=Alignment.left, position=Vector(10, 45), font_size=40, z_index=1,
                                text="1, 2, 3 - change weapons. SPACE - spawn enemy"))
            self.root.add_child(TextNode(font=registry.global_controllers.assets_controller.font_2,
                                origin_alignment=Alignment.right, position=Vector(1910, 20), font_size=30, z_index=1,
                                color=Color(1, 0, 0, 1), text="Press Q to quit game"))
            self.frag_count_label = TextNode(font=registry.global_controllers.assets_controller.font_1,
                                origin_alignment=Alignment.left, position=Vector(10, 70), font_size=40, z_index=1,
                                color=Color(1, 1, 0, 1), text="")
            self.root.add_child(self.frag_count_label)
            # .... rest of the code

        def score_frag(self):
            # function for tracking frag count
            self.frag_count += 1
            self.frag_count_label.text = f"Frag Count: {self.frag_count}"

Run the game and check out the results!

.. note::

    When adding :code:`TextNode` to the scene it's important to give them proper :code:`z_index`. Games will usually
    have some background image and you may often be wondering "why is that TextNode not visible"? Most likely it's
    because of :code:`z_index` being too low and some other sprite is rendering in front of it!

Updating text
~~~~~~~~~~~~~

Updating text property of the :code:`TextNode` is a performance-heavy operation and you should avoid updating
:code:`text` property on each frame (unless it's really needed). In our case, we only need to update
the frag count when an enemy is killed. We've already written a :code:`score_frag` function, let's now call it:

.. code-block:: python
    :caption: controllers/enemies_controller.py

    class EnemiesController:

        def remove_enemy(self, enemy):
            self.enemies.remove(enemy)  # remove from the internal list
            enemy.delete()  # remove from the scene
            # increment the frag counter
            self.scene.score_frag()


Transforming text
~~~~~~~~~~~~~~~~~

Since text nodes are regular Nodes, you can use all of base :code:`Node` properties to transform them, e.g. reposition,
rotate, scale, etc.

.. code-block:: python

    my_text_node.rotation_degrees = 45
    my_text_node.scale = Vector(0.5, 0.75)

Text Nodes can also be a child nodes of other nodes, and can have child nodes themselves.

.. code-block:: python

    tn = TextNode(font = my_font, text="Hello world")
    tn.add_child(Node(sprite=my_sprite))


Let's move on, :doc:`to the next part of the tutorial </tutorial/part08>`