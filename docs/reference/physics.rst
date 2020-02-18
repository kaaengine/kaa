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

    Gets or sets the damping inside the SpaceNode. Represents a "friction" or a "drag force" inside the environment which
    slows all BodyNodes down with time. A damping of 0.25 means velocity of all BodyNodes will decrease by a factor of 4
    in 1 second. A damping of 1 (default) means no slowdown force applied. A damping greater than 1 will make all BodyNodes
    accelerate, proportionally to its value.

    Damping is applied only to the dynamic BodyNodes. Kinematic and Static BodyNodes do not have mass and therefore
    ignore the damping effect.

.. _SpaceNode.sleeping_threshold:
.. attribute:: SpaceNode.sleeping_threshold

    Gets of sets the sleep time threshold (in miliseconds) which affects all BodyNodes in
    the SpaceNode. If given BodyNode remains static (doesn't change its position or rotation) for that amount of
    time the engine will stop making physical calculations for it. In some situations it can improve the performance.
    A body remaining in a sleeping state can still collide with other bodies - that will force it to move and
    'wake up' as a consequence.

    Default value for the sleeping_threshold is infinite, which effectively means that the performance mechanism is
    disabled.

Instance methods:

.. _SpaceNode.set_collision_handler:
.. method:: SpaceNode.set_collision_handler(trigger_a, trigger_b, handler_callable)

    Registers a custom collision handler function between two :class:`HitboxNode` instances, tagged with
    trigger_a and trigger_b respectively.

    Collisions occur between HitboxNodes (not between BodyNodes!). The :code:`trigger_a` and :code:`trigger_b` params
    are your own values which you use to tag :class:`HitboxNode`. They can be any type, using simple types such as
    numbers or strings is recommended.

    :code:`handler_callable` is your own callable which accepts the following three parameters:

    * :code:`arbiter` - an :class:`Arbiter` object that holds additional information about collision.
    * :code:`collision_pair_a`- a :class:`CollisionPair` object that allows identifying which BodyNode and which HitboxNoded collided. Corresponds with HitboxNode identified by trigger_a.
    * :code:`collision_pair_b`- a :class:`CollisionPair` object that allows identifying which BodyNode and which HitboxNoded collided. Corresponds with HitboxNode identified by trigger_b.

    .. code-block:: python

        # somwhere in the code...
        bullet_hitbox = HitboxNode(shape=Circle(radius=10), trigger_id=123, ...... )  # 123 is our own value we give to all bullet hitboxes
        enemy_hitbox = HitboxNode(shape=Circle(radius=10), trigger_id=456, ...... )  # 456 is our own value we give to all enemy hitboxes

        # collision handler function:
        def on_collision_bullet_enemy(self, arbiter, bullet_pair, enemy_pair):
            print("Detected a collision between a bullet object's {} hitbox {} and Enemy's object {} hitbox {}".format(
                bullet_pair.body, bullet_pair.hitbox, enemy_pair.body, enemy_pair.hitbox))
            # ... write code to handle the collision effects ....

        # assuming space_node is <SpaceNode>,
        # 123 and 456 here are defining which pair of hitbox collisions shall be handled by the on_collision_bullet_enemy
        # in this case it defines a pair of a bullet hitbox and enemy hitbox
        space_node.set_collision_handler(123, 456, on_collision_bullet_enemy)

    **IMPORTANT**: Collision handler function can be called multiple times for given pair of
    colliding objects (even multiple times per frame). This can happen if object's hitboxes touch for the first time,
    then they either overlap or touch each other for some time and finally - they separate. The collision handler
    function will be called every frame, as long as the hitboxes touch or overlap. When they make apart, the
    collision handler function stops being called.

:class:`BodyNode` reference
---------------------------

.. class:: BodyNode(body_type=BodyNodeType.dynamic, force=Vector(0,0), velocity=Vector(0,0), mass=20.0, moment=10000.0, torque=0, torque_degrees=0, angular_velocity=0, angular_velocity_degrees=0, position=Vector(0,0), rotation=0, scale=Vector(1, 1), z_index=0, color=Color(0,0,0,0), sprite=None, shape=None, origin_alignment=Alignment.center, lifetime=None, transition=None, visible=True)

    BodyNode extends the :class:`nodes.Node` class, introducing physical features.

    In the nodes tree, BodyNode must be a direct child of a :class:`SpaceNode`.

    BodyNode is the only node type which can have :class:`HitboxNode` as children nodes.

    BodyNodes themselves never collide with each other. The need to have HitboxNodes as children to generate collisions.
    A BodyNode can have multiple HitboxNodes.

    BodyNode constructor accepts all parameters from the base :class:`nodes.Node` class and adds the following
    new parameters:

    * :code:`body_type` - a :class:`BodyNodeType` enum value. :ref:`Learn more here <BodyNode.body_type>`
    * :code:`force` - a :class:`geometry.Vector`
    * :code:`velocity` - a :class:`geometry.Vector`
    * :code:`mass` - a number
    * :code:`moment` - a number
    * :code:`torque` - a number
    * :code:`torque_degrees` - a number, alternative to :code:`torque`, using degrees instead of radians
    * :code:`angular_velocity` - a number
    * :code:`angular_velocity_degrees` - a number, alternative to :code:`angular_velocity`, using degrees instead of radians

Instance properties:

.. _BodyNode.body_type:
.. attribute:: BodyNode.body_type

    Gets or sets body type, must be a :class:`BodyNodeType` value. There are three types available:

    * static - the body has infinite mass and won't move when its hitboxes collide with any other hitboxes. You cannot move it "manually" by setting its velocity or angular velocity either. Those nodes are **truly** static.
    * kinematic - similar to static body in a sense that its velocity or rotation will never be affected by anything, e.g. its hitboxes colliding. But the difference is that you can move and rotate that type of body. The collisions will occur normally and you will be able to handle them.
    * dynamic - the default type. Physics engine will calculate body's velocity and angular velocity when its hitboxes will collide with other bodies' hitboxes.

    Use static bodies for static obstacles and other elements on the scene that you know won't move, but you want
    them to collide with other bodies and block their movement. Those bodies will always have zero velocity and
    zero angular velocity.

    Use kinematic bodies for objects which you want to move but you don't want their velocity controlled by the physics
    engine. Those nodes won't move or rotate on their own. The onus is on you to set their velocity or angular velocity
    but you still want to be able to detect collisions between them and other objects on the scene.

    Use dynamic bodies for freely moving objects that you want physics engine to fully take care of. Dynamic bodies
    have their velocity and angular velocity calculated by the engine.

    .. note::

        Example: a classic space shooter
        `Git Gud or Get Rekt <https://store.steampowered.com/app/1117810/Git_Gud_or_Get_Rekt/>`_, built with kaa engine
        is using kinematic bodies for player, enemies, and bullets, and dynamic bodies for debris left
        on the scene after enemies explode.


.. _BodyNode.force:
.. attribute:: BodyNode.force

    Gets or sets a custom force applied to the BodyNode, as :class:`geometry.Vector`. The force is reset to zero
    on each frame, so if you want it to constantly work on the object, you need to apply it on each frame.

    Applying force affects object's velocity.

    Force has an effect only on :ref:`dynamic body nodes <BodyNode.body_type>`. Static and kinematic body nodes will
    not be affected.


.. _BodyNode.velocity:
.. attribute:: BodyNode.velocity

    Gets or sets the linear velocity of the BodyNode, as :class:`geometry.Vector`. Linear velocity vector determines
    the speed and direction of movement of an object.

    For :ref:`dynamic body nodes <BodyNode.body_type>` the velocity is calculated by the physics engine. You can
    override the velocity value calculated by the engine but you should consider :ref:`applying force <BodyNode.force>`
    instead.

    Setting velocity from your code is recommended for kinematic bodies, as they won't move on their own
    otherwise.

.. _BodyNode.mass:
.. attribute:: BodyNode.mass

    Gets or sets the mass for the body node. Mass has an effect on the output velocity of dynamic body when it collides with other bodies.

.. _BodyNode.torque:
.. attribute:: BodyNode.torque

    Gets or sets the torque for the body node. Using radians. The torque is reset to zero on each frame, so if you
    want it to constantly work on the object you need to apply it on each frame.

    Applying torque affects object's angular velocity.

    Applying torque has an effect only on :ref:`dynamic body nodes <BodyNode.body_type>`. Static and kinematic body
    nodes are not affected.

    For degrees use :ref:`torque_degrees <BodyNode.torque_degrees>`

.. _BodyNode.torque_degrees:
.. attribute:: BodyNode.torque_degrees

    Gets or sets the torque for the body node. Using degrees. See :ref:`torque <BodyNode.torque>`

.. _BodyNode.angular_velocity:
.. attribute:: BodyNode.angular_velocity

    Gets or sets the angular velocity for the body node. Using radians. Angular velocity determines how fast the
    object rotates and the direction of the rotation (clockwise or anticlockwise).

    Similarly to :ref:`velocity <BodyNode.velocity>` the angular velocity is calculated by the physics engine for
    :ref:`dynamic body nodes <BodyNode.body_type>`. You can override the angular velocity manually but you should
    consider :ref:`applying torque <BodyNode.torque>` instead.

    Setting angular velocity from your code is recommended for kinematic bodies, as they won't rotate on their own
    otherwise.

    For degrees use :ref:`angular_velocity_degrees <BodyNode.angular_velocity_degrees>`

.. _BodyNode.angular_velocity_degrees:
.. attribute:: BodyNode.angular_velocity_degrees

    Gets or sets the angular velocity for the body node. Using degrees. See :ref:`angular_velocity <BodyNode.angular_velocity>`

.. _BodyNode.moment:
.. attribute:: BodyNode.moment

    Gets or sets the moment for the body node. Moment has an effect on the output angular velocity of dynamic body when it collides with other bodies.

.. attribute:: BodyNode.sleeping

    Gets or sets the sleeping status of the node as bool. If set to :code:`True` it gives the physics engine a
    performance hint, making it ignore this node when calculating its velocity and angular velocity. The node
    will wake up automatically when it's moving or rotating so it doesn't makes sense to set the sleeping status
    on a moving or rotating nodes.

    See also: :ref:`SpaceNode.sleeping_threshold <SpaceNode.sleeping_threshold>`.


:class:`HitboxNode` reference
-----------------------------

.. class:: HitboxNode(shape, group=None, mask=None, collision_mask=None, trigger_id=None, position=Vector(0,0), rotation=0, scale=Vector(1, 1), z_index=0, color=Color(0,0,0,0), sprite=None, shape=None, origin_alignment=Alignment.center, lifetime=None, transition=None, visible=True)

    HitboxNode extends the :class:`Node` class and introduces collision detection features.

    In the nodes tree, HitboxNode must be a direct child of a :class:`BodyNode`. A :class:`BodyNode` can have many
    HitboxNodes.

    HitboxNode inherits all :class:`Node` properties and methods, some of which may be particularly usful for
    debugging. For example, by setting a color and z_index of on a HitboxNode you can make the hitbox visible.

    Hitbox node has its own specific params:

    * :code:`shape` - can be either :class:`geometry.Polygon` or :class:`geometry.Circle`
    * :code:`group` - an integer.
    * :code:`mask` - a bit mask, it's recommended to use enumerated constant using enum.Intflag type
    * :code:`collision_mask` - a bit mask, it's recommended to use enumerated constant using enum.Intflag type
    * :code:`trigger_id` - your own value used with the :meth:`SpaceNode.set_collision_handler()` method.

Instance properties:

.. attribute:: HitboxNode.shape

    Gets or sets the shape of the hitbox. It can be either :class:`geometry.Polygon` or :class:`geometry.Circle`.

.. attribute:: HitboxNode.group

    Gets or sets the group of the hitbox, as integer. Hitboxes with the same group won't collide with each other.
    It's basically a performance hint for the physics engine. Default value is None, meaning no group.

    Another method of telling the engine which hitbox collisions it should ignore is to set :code:`mask` and
    :code:`collision_mask` on a HitboxNode.

.. attribute:: HitboxNode.mask

    Gets or sets the category of this hitbox node as bit mask. Other nodes will collide with this node if they
    match on collision_mask. Otherwise collisions will be ignored. Use mask and collision_mask as performance
    hints for the engine.

    By default mask and hitbox_mask are null which means the engine will try to detect
    collisions between each pair of hitboxes on the scene.

    In the example below we give the engine the following hints:
    * player hitbox will collide only with enemy hitbox, enemy bullet hitbox and wall hitbox
    * player bullet hitbox will collide only with the enemy hitbox
    * enemy hitbox will collide only with other enemy hitboxes, player, player bullet and wall hitbox
    * enemy bullet will collide only with the player hitboxes
    * wall will collide with everything except other wall hitboxes

    .. code-block:: python

        from kaa.physics import HitboxNode
        from kaa.geometry import Circle, Vector, Polygon
        import enum

        class CollisionMask(enum.IntFlag):
            player = enum.auto()
            player_bullet = enum.auto()
            enemy = enum.auto()
            enemy_bullet = enum.auto()
            wall = enum.auto()

            player_collision_mask = enemy | enemy_bullet | wall
            enemy_collision_mask = enemy | player | player_bullet | wall
            wall_collision_mask = player | player_bullet | enemy | enemy_bullet

        player_hitbox = HitboxNode(shape=Circle(radius=20), mask=CollisionMask.player,
                                   collision_mask=player_collision_mask)
        player_bullet_hitbox = HitboxNode(shape=Circle(radius=5), mask=CollisionMask.player_bullet,
                                          collision_mask=enemy)
        enemy_hitbox = HitboxNode(shape=Circle(radius=20), mask=CollisionMask.enemy,
                                  collision_mask=enemy_collision_mask)
        enemy_bullet_hitbox = HitboxNode(shape=Circle(radius=5), mask=CollisionMask.enemy_bullet,
                                         collision_mask=player)
        wall = HitboxNode(shape=Polygon([Vector(-50, -50), Vector(-50, 50), Vector(0, 100)],
                          mask=CollisionMask.wall, collision_mask=wall_collision_mask))

    What if there's assymetry in the mask and collision_mask definitions? For example, what will happens if we
    set the player hitbox to collide with enemy hitbox, but won't set enemy hitbox to collide with the player
    hitbox? In that case, the collisions won't occur. The collision masks need to match symmetrically from both sides.

    What if there is a proper symmetry in collision mask definitions but both hitboxes have the same group? In that
    case the group value takes precedence and collisions won't occur.

.. attribute:: HitboxNode.collision_mask

    Gets or sets the categories of other hitboxes that you want this hitbox to collide with.

    See the full example in the :code:`mask` section above for more information.

.. attribute:: HitboxNode.trigger_id

    Gets or sets the trigger id value. It can be any value of your choice (using integers is recommended). It's a
    'tag' value which you need to pass when :ref:`registering your custom collision handler function <SpaceNode.set_collision_handler>`


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

    Enum type used for classifying BodyNodes. It has the following values:

    * :code:`BodyNodeType.static`
    * :code:`BodyNodeType.dynamic`
    * :code:`BodyNodeType.kinematic`

    Refer to BodyNode's :ref:`body_type property<BodyNode.body_type>` for more information.

:class:`CollisionPhase` reference
---------------------------------

.. class:: CollisionPhase

    TODO