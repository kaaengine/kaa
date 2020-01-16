Kaa engine Reference
====================

.. toctree::
    :maxdepth: 2
    :caption: Full kaa reference:

    audio
    colors
    engine
    geometry
    input
    log
    nodes
    physics

All kaa imports cheat sheet
---------------------------

.. code-block:: python

    from kaa.audio import Sound, Music

    from kaa.colors import Color

    from kaa.engine import Engine, Scene, VirtualResolutionMode, get_engine

    from kaa.fonts import Font, TextNode

    from kaa.geometry import Vector, Segment, Circle, Polygon, PolygonType, Alignment, classify_polygon

    from kaa.input import Keycode, MouseButton, ControllerButton, ControllerAxis, Event, SystemEvent, WindowEvent,
        KeyboardEvent, MouseEvent, ControllerEvent

    from kaa.log import get_core_logging_level, set_core_logging_level, CoreLogLevel, CoreLogCategory, CoreHandler,

    from kaa.nodes import Node

    from kaa.physics import SpaceNode, BodyNode, HitboxNode, BodyNodeType, CollisionPhase

    from kaa.renderer import Renderer

    from kaa.sprites import Sprite

    from kaa.timers import Timer

    from kaa.transitions import NodeTransitionsSequence, NodeTransitionsParallel, NodeCustomTransition,
        AttributeTransitionMethod, NodePositionTransition, NodeRotationTransition, NodeScaleTransition,
        NodeColorTransition, BodyNodeVelocityTransition, BodyNodeAngularVelocityTransition, NodeTransitionDelay,
        NodeTransitionCallback








