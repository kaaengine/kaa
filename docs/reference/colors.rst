:mod:`colors` --- Wrapper class for colors
==========================================
.. module:: colors
    :synopsis: Wrapper class for colors

:class:`Color` reference
------------------------

A ref to :class:`audio.Sound` here

A :class:`Color` represents a color in RGBA standard. Color is a property attribute of a :class:`nodes.Node` instance (and
instances of all its subclasses e.g. :class:`physics.BodyNode`, :class:`physics.BodyNode`, :class:`fonts.TextNode`
etc.).

Giving :class:`nodes.Node` tints this node's :class:`geometry.Shape` in that color. In case of text nodes it sets
the color of the text.

Constructor:

.. class:: Color(r=0.0, g=0.0, b=0.0, a=1.0)

   Parameters r, g, b and a are red, green, blue and alpha. They take values between 0 and 1.

Instance properties (read only):

.. attribute:: Color.r

    Returns red value

.. attribute:: Color.g

    Returns green value

.. attribute:: Color.b

    Returns blue value

.. attribute:: Color.a

    Returns blue value

Class methods:

.. classmethod:: Color.from_int(r=0, g=0, b=0, a=0)

    Allows to construct a :class:`Color` instance from integer parameters: r, g, b and a must be integers between
    0 and 255