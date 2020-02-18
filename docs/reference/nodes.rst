:mod:`nodes` --- Your objects on the scene
==========================================
.. module:: nodes
    :synopsis: Your objects on the scene


:class:`Node` reference
-----------------------

Nodes are main concept of the kaa engine. They're "objects" which you can add to the Scene. Each Node has its
spatial properties such as position, rotation or scale. A Node may also have a sprite (graphics loaded from a file)
and can be animated. Nodes have other properties such as z_index, shape, color, origin etc. All those attributes are
described in the documentation below.

A Node can have child Nodes, which you can add with the :meth:`Node.add_child`
method, thus creating a tree-like structure of nodes on the scene. As the parent node gets transformed (changes its position,
rotation or scale) all its children nodes will transform accordingly.

Each :class:`engine.Scene` instance has a root node - this is the first node on the Scene to which you can start adding
your own Nodes.

A node without a sprite image (or without a shape and color properties set explicitly) will be just a logical entity
on the scene, in other words: you won't see it. Such logical Nodes are often very useful, for example, as a containers
for grouping other nodes.

Although the bare :class:`Node` will do its job well and allow you to create simple games, the Kaa engine comes with
a collection of other specialized Nodes (they all inherit from the :class:`Node` class):

* :class:`physics.SpaceNode` - a container node to simulate the physical environment.
* :class:`physics.BodyNode` - a physical node which can have hitbox nodes. Can interact with other BodyNodes. Must be a direct child of SpaceNode. Can have zero or more Hitbox Nodes.
* :class:`physics.HitboxNode` - defines an area that will collide, and allows wiring up your own collision handler function. Hitbox Node must be a child node of a BodyNode.
* :class:`fonts.TextNode` - a node used to render text on the screen.

For your game's actual objects such as Player, Enemy, Bullet, etc. we recommend writing classes that inherit from
the Node class (or BodyNode if you want the object to utilize :doc:`kaaengine's physics features </reference/physics>`).


.. class:: Node(position=Vector(0,0), rotation=0, scale=Vector(1, 1), z_index=0, color=Color(0,0,0,0), sprite=None, shape=None, origin_alignment=Alignment.center, lifetime=None, transition=None, visible=True)

    A basic example how to create a new Node (with a sprite) and add it to the Scene:

    .. code-block:: python

        from kaa.nodes import Node
        from kaa.sprites import Sprite
        from kaa.geometry import Vector
        import os

        # inside a Scene's __init__ :
        my_sprite = Sprite(os.path.join('assets', 'gfx', 'arrow.png')  # create a sprite from image file
        self.node = Node(position=Vector(100, 100), sprite=my_sprite))  # create a Node at (100, 100) with the sprite
        self.root.add_child(self.node)  # until you add the Node to the Scene it won't not show up on the screen!

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

    Also see: :ref:`Node origin points <Node.origin_alignment>`.

.. _Node.parent:
.. attribute:: Node.parent

    Retruns this node's parent :class:`Node`, or None in case of the root node.

.. _Node.z_index:
.. attribute:: Node.z_index

    Gets or sets node z_index (integer). Nodes with higher z_index will overlap those with lower z_index when drawn
    on the screen.

.. _Node.rotation:
.. attribute:: Node.rotation

    Gets or sets node rotation, in radians. There is no capping value, meaning you can set it to values greater
    than :code:`math.pi*2` or lower than :code:`-math.pi*2`.

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

    Gets or sets node rotation, in degrees (as float). There is no capping value, meaning you can set it to values greater
    than 360 degrees or smaller than -360 degrees.

    Changing node rotation will make the node rotate around its origin point. Read more about
    :ref:`Node origin points <Node.origin_alignment>`.

.. _Node.scale:
.. attribute:: Node.scale

    Gets or sets the node scale, as :class:`geometry.Vector`. X value of the vector is used to scale the node in the
    X axis, while Y value is used to scale it in the Y axis. Negative value of X or Y is possible - it will make
    the node to be rendered as a mirror reflection in X and/or Y axis respectively.

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

    Gets or sets the visibility of the node (shows or hides it), using bool.

    Makes most sense for nodes which are rendered on the screen such as nodes having sprites, or text nodes.

    Note that this has only a visual effect, so for example setting :code:`visible` to :code:`False` on a
    :class:`physics.HitboxNode` will not make the hitbox inactive - it will still detect collisions normally.

    Setting visible to :code:`False` will hide all of its child nodes (recursively) as well.

.. _Node.sprite:
.. attribute:: Node.sprite

    Gets or sets a :class:`sprites.Sprite` for the node.

    A sprite is an immutable object that represents a graphical image, which can have one or more frames.
    Rrefer to :class:`sprites.Sprite` documentation for more information.

    Assigning a Sprite to a Node will make the sprite be displayed at node's position, with node's rotation and scale.

    Since sprite is a dimensional object (has its width and height) and node position is just a 2D (x, y) coords,
    it is important to understand the concept of node's origin point. Read more
    about :ref:`Node origin points <Node.origin_alignment>`.

    .. code-block:: python

        from kaa.nodes import Node
        from kaa.sprites import Sprite
        from kaa.geometry import Vector, Alignment
        import os

        # inside a Scene's __init__ :
        my_sprite = Sprite(os.path.join('assets', 'gfx', 'arrow.png')  # create a sprite from image file
        self.node = Node(position=Vector(100, 100), sprite=my_sprite))  # create a Node at (100, 100) with the sprite
        self.node.origin_alignment = Alignment.center # this makes the (100, 100) position be at the center of the sprite
        self.root.add_child(self.node)  # until you add the Node to the Scene it won't not show up on the screen!

.. _Node.color:
.. attribute:: Node.color

    Gets or sets the color of the shape of the node, using :class:`colors.Color`.

    In practice, if a node has a sprite that means that a sprite will be tinted in that color.

    If a node does not have a sprite it still can have a shape (see the :ref:`shape <Node.shape>` property).
    In that case setting a color will make the shape be rendered in that color.

    For text nodes (:class:`fonts.TextNode`) it gets or sets the color of the text.

    It is often useful to set a color for hitbox nodes (:class:`physics.HitboxNode`) to see where the hitboxes are in
    relation to the node's sprite. Just remember to set a high enough z_index on the hitbox node.

    The default color of a Node is a "transparent" color (r=0, g=0, b=0, a=0).

.. _Node.shape:
.. attribute:: Node.shape

    Gets or sets a shape of a Node. A shape can be one of the following types:

    * :code:`None` - this is the default value (no shape)
    * :class:`geometry.Circle` - the shape has a form of a circle
    * :class:`geometry.Polygon` - the shape has a form of a polygon.

    The most common scenario for setting a shape manually is for the hitbox nodes (:class:`physics.HitboxNode`). It
    defines an area that will generate collisions. More information is available in the
    :doc:`physics module documentation </reference/physics>`).

    If you set a Sprite for a Node, its shape will be automatically set to a rectangular polygon corresponding with the
    size of the sprite. If Sprite is animated (has many frames) node's shape dimensions will be of a single frame.

    Overriding sprite node's shape is usually not necessary, but you can always do that. For example, you can set
    a 100x200 px sprite for a node and then set a custom shape e.g. a non-rectangular polygon or a circle.
    The drawn image will be fit inside a defined shape.

.. _Node.origin_alignment:
.. attribute:: Node.origin_alignment

    Gets or sets origin alignment of a node, as :class:`geometry.Alignment`.

    It's best to show what origin point is on an example. Assume you have a Node with a 100px width and 50px height
    sprite. You tell the engine to draw the node at some specific position e.g. :code:`position=Vector(300, 200)`.
    But what does this actually mean? Which pixel of the 100x50 image will really be drawn at (300, 200)?
    The top-left pixel? Or the central pixel? Or maybe some other pixel?

    By default it's the central pixel and that reference point is called the 'origin'. By setting the
    origin_alignment you can change the position of the point to one of the 9 default positions: from top left,
    through center to the bottom right.

    Setting the origin alignment is especially useful when working with text nodes (:class:`font.TextNode`) as it
    allows you to align text to the left or right.

    If you need a custom origin point position, not just one of the 9 default values, you can always wrap a node
    with a parent node. Remember that node positions are always set in relation to their parents, so by creating a
    parent-child node relations and setting origin_alignment appropriately, you can lay out the nodes on the scene
    any way you want.

.. _Node.lifetime:
.. attribute:: Node.lifetime

    Gets or sets a lifetime of the node, in miliseconds.

    By default nodes live forever. After you add them to the scene with :meth:`Node.add_child` method they will stay
    there until you delete them by calling :meth:`Node.delete`.

    Setting the lifetime of a node will remove the node automatically from the scene after given number of
    miliseconds. It's important to note that the timer starts ticking after you add the node to the scene, not
    when you instantiate the node.

.. _Node.transition:
.. attribute:: Node.transition

    Gets or sets a transition object on the node. Must be one of the types from the :code:`kaa.transitions` namespace.

    Transitions are "recipes" how the node should transform over time, by transformation we mean changing node's
    position, rotation, scale, color, etc. Transitions system is a very powerful feature,
    :doc:`refer to transitions documentation for details </reference/transitions>`.

Instance Methods:

.. method:: Node.add_child(child_node)

    Adds a child node to the current node. The child_node must be a :class:`Node` type or subtype.

    Each Scene always has a :ref:`root node <Scene.root>`, which allows to add your first nodes.

    When a parent node gets transformed (repositioned, scaled, rotated), all its child nodes are transformed
    accordingly.

    You can build the node tree freely, with some exceptions:

    * :class:`physics.BodyNode` must be a direct child of a :class:`physics.SpaceNode`
    * :class:`physics.HitboxNode` must be a direct child of a :class:`physics.BodyNode`

.. method:: Node.delete()

    Deletes a node from the scene. All child nodes get deleted automatically as well.

    **Important:** The node gets deleted immediately so you should not read any of the deleted node's properties
    afterwards. It may result in segmentation fault error and the whole process crashing down.

    See also: :ref:`Node lifetime <Node.lifetime>`