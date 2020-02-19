:mod:`fonts` --- Drawing text on screen
=======================================
.. module:: fonts
    :synopsis: Drawing text on screen

:class:`Font` reference
-----------------------

Constructor:

.. class:: Font(font_filepath)

    Font object is used to load a font from a file. Font objects are immutable.

    The Font constructor accepts just one parameter: :code:`font_filepath` which should be a string with a path to a font file.

    Kaa engine currently supports the following font file formats:

    * ttf

    .. code-block:: python

        import os
        from kaa.fonts import Font

        # .... somewhere inside a Scene ...
        font = Font(os.path.join('assets','fonts','DejaVuSans.ttf'))

:class:`TextNode` reference
---------------------------

Constructor:

.. class:: TextNode(font, text="", font_size=28.0, line_width=float("Inf"), interline_spacing=1.0, first_line_indent=0, position=Vector(0,0), rotation=0, scale=Vector(1, 1), z_index=0, color=Color(0,0,0,0), sprite=None, shape=None, origin_alignment=Alignment.center, lifetime=None, transition=None, visible=True)

    HitboxNode extends the :class:`nodes.Node` class to give you ability to comfortably work with text.

    In addition to all :class:`nodes.Node` params the TextNode constructor accepts the following ones:

    * :code:`font` - a :class:`Font` instance
    * :code:`font_size` - a number
    * :code:`line_width` - a number
    * :code:`interline_spacing` - a number
    * :code:`first_line_indent` - a number

    .. code-block:: python

        class MyScene(Scene):

            def __init__(self):
                font = Font(os.path.join('assets','fonts','DejaVuSans.ttf'))

                # a simple label
                simple_text = TextNode(font=font, text="Hello world", position=Vector(100, 100), font_size=30,
                                       origin_alignmnet=Alignment.left, color=Color(1,1,0,1), z_index=100)

                # a paragraph with a width of 300 and first line indent of 50. Words will wrap automatically
                wrapped_text = TextNode(font=font,
                                        text="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut dignissim, tellus "
                                             "sit amet ultrices facilisis, purus mi malesuada ante, sit amet ultricies erat "
                                             "mauris a turpis. Integer a elit sed mi mattis tincidunt. Pellentesque tristique "
                                             "semper cursus. Maecenas suscipit, ex quis condimentum consectetur, quam sapien "
                                             "placerat ex, eu aliquam est est condimentum mauris. ",
                                        position=Vector(500, 500), font_size=30,
                                        origin_alignmnet=Alignment.center, color=Color(1, 0, 0, 1), line_width=300,
                                        first_line_indent=50, z_index=101)

                self.root.add_child(simple_text)
                self.root.add_child(wrapped_text)

Instance properties

.. attribute:: TextNode.text

    Gets or sets a text to be rendered. A string.

    .. note::

        Updating text is relatively heavy operation in terms of performance so you should avoid doing it on each frame
        on a large number of nodes.


.. attribute:: TextNode.font_size

    Gets or sets the font size to be used when rendering the text. A number. Default is 28.

.. attribute:: TextNode.line_width

    Gets or sets the paragraph width. A number. Words will wrap automatically to fit the desired width. Default is
    infinite width.

.. attribute:: TextNode.interline_spacing

    Gets or sets the spacing between the lines of text in case of multiline texts.

.. attribute:: TextNode.first_line_indent

    Gets or sets the first line indentation in case of multiline texts.







