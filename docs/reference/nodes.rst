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

Nodes should not be confused with images (sprites). A Node may have a sprite. Sprite is basically a static
or animated image, loaded from a graphics file. Refer to :class:`sprite.Sprite` documentation for a full list of sprite
features.

Until you set a Sprite for a node it will be just a logical entity on the scene, in other words: you won't see it. Such
logical Nodes are often very useful, for example, acting as a containers for grouping other nodes.

Kaa engine comes with a collection of specialized Nodes, which inherit from the base :class:`Node` class. Examples of such
specialized nodes include:

* :class:`physics.SpaceNode` - a container node to simulate the physical environment.
* :class:`physics.BodyNode` - a physical node which can have hitbox nodes. Can interact with other BodyNodes. Must be a child of SpaceNode.
* :class:`physics.HitboxNode` - must be a child node of a BodyNode, defines an area that will collide. You can write your own collision handlers too.
* :class:`fonts.TextNode` - a node used to render text on the screen.

For your game's actual, visible objects such as Player, Enemy, Bullet, etc. we recommend writing classes that inherit from
the Node class or BodyNode if you want the object to utilize kaaengine's physics features.

Nodes have other properties, such as z_index, shape, color, origin etc. All those concepts are described in the
documentation below.

.. class:: Node(position=Vector(0,0), rotation=0, scale=Vector(1, 1), z_index=0, visible=True, color=Color(0,0,0,0), sprite=None, shape=None, origin_alignment=Alignment.center, lifetime=None, transition=None)

    None of the Node properties are required.

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

.. attribute:: Node.scene

    Returns a :class:`Scene` instance to which this Node belongs. Will be None if the node wasn't added to any Scene yet.
    Use :meth:`Node.add_child` method to add nodes. Each Scene has a root node to which you can add nodes.

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


.. attribute:: Node.z_index

    TODO

.. attribute:: Node.rotation

    TODO

.. attribute:: Node.rotation_degrees

    TODO

.. attribute:: Node.scale

    TODO

.. attribute:: Node.offset

    TODO

.. attribute:: Node.transformation_offset

    TODO

.. attribute:: Node.visible

    TODO

.. attribute:: Node.color

    TODO

.. attribute:: Node.track_position

    TODO

.. attribute:: Node.sprite

    TODO

.. attribute:: Node.shape

    TODO

.. attribute:: Node.origin_alignment

    TODO

.. attribute:: Node.lifetime

    TODO

.. attribute:: Node.transition

    TODO

.. attribute:: Node.width

    TODO

.. attribute:: Node.height

    TODO

Instance Methods:

.. method:: Node.add_child(child_node)

    TODO

.. method:: Node.delete()

    TODO