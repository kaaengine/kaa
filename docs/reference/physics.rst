:mod:`physics` --- A 2D physics system, with rigid bodies, collisions and more!
===============================================================================
.. module:: physics
    :synopsis: A 2D physics system, with rigid bodies, collisions and more!

Kaa inlcudes a 2D physics engine which allows you to easily add physical features to objects in your game, handle
collisions etc. The idea is based on three types of specialized :doc:`nodes </reference/nodes>`:

* :class:`SpaceNode` - it represents physical simulation environment, introducing environmental properties such as gravity or damping.
* :class:`BodyNode` - represents a physical body. Must be a direct child of a :class:`physics.SpaceNode`. Can have zero or more HitboxNodes.
* :class:`HitboxNode` - represents an area of a BodyNode which can collide with other HitboxNodes. Must be a direct child of a :class:`physics.BodyNode`.

Read more about :doc:`the nodes concept in general </reference/nodes>`.

.. note::

    Physics system present in the kaa engine is a wrapper of an excellent 2D physics library - `Chipmunk <https://chipmunk-physics.net/documentation.php>`_.

:class:`SpaceNode` reference
----------------------------

.. class:: SpaceNode(gravity=Vector(0,0), damping=1)

    SpaceNode is a :class:`nodes.Node` that represents physical simulation environment. All BodyNodes
    must be direct children of a SpaceNode. Typically you'll need just one SpaceNode per Scene, but nothing
    prevents you from adding more. If you decide to use multiple SpaceNodes on a Scene, be aware that they will be
    isolated (BodyNodes under SpaceNode A won't be able to interact with BodyNodes under SpaceNode B).

    Space node is also place where you can register collision handles (see :meth:`SpaceNode.set_collision_handler`).
    Collision handlers are your custom functions which will be called when a collision between a pair of defined
    hitbox nodes occurs.

    Constructor accepts all parameters from the base :class:`nodes.Node` class and adds the following
    new parameters:

    * :code:`gravity` - a :class:`geometry.Vector`
    * :code:`damping` - a number

Instance properties:

.. attribute:: SpaceNode.gravity

    Gets or sets the gravity inside the SpaceNode, as :class:`geometry.Vector`. Direction of the vector determines the
    direction of the gravitational force, while it's length determines gravity strength.

    Gravity will be applied only to the dynamic BodyNodes. Kinematic and Static BodyNodes do not have mass and therefore
    are not affected by the gravity.

    Default gravity is zero, meaning no gravitational forces applied.

.. attribute:: SpaceNode.damping


    Gets or sets the damping inside the SpaceNode. Represents a friction force or a drag force inside the environment which
    slows all BodyNodes down with time. A damping of 0.25 means velocity of all BodyNodes will decrease by a factor of 4
    in 1 second. A damping of 1 (default) means no slowdown force applied. A damping greater than 1 will make all BodyNodes
    accelerate, proportionally to its value.

    Damping is applied only to the dynamic BodyNodes. Kinematic and Static BodyNodes do not have mass and therefore
    ignore the damping effect.

Instance methods:

.. method:: SpaceNode.set_collision_handler(trigger_a, trigger_b, handler_callable)

    Registers a custom collision handler function between two :class:`HitboxNode`, tagged with trigger_a and trigger_b.

    Collisions occur between HitboxNodes (not between BodyNodes!). The :code:`trigger_a` and :code:`trigger_b` params
    are your own values which you use to tag :class:`HitboxNode`. They can be any type, using simple types such as
    numbers or strings is recommended.

    :code:`handler_callable` is your own function which must have the following three parameters:

    * :code:`arbiter` - an :class:`Arbiter` object that holds additional information about collision.
    * :code:`collision_pair_a`- a :class:`CollisionPair` object that allows identifying which BodyNode and which HitboxNoded collided. Corresponds with HitboxNode identified by trigger_a.
    * :code:`collision_pair_b`- a :class:`CollisionPair` object that allows identifying which BodyNode and which HitboxNoded collided. Corresponds with HitboxNode identified by trigger_b.

    .. code-block:: python

        # creating hitboxes
        bullet_hitbox = HitboxNode(shape=Circle(radius=10), trigger_id=123)  # 123 is our own value which we give

        # collision handler function:
        def on_collision_bullet_enemy(self, arbiter, bullet_pair, enemy_pair):
            print("Detected a collision between a bullet object's {} hitbox {} and Enemy's object {} hitbox {}".format(
                bullet_pair.body, bullet_pair.hitbox, enemy_pair.body, enemy_pair.hitbox))
            # ... write code to handle the collision effects ....

        # assuming space_node is <SpaceNode>:
        space_node.set_collision_handler(123, 456, self.on_collision_grenade_enemy)

        # note: 123 and 456 are any values of your choice.


    **IMPORTANT**: Collision handler function can be called multiple times for given pair of
    colliding objects (even multiple times per frame). This can happen if object's hitboxes touch for the first time,
    then they either overlap or touch each other for some time and finally - they separate. The collision handler
    function will be called every frame, as long as the hitboxes touch or overlap. When they make apart, the
    collision handler function stops being called.

:class:`BodyNode` reference
---------------------------

.. class:: BodyNode(body_type=BodyNodeType.dynamic, force=Vector(0,0), velocity=Vector(0,0), mass=20, moment=10000, torque=0, torque_degrees=0, angular_velocity=0, angular_velocity_degrees=0, position=Vector(0,0), rotation=0, scale=Vector(1, 1), z_index=0, color=Color(0,0,0,0), sprite=None, shape=None, origin_alignment=Alignment.center, lifetime=None, transition=None, visible=True)

    BodyNode is an extension of a :class:`nodes.Node` class, introducing physical properties. BodyNode must be
    a child of a SpaceNode. BodyNode is the only node type which can have :class:`HitboxNode` as children.

    Constructor accepts all parameters from the base :class:`nodes.Node` class and adds the following
    new parameters:

    * :code:`body_type` - a :class:`BodyNodeType` enum value. :ref:`Read more about available body types <BodyNode.body_type>`
    * :code:`force` - a :class:`geometry.Vector`
    * :code:`velocity` - a :class:`geometry.Vector`
    * :code:`mass` - a number
    * :code:`moment` - a number
    * :code:`torque` - a number
    * :code:`torque_degrees` - a number
    * :code:`angular_velocity` - a number
    * :code:`angular_velocity_degrees` - a number

Instance properties:

.. _BodyNode.body_type:
.. attribute:: BodyNode.body_type::

    TODO

:class:`HitboxNode` reference
-----------------------------

.. class:: HitboxNode()

    Params:

    * :code:`shape`
    * :code:`group`
    * :code:`mask`
    * :code:`collision_mask`
    * :code:`trigger_id`


:class:`Arbiter` reference
--------------------------

.. class:: Arbiter

    Arbiter object is passed to the collision handler function when collision occurs. It holds information about
    the collision in following fields:

    * :code:`space` - a :class:`SpaceNode` where collision occurred.
    * :code:`phase` - an enum value (:class:`CollisionPhase`), indicating collision phase. Available values are:

        * :code:`CollisionPhase.begin` - indicates that collision betwen two objects has started (their hitboxes have just touched or overlapped)
        * :code:`CollisionPhase.pre_solve` - indicates that two hitboxes are still in contact (touching or overlapping). It is called before the engine calculates the physics (e.g. velocities of both colliding objects)
        * :code:`CollisionPhase.post_solve` - like pre_solve, but called after the engine calculates the physics for the objects.
        * :code:`CollisionPhase.separate` - indicates that hitboxes of our two objects have separated - the collision has ended


:class:`CollisionPair` reference
--------------------------------

.. class:: CollisionPair

    CollisionPair object is passed to the collision handler function (see :meth:`SpaceNode.set_collision_handler()`).
    It holds references to an object that collided. The CollisionPair has the following fields:

    * :code:`body` - referencing :class:`BodyNode` which collided
    * :code:`hitbox` - referencing :class:`HitboxNode` which collided. Note that body nodes can have multiple hitboxes: here you can find which of them has collided


:class:`BodyNodeType` reference
-------------------------------

.. class:: BodyNodeType

    TODO

:class:`CollisionPhase` reference
---------------------------------

.. class:: CollisionPhase

    TODO