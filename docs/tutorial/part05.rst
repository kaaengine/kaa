Part 5: Physics
===============

In this chapter we will implement the physics in the game. We will add enemies which we will be able to shoot with 3 weapons:

* Machine gun - will shoot regular bullets, which will deal damage to enemies they hit.
* Grenade launcher - grenades will explode on collision (triggering already known explosion animation) and deal damage to enemies in certain radius and apply force pushing enemies away
* Force gun - will shoot a large bullets which won't do any damage, just freely interact with enemies and with each other


Understanding SpaceNode, BodyNode and HitboxNode
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We need to learn about 3 new types of nodes which we need to simulate the physics in the game:

* SpaceNode - it represents physical simulation environment. Typically, a scene will need just one SpaceNode. SpaceNode has the following properties:

 * :code:`gravity` - a Vector. A force affecting all BodyNodes added to that SpaceNode
 * :code:`damping` - a float, representing friction forces. The bigger it is, the faster a freely moving objects will slow down.
 * width/height dimensions are not meanigful for the SpaceNode - it always covers the whole scene

* BodyNode - represents a physical body. It has the same properties as Node (in fact it inherits from the Node class) but adds a few new ones, such as:

  * :code:`mass` - a float
  * :code:`velocity` - a Vector. Vector's rotation is objects' movement direction and vector's length is how fast the object is moving.
  * :code:`angular_velocity` - a float. How fast the object is rotating around its center. Positive and negative values represent clockwise and anti-clockwise rotation speed respectively.
  * :code:`moment` - short explanation TBD
  * and few others.

* HitboxNode - represents an area of a BodyNode which can collide with other HitboxNodes. A BodyNode can have multiple HitboxNodes. A BodyNode without HitboxNodes has all physical properties calculated normally but won't collide with anything! HitboxNode properties include:

  * :code:`shape` - defines a shape of the hitbox, must be an instance of :code:`kaa.geometry.Circle` or :code:`kaa.geometry.Polygon`
  * :code:`mask` - user-defined enum.IntFlag, indicating "what type of object I am"
  * :code:`collision_mask` - user-defined enum.IntFlag, indicating "what type(s) of objects I can collide with"
  * :code:`trigger_id` - a user-defined ID used for collision handler function
  * :code:`group` - explanation TODO

When working with regular Nodes, we could build any tree-like structures we wanted, with multiple levels of nested Nodes. When working with physical Nodes some restrictions apply:

* SpaceNode must be assigned directly to the root node.
* BodyNode must be a child of a SpaceNode. It cannot be a child of other node type.
* BodyNode cannot have other BodyNodes as children. It can have regular Nodes as children though.
* HitboxNode must be a child of BodyNode. It cannot be a child of any other node type. BodyNode can have any number of HitboxNodes (including zero).

.. note::

    Physics engine available in kaa is a wrapper for an `excellent 2D physics engine written in C++ named Chipmunk <https://chipmunk-physics.net/>`_.
    Kaa surfaces a lot of Chipmunk methods and properties, but not all. New features are coming soon!


Why a BodyNode cannot have other BodyNodes as children ?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As you'll work on more complex games you'll notice that the most significant restriction is that BodyNode cannot
have other BodyNodes as children. It means we cannot have a tree-like structure of colliding objects (the list of
colliding objects in the scene must be a flat list!). It may seem like a serious
constraint, but there are good reasons for it. The purpose of physics engine is to calculate object's position,
rotation, velocity etc. based on environment properties (gravity, damping) and interactions (e.g. collisions) with
other dynamic objects. A node whose transformations (position, rotation) would be calculated
in relation to its parent, regardless of the physical environment (like it is with regular Nodes) simply stops being a
physical node and becomes just a picture drawn on the screen.

Having said that, there are ways in which you can simulate a more complex or hierarchical structure of physical objects

* Apply all BodyNode transformations you want manually and set it's position and/or rotation manually in relation to the parent object
* Collision queries - this feature is to be implemented soon. It will allow you to ask a question like "here's a polygon (circle, segment), tell me which HitboxNodes/BodyNodes it collides with"
* Joints - this feature is to be implemented next. You will be able to connect BodyNodes with 'joints' and they will behave


Types of BodyNodes
~~~~~~~~~~~~~~~~~~

A :code:`BodyNode` can be one of three types. This is determined by setting :code:`body_type` property on a :code:`BodyNode`.

* static (:code:`kaa.physics.BodyNodeType.static`) - this node cannot change position or rotation. Basically a performance hint for the engine. Useful for non-moving platforms, walls etc.
* kinematic (:code:`kaa.physics.BodyNodeType.kinematic`) - the node can move but does not have a mass (you can set the mass but it won't change its behavior). Upon collision it will behave as a static object. Useful when you're interested just in detecting a collision and handle all consequences on your own.
* dynamic (:code:`kaa.physics.BodyNodeType.dynamic`) - fully dynamic node. Useful for a 'free' objects which you add to the environment and let the engine work out all the physics.


Implement the first dynamic BodyNode
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Let's start using physics in our game. First let's define enum flags which we'll use to control what collides with what.

.. code-block:: python
    :caption: common/enums.py

    class HitboxMask(enum.IntFlag):
        player = enum.auto()
        enemy = enum.auto()
        bullet = enum.auto()
        all = player | enemy | bullet

Next let's add a SpaceNode to the Scene - it will be a container for all BodyNodes.

.. code-block:: python
    :caption: scenes/gameplay.py

    from kaa.physics import SpaceNode

    class GameplayScene(Scene):

        def __init__(self):
            super().__init__()
            self.space = SpaceNode()
            self.root.add_child(self.space)
            self.player_controller = PlayerController(self)

        # ....... rest of the class ......

We also need to change the line in the :code:`PlayerController` which adds :code:`Player` to the scene. We shall now
add the player to the space node.

.. code-block:: python
    :caption: controllers/player_controller.py

    # inside __init__ :
    self.scene.space.add_child(self.player)

Let's add few variables to settings.py. We'll need it later, just trust me and add that stuff for now :)

.. code-block:: python
    :caption: settings.py

    COLLISION_TRIGGER_PLAYER = 1
    COLLISION_TRIGGER_ENEMY = 2
    COLLISION_TRIGGER_MG_BULLET = 3
    COLLISION_TRIGGER_GRENADE_LAUNCHER_BULLET = 4
    COLLISION_TRIGGER_FORCE_GUN_BULLET = 5

Finally, let's change the :code:`Player` object to be a dynamic :code:`BodyNode` with a mass of 1. Let's also add
a hitbox for the player!

.. code-block:: python
    :caption: objects/player.py

    import settings
    from kaa.physics import BodyNode, BodyNodeType, HitboxNode
    from kaa.geometry import Vector, Polygon
    from kaa.enum import WeaponType, HitboxMask

    class Player(BodyNode): # changed from kaa.Node

        def __init__(self, position, hp=100):
            # node's properties
            super().__init__(body_type=BodyNodeType.dynamic, mass=1,
                             z_index=10, sprite=registry.global_controllers.assets_controller.player_img, position=position)
            # define a hitbox
            self.add_child(HitboxNode(
                shape=Polygon([Vector(-8, -19), Vector(8, -19), Vector(8, 19), Vector(-8, 19), Vector(-8, -19)]),
                mask=HitboxMask.player,
                collision_mask=HitboxMask.enemy,
                trigger_id=settings.COLLISION_TRIGGER_PLAYER
            ))
            # .......... rest of the function ...........

As we can see, we've added a rectangular hitbox, with mask 'player' and told the engine it should collidwe with hitboxes
whose mask is 'enemy'. We have also set a trigger_id (a custom integer number) - the meaning of this ID will become clear soon.

A few important remarks about Polygons of hitboxes:

* they must be closed (the first and the last point must be the same)
* `they must be convex <https://www.google.pl/search?q=convex+shape&tbm=isch&source=univ&sa=X&ved=2ahUKEwjr9pnJ5M7lAhW9AhAIHeVXCRMQsAR6BAgJEAE&biw=1920&bih=967>`_
* Polygon's coordinates are relative to the node origin

Run the game and make sure everything works. The gameplay did not change at all, but our hero is now a physical object!

Remember the naive implementation of player movement (setting player's position on WSAD keys pressed)? From physic's
engine standpoint such manual change of position would mean that the player is teleporting... It doesn't make sense.
Instead, let's set player's :code:`velocity` on pressing WSAD keys and let the physics engine calculate the position!

.. code-block:: python
    :caption: settings.py

    PLAYER_SPEED = 150

.. code-block:: python
    :caption: controllers/player_controller.py

    def update(dt):
        self.player.velocity=Vector(0,0)

        if self.scene.input.is_pressed(Keycode.w):
            self.player.velocity += Vector(0, -settings.PLAYER_SPEED)
        if self.scene.input.is_pressed(Keycode.s):
            self.player.velocity += Vector(0, settings.PLAYER_SPEED)
        if self.scene.input.is_pressed(Keycode.a):
            self.player.velocity += Vector(-settings.PLAYER_SPEED, 0)
        if self.scene.input.is_pressed(Keycode.d):
            self.player.velocity += Vector(settings.PLAYER_SPEED, 0)
        # ...... rest of the function ........

Run the game and make sure it works. Player's position will now be calculated by the physics engine, taking dt into
account automatically.

kinematic BodyNodes
~~~~~~~~~~~~~~~~~~~


static BodyNodes
~~~~~~~~~~~~~~~~

