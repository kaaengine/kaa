:mod:`nodes` --- Your objects on the scene
==========================================
.. module:: nodes
    :synopsis: Your objects on the scene


:class:`Node` reference
-----------------------

Nodes are main concept of the kaa engine. They're "objects" which you can add to the Scene. Each Node has properties
such as position, rotation or scale. A Node can have child Nodes which you can add with :meth:`Node.add_child`
method, thus creating a tree-like structure of nodes. As the parent node gets transformed (i.e. changes its position,
rotation or scale) all its children nodes will transform accordingly.

Each :class:`engine.Scene` instance has a root node - this is the first node on the Scene to which you can start adding
your own Nodes.

Nodes should not be confused with images (sprites). A Node may have a sprite (if you want it to be a graphical object),
but it doesn't have to. Sprite is basically a static or animated image, loaded from a graphics file. Refer to
:class:`sprite.Sprite` documentation for a full list of sprite features.

Until you set a Sprite for a node it will be just a logical entity on the scene, in other words: you won't see it. Such
logical Nodes are often very useful, for example, as a containers for grouping other nodes.

Kaa engine comes with a collection of specialized Nodes, which inherit from the base :class:`Node` class:

* :class:`physics.SpaceNode` - a container node to simulate the physical environment.
* :class:`physics.BodyNode` - a physical node which can have hitbox nodes. Can interact with other BodyNodes. Must be a direct child of SpaceNode. Can have zero or more Hitbox Nodes.
* :class:`physics.HitboxNode` - defines an area that will collide, and allows wiring up your own collision handler function. Hitbox Node must be a child node of a BodyNode.
* :class:`fonts.TextNode` - a node used to render text on the screen.

For your game's actual objects such as Player, Enemy, Bullet, etc. we recommend writing classes that inherit from
the Node class (or BodyNode if you want the object to utilize :doc:`kaaengine's physics features </reference/physics>`).

Nodes have other properties, such as z_index, shape, color, origin etc. All those concepts are described in the
documentation below.

.. class:: Node(position=Vector(0,0), rotation=0, scale=Vector(1, 1), z_index=0, color=Color(0,0,0,0), sprite=None, shape=None, origin_alignment=Alignment.center, lifetime=None, transition=None, visible=True)

    A basic example how to create a new Node (with a sprite) and add it to the Scene:

    .. code-block:: python

        from kaa.nodes import Node
        from kaa.sprites import Sprite
        from kaa.geometry import Vector
        import os

        # inside a Scene's __init__ :
        my_sprite = Sprite(os.path.join('assets', 'gfx', 'arrow.png')  # create a sprite from image file
        self.node = Node(position=Vector(100, 100), sprite=my_sprite))  # create a Node at (100, 100) with a sprite
        self.root.add_child(self.node)  # until you add a Node to the Scene it won't not show up on the screen!

Instance Properties:

.. _Node.scene:
.. attribute:: Node.scene

    Returns a :class:`Scene` instance to which this Node belongs. Will be None if the node wasn't added to any Scene yet.
    Use :meth:`Node.add_child` method to add nodes. Each Scene has a root node to which you can add nodes.

.. _Node.position:
.. attribute:: Node.position

    Gets or sets node position, as a :class:`geometry.Vector`.

    **IMPORTANT:** Node position is always relative to its parent node, it is not an "absolute" position on the Scene.
    It is illustrated by the example below:

    .. code-block:: python

        from kaa.nodes import Node
        from kaa.geometry import Vector

        # inside a Scene's __init__ :
        self.node1 = Node(position = Vector(100, 100))
        self.root.add_child(self.node1)  # adding to scene's root node, so node1 absolute position is (100, 100)
        # create another node
        self.node2 = Node(position = Vector(-20, 30))
        self.node1.add_child(self.node2)  # node2 absolute position is (80, 130) !

.. _Node.parent:
.. attribute:: Node.parent

    Retruns this node's parent :class:`Node`, or None in case of the root node.

.. _Node.type:
.. attribute:: Node.type

    Returns Node type. TODO: what is it?

.. _Node.z_index:
.. attribute:: Node.z_index

    Gets or sets node z_index (integer). Nodes with higher z_index will overlap those with lower z_index when drawn
    on the screen.

.. _Node.rotation:
.. attribute:: Node.rotation

    Gets or sets node rotation, in radians.

    Changing node rotation will make the node rotate around its origin point. Read more about
    :ref:`Node origin points <Node.origin_alignment>`.

    .. code-block:: python

        import math
        from kaa.nodes import Node
        from kaa.geometry import Vector

        # inside a Scene's __init__ :
        self.node1 = Node(position = Vector(100, 100), sprite=self.my_sprite)
        self.root.add_child(self.node1)
        self.node1.rotation = -math.pi / 4

.. _Node.rotation_degrees:
.. attribute:: Node.rotation_degrees

    Gets or sets node rotation, in degrees (as float).

    Changing node rotation will make the node rotate around its origin point. Read more about
    :ref:`Node origin points <Node.origin_alignment>`.

.. _Node.scale:
.. attribute:: Node.scale

    Gets or sets the node scale, as :class:`geometry.Vector`.

    .. code-block:: python

        import math
        from kaa.nodes import Node
        from kaa.geometry import Vector

        # inside a Scene's __init__ :
        self.node1 = Node(position = Vector(100, 100), sprite=self.my_sprite)
        self.root.add_child(self.node1)
        self.node1.scale = Vector(2, 0.5)  # stretch the node by a factor of 2 in the X axis and shrink it by a factor of 0.5 in the Y axis


.. _Node.visible:
.. attribute:: Node.visible

    TODO

.. _Node.color:
.. attribute:: Node.color

    TODO

.. _Node.sprite:
.. attribute:: Node.sprite

    TODO

.. _Node.shape:
.. attribute:: Node.shape

    TODO

.. _Node.origin_alignment:
.. attribute:: Node.origin_alignment

    TODO

.. _Node.lifetime:
.. attribute:: Node.lifetime

    TODO

.. _Node.transition:
.. attribute:: Node.transition

    TODO

Instance Methods:

.. method:: Node.add_child(child_node)

    TODO

.. method:: Node.delete()

    TODO