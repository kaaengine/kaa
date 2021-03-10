:mod:`physics` --- A 2D physics system, with rigid bodies, collisions and more!
===============================================================================
.. module:: physics
    :synopsis: A 2D physics system, with rigid bodies, collisions and more!

Kaa inlcudes a 2D physics engine which allows you to easily add physical features to objects in your game, handle
collisions etc. The idea is based on three types of specialized :doc:`nodes </reference/nodes>`:

* :class:`SpaceNode` - it represents physical simulation environment, introducing environmental properties such as gravity or damping.
* :class:`BodyNode` - represents a physical body. Each BodyNode must be a direct child of a :class:`physics.SpaceNode`. BodyNode can have HitboxNodes as child nodes.
* :class:`HitboxNode` - represents an area of a BodyNode which can collide with other HitboxNodes. Must be a direct child of a :class:`physics.BodyNode`.

Read more about :doc:`the nodes concept in general </reference/nodes>`.

.. note::

    Physics system present in the kaa engine is a wrapper of an excellent 2D physics library - `Chipmunk <https://chipmunk-physics.net/documentation.php>`_.

:class:`SpaceNode` reference
----------------------------

.. class:: SpaceNode(gravity=Vector(0,0), damping=1, position=Vector(0, 0), rotation=0, scale=Vector(1, 1), z_index=0, color=Color(0, 0, 0, 0), sprite=None, shape=None, origin_alignment=Alignment.center, lifetime=None, transition=None, visible=True)

    SpaceNode extends the :class:`nodes.Node`. It represents physical simulation environment. All BodyNodes
    must be direct children of a SpaceNode. Typically you'll need just one SpaceNode per Scene, but nothing
    prevents you from adding more. If you decide to use multiple SpaceNodes on a Scene, be aware that they will be
    isolated (BodyNodes under SpaceNode A won't be able to interact with BodyNodes under SpaceNode B).

    Space node is also place where you can register collision handlers (see :meth:`SpaceNode.set_collision_handler`).
    Collision handlers are your custom functions which will be called when a collision between a pair of defined
    hitbox nodes occurs.

    Another feature of the SpaceNode is running spatial queries. You can find hitboxes colliding with a
    custom shape (:class:`geometry.Circle`, :class:`geometry.Polygon` or :class:`geometry.Segment`) via
    :meth:`SpaceNode.query_shape_overlaps()`. You can find hitboxes colliding with a ray cast between points
    A and B using :meth:`SpaceNode.query_ray()`. Finally you can also find hitboxes around a specific point
    with :meth:`SpacenNode.query_point_neighbors()`.


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

    Gets of sets the sleep time threshold (in seconds) which affects all BodyNodes in
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
    trigger_a and trigger_b respectively. The function will get called when collision between hitboxes occur.

    Note, that collisions occur between HitboxNodes (not between BodyNodes!). The :code:`trigger_a`
    and :code:`trigger_b` params are your own values which you use to tag :class:`HitboxNode`. They should be
    of integer type.

    :code:`handler_callable` is your own callable, it takes the following three parameters:

    * :code:`arbiter` - an :class:`Arbiter` object that holds additional information about collision.
    * :code:`collision_pair_a`- a :class:`CollisionPair` object that allows identifying which BodyNode and which HitboxNoded collided. Corresponds with HitboxNode identified by trigger_a.
    * :code:`collision_pair_b`- a :class:`CollisionPair` object that allows identifying which BodyNode and which HitboxNoded collided. Corresponds with HitboxNode identified by trigger_b.

    If your collision handler function does not return any value, the collision will occur normally. However if you
    return 0 in the collision handler AND you do that in the begin or pre_solve phase, then collision will be ignored
    by the physics engine (no impulses will be applied to colliding objects). 

    .. code-block:: python

        # somwhere in the code...
        bullet_hitbox = HitboxNode(shape=Circle(radius=10), trigger_id=123, ...... )  # 123 is our own value we give to all bullet hitboxes
        enemy_hitbox = HitboxNode(shape=Circle(radius=10), trigger_id=456, ...... )  # 456 is our own value we give to all enemy hitboxes

        # collision handler function:
        def on_collision_bullet_enemy(arbiter, bullet_pair, enemy_pair):
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

.. method:: SpaceNode.query_shape_overlaps(shape, mask=kaa.physics.COLLISION_BITMASK_ALL, collision_mask=kaa.physics.COLLISION_BITMASK_ALL, group=kaa.physics.COLLISION_GROUP_NONE)

    Takes a shape (:class:`geometry.Circle` or :class:`geometry.Polygon`) and returns
    hitboxes which overlap with that shape (either partially or entirely) as well as body nodes which own those
    hitboxes. The shape coordinates are expected to be in a frame reference relative to the SpaceNode.

    When running the query, the shape you pass is treated like a hitbox node, therefore parameters such as mask,
    collision_mask and group behave identically as in :class:`HitboxNode`. It means you can use those params
    for filtering purpose. Refer to :ref:`mask <HitboxNode.mask>`,
    :ref:`collision_mask <HitboxNode.collision_mask>` and :ref:`group <HitboxNode.group>` for more information.

    The query returns a list of :class:`ShapeQueryResult` objects. Each :class:`ShapeQueryResult` represents a
    'collision' of the shape with one hitbox. It holds a reference to hitbox' parent (body node) and other metadata
    such as intersection points.

    .. code-block:: python

        from kaa.physics import SpaceNode, BodyNode, HitboxNode
        from kaa.geometry import Polygon

        self.space = SpaceNode()
        self.root.add_child(self.space)
        body_node = BodyNode(position=Vector(0, 0))
        hitbox = HitboxNode(shape=Polygon.from_box(Vector(100, 100)))
        body_node.add_child(hitbox)
        self.space.add_child(body_node)
        # find hitboxes intersecting with our triangular polygon
        triangle = Polygon([Vector(0, 0), Vector(100, 100), Vector(0, 200) ])
        results = self.space.query_shape_overlaps(triangle)
        for result in results:
            print(f"Shape {triangle.points} collided with hitbox {result.hitbox.shape.points} owned "
                  f"by {result.body}. Contact points metadata accessible at {result.contact_points}.")

.. method:: SpaceNode.query_ray(ray_start, ray_end, radius=0., mask=kaa.physics.COLLISION_BITMASK_ALL, collision_mask=kaa.physics.COLLISION_BITMASK_ALL, group=kaa.physics.COLLISION_GROUP_NONE)

    A "ray casting" method. Takes in a ray (two Vectors: :code:`ray_start` and :code:`ray_end`) and returns hitboxes
    (and their owning BodyNodes) which collide with that ray. The ray coordinates are expected to be in a frame reference
    relative to the SpaceNode.

    The :code:`radius` parameter sets the width of the cast ray.

    When running the query, the ray is treated like a hitbox node, therefore parameters such as mask,
    collision_mask and group behave identically as in :class:`HitboxNode`. It means you can use those params
    for filtering purpose. Refer to :ref:`mask <HitboxNode.mask>`,
    :ref:`collision_mask <HitboxNode.collision_mask>` and :ref:`group <HitboxNode.group>` for more information.

    The query returns a list of :class:`RayQueryResult` objects. Each represents a collision of the ray with one
    hitbox. It holds a reference to hitbox owner (body node) and other metadata such as intersection point.

    .. code-block:: python

        from kaa.physics import SpaceNode, BodyNode, HitboxNode
        from kaa.geometry import Polygon

        self.space = SpaceNode()
        self.root.add_child(self.space)
        body_node = BodyNode(position=Vector(0, 0))
        hitbox = HitboxNode(shape=Polygon.from_box(Vector(100, 100)))
        body_node.add_child(hitbox)
        self.space.add_child(body_node)

        # cast a ray and find hitboxes colliding with the ray
        results = self.space.query_ray(ray_start=Vector(-200, -200), ray_end=Vector(200,200))
        for result in results:
            print(f"Ray collided with {result.hitbox.shape.points} hitbox owned by {result.body} at "
                  f"{result.point}. Normal was {result.normal} and alpha was {result.alpha}")



.. method:: SpaceNode.query_point_neighbors(point, max_distance, mask=kaa.physics.COLLISION_BITMASK_ALL, collision_mask=kaa.physics.COLLISION_BITMASK_ALL, group=kaa.physics.COLLISION_GROUP_NONE)

    Queries for hitboxes :code:`max_distance` away from :code:`point`. The :code:`point` must be a
    :class:`geometry.Vector`.

    When running the query, the :code:`point` is treated like a hitbox node, therefore parameters such as mask,
    collision_mask and group behave identically as in :class:`HitboxNode`. It means you can use those params
    for filtering purpose. Refer to :ref:`mask <HitboxNode.mask>`,
    :ref:`collision_mask <HitboxNode.collision_mask>` and :ref:`group <HitboxNode.group>` for more information.

    The query returns a list of :class:`PointQueryResult` objects which contain collision data such as references
    to hitbox, its owner body node and other metadata.

    .. code-block:: python

        from kaa.physics import SpaceNode, BodyNode, HitboxNode
        from kaa.geometry import Polygon

        self.space = SpaceNode()
        self.root.add_child(self.space)
        body_node = BodyNode(position=Vector(0, 0))
        hitbox = HitboxNode(shape=Polygon.from_box(Vector(100, 100)))
        body_node.add_child(hitbox)
        self.space.add_child(body_node)

        # find hitboxes in the vicinity of a point
        point = Vector(-140, 140)
        results = self.space.query_point_neighbors(point=point, max_distance=200)
        for result in results:
            print(f"Point {point} collided with hitbox {result.hitbox.shape.points} owned "
                  f"by {result.body}. Collision point is at {result.point}, distance: {result.distance}")


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

.. _BodyNode.local_force:
.. attribute:: BodyNode.local_force

    Same as :ref:`BodyNode.force <BodyNode.force>` but uses strictly local frame of reference.

    .. code-block:: python

        node.rotation_degrees = 0
        node.force = Vector(1, 0)  # force will drag the object in direction V(1, 0), regardless to node rotation

        other_node.rotation_degrees = 45
        other_node.local_force = Vector(1, 0)  # force direction will be calculated AFTER applying the rotation!

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

Instance methods:

.. method:: BodyNode.apply_force_at_local(force, at)

    Applies :code:`force` (:class:`geometry.Vector`) to this body node at position :code:`at` (:class:`geometry.Vector`).
    The :code:`at` parameter is in a relative frame of reference. For example, if :code:`at` is :code:`Vector(0, 0)`
    then the force will be applied at the center of the body node.

    .. note::

        Applied force will be automatically reset to zero each frame, so if you want to apply force constantly
        you should do that on each frame.

.. method:: BodyNode.apply_impulse_at_local(impulse, at)

    Applies :code:`impulse` (:class:`geometry.Vector`) to this body node at position :code:`at` (:class:`geometry.Vector`).
    The :code:`at` parameter is in a relative frame of reference. For example, if :code:`at` is :code:`Vector(0, 0)`
    then the impulse will be applied at the center of the body node.

    .. note::
        Use impulses when you need to apply a very large force applied over a very short period of time. Some
        examples are a ball hitting a wall or cannon firing.

.. method:: BodyNode.apply_force_at(force, at)

    Same as :meth:`BodyNode.apply_force_at_local` but :code:`at` is in an absolute frame of reference. For instance,
    if body node's :ref:`absolute position <Node.absolute_position>` is Vector(110, 34) and you want to apply the
    force at the center of the body, you need to pass :code:`at=Vector(110, 34)`.

.. method:: BodyNode.apply_impulse_at(impulse, at)

    Same as :meth:`BodyNode.apply_impulse_at_local` but :code:`at` is in an absolute frame of reference. For instance,
    if body node's :ref:`absolute position <Node.absolute_position>` is Vector(110, 34) and you want to apply the
    impulse at the center of the body, you need to pass :code:`at=Vector(110, 34)`.


:class:`HitboxNode` reference
-----------------------------

.. class:: HitboxNode(shape, group=kaa.physics.COLLISION_GROUP_NONE, mask=kaa.physics.COLLISION_BITMASK_ALL, collision_mask=kaa.physics.COLLISION_BITMASK_ALL, trigger_id=None, position=Vector(0,0), rotation=0, scale=Vector(1, 1), z_index=0, color=Color(0,0,0,0), sprite=None, shape=None, sensor=False, elasticity=0.95, friction=0, surface_velocity=Vector(0, 0), origin_alignment=Alignment.center, lifetime=None, transition=None, visible=True))

    HitboxNode extends the :class:`Node` class and introduces collision detection features.

    In the nodes tree, HitboxNode must be a direct child of a :class:`BodyNode`. A :class:`BodyNode` can have many
    HitboxNodes.

    HitboxNode inherits all :class:`Node` properties and methods, some of which may be particularly useful for
    debugging. For example, by setting a color and z_index of on a HitboxNode you can make the hitbox visible.

    Hitbox node has its own specific params, related with collision handling:

    * :code:`shape` - can be either :class:`geometry.Polygon` or :class:`geometry.Circle`
    * :code:`group` - an integer, default value is a kaa constant meaning "no group". Hitboxes within the same group will never collide with each other.
    * :code:`mask` - an integer, used as a bit mask, it's recommended to use enum.Intflag enumerated constant. Default value is a kaa constant meaning "match all masks". Defines a category of this hitbox.
    * :code:`collision_mask` - an integer, used as a bit mask, it's recommended to use enum.Intflag enumerated constant. Default value is a kaa constant meaning "match all masks". Defines with which categories this hitbox should collide.
    * :code:`trigger_id` - an integer, your own value used with the :meth:`SpaceNode.set_collision_handler()` method. Used in custom collision handling.

    The hitbox node also has a few properties affecting its physical behaviour:

    * :code:`sensor`
    * :code:`elasticity`
    * :code:`friction`
    * :code:`surface_velocity`

Instance properties:

.. attribute:: HitboxNode.shape

    Gets or sets the shape of the hitbox. It can be either :class:`geometry.Polygon` or :class:`geometry.Circle`.

.. _HitboxNode.group:
.. attribute:: HitboxNode.group

    Gets or sets the group of the hitbox, as integer. Hitboxes with the same group won't collide with each other.
    It's basically a performance hint for the physics engine. Default value is kaa.physics.COLLISION_GROUP_NONE,
    meaning no group is used.

    Another method of telling the engine which hitbox collisions it should ignore is to set :code:`mask` and
    :code:`collision_mask` on a HitboxNode.

.. _HitboxNode.mask:
.. attribute:: HitboxNode.mask

    Gets or sets the category of this hitbox node, as a bit mask. Other nodes will collide with this node if they
    match on collision_mask. Otherwise collisions will be ignored. Use mask and collision_mask as performance
    hints for the engine.

    By default mask and hitbox_mask are kaa.physics.COLLISION_BITMASK_ALL which meaning the engine will not apply
    any filtering when detecting collisions - hitbox with those values will collide with any other hitbox.

    An example below shows how to set mask and collision_mask values to apply the following logic:

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
                                   collision_mask=CollisionMask.player_collision_mask)
        player_bullet_hitbox = HitboxNode(shape=Circle(radius=5), mask=CollisionMask.player_bullet,
                                          collision_mask=CollisionMask.enemy)
        enemy_hitbox = HitboxNode(shape=Circle(radius=20), mask=CollisionMask.enemy,
                                  collision_mask=CollisionMask.enemy_collision_mask)
        enemy_bullet_hitbox = HitboxNode(shape=Circle(radius=5), mask=CollisionMask.enemy_bullet,
                                         collision_mask=CollisionMask.player)
        wall = HitboxNode(shape=Polygon([Vector(-50, -50), Vector(-50, 50), Vector(0, 100)],
                          mask=CollisionMask.wall, collision_mask=CollisionMask.wall_collision_mask))

    What if there's assymetry in the mask and collision_mask definitions? For example, what will happens if we
    set the player to collide with enemy, but won't set enemy to collide with the player?
    In that case, those collisions won't occur. The collision masks need to match symmetrically from both sides for
    collision to be detected.

    What if there is a proper symmetry in collision mask definitions but both hitboxes have the same
    :ref:`group <HitboxNode.group>`? In that case the group value takes precedence and collisions won't occur.

.. _HitboxNode.collision_mask:
.. attribute:: HitboxNode.collision_mask

    Gets or sets the categories of other hitboxes that you want this hitbox to collide with.

    See the full example in the :ref:`mask <HitboxNode.mask>` section above for more information.

.. attribute:: HitboxNode.trigger_id

    Gets or sets the trigger id value. It can be any value of your choice. It's a
    'tag' value which you need to pass when :ref:`registering your custom collision
    handler function <SpaceNode.set_collision_handler>`

.. attribute:: HitboxNode.sensor

    Gets or sets the sensor flag (bool). Default is :code:`False`. If set to :code:`True`, the hitbox will not
    cause any physical collision effects (i.e. will not interact with other colliding objects) but will still trigger
    its collision handler function (check out :ref:`SpaceNode.set_collision_handler <SpaceNode.set_collision_handler>`
    method for more info on how to register a collision handlers for hitboxes).

.. attribute:: HitboxNode.elasticity

    Gets or sets hitbox elasticity, as :code:`float`. This is a percentage of kinetic energy transferred during collision
    and should be between 0 and 1. A value of 0.0 gives no bounce, while a value of 1.0 will give a "perfect" bounce.
    Default elasticity is 0.95. The elasticity for a collision is found by multiplying the elasticity of the
    interacting hitboxes together.

.. attribute:: HitboxNode.friction

    Gets or sets hitbox friction coefficient, as :code:`float`. Physics engine uses the Coulomb friction model, a
    value of 0.0 is frictionless. The friction for a collision is found by multiplying the friction of
    the interacting hitboxes together. Default is 0.

.. attribute:: HitboxNode.surface_velocity

    Gets or sets hitbox surface velocity, as :class:`geometry.Vector`. Useful for creating conveyor belts or players
    that move around. This value is only used when calculating friction, not resolving the collision. Default is
    :code:`Vector(0, 0)` (no surface velocity)


:class:`ShapeQueryResult` reference
-----------------------------------

.. class:: ShapeQueryResult

    ShapeQueryResult object is returned by the :meth:`SpaceNode.query_shape_overlaps()` method. A single query can
    return multiple ShapeQueryResult objects. A ShapeQueryResult has the following properties:

    * :code:`hitbox` - an instance of :class:`HitboxNode` which collided
    * :code:`body` - a :class:`BodyNode` instance that owns the hitbox
    * :code:`contact_points` - a list of :class:`CollisionContactPoint` objects which contain information about collision points

:class:`CollisionContactPoint` reference
----------------------------------------

.. class:: CollisionContactPoint

    A CollisionContactPoint instance represents an actual point where collision between two shapes occurred. It has
    the following properties:

    * :code:`point_a`
    * :code:`point_b`
    * :code:`distance`


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

    Enum type used by the collision handler :class:`Arbiter`. It has the following values:

    * :code:`CollisionPhase.begin`
    * :code:`CollisionPhase.pre_solve`
    * :code:`CollisionPhase.post_solve`
    * :code:`CollisionPhase.separate`


:class:`RayQueryResult` reference
-----------------------------------

.. class:: RayQueryResult

    RayQueryResult objects are returned by the :meth:`SpaceNode.query_ray()` method. A ShapeQueryResult represents
    a collision between a ray and a hitbox. It has the following properties:

    * :code:`hitbox` - an instance of :class:`HitboxNode` which collided
    * :code:`body` - a :class:`BodyNode` instance that owns the hitbox
    * :code:`point` - a :class:`geometry.Vector` where the ray intersected the hitbox
    * :code:`normal` - a :class:`geometry.Vector` with ray reflection direction. This vector is normalized.
    * :code:`alpha` - a float number indicating distance from the ray start point to the point where collision occurred. The distance is in relation to the ray length so the number is always between 0 and 1.

:class:`PointQueryResult` reference
-----------------------------------

.. class:: PointQueryResult

    PointQueryResult objects are returned by the :meth:`SpaceNode.query_point_neighbors()` method. Properties are

    * :code:`hitbox` - an instance of :class:`HitboxNode` which collided
    * :code:`body` - a :class:`BodyNode` instance that owns the hitbox
    * :code:`point` - a :class:`geometry.Vector` coords of the nearest point of collision
    * :code:`distance` - a :class:`geometry.Vector` with a distance to the point of collision
