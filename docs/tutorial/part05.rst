Part 5: Physics
===============

In this chapter we will implement physics in the game. We will add enemies and also implement shooting at them with 3 weapons:

* Machine gun - will shoot regular bullets, which will deal damage to enemies they hit.
* Grenade launcher - grenades will explode on collision (triggering already known explosion animation) and deal damage to enemies in certain radius and apply force pushing enemies away
* Force gun - will shoot a large bullets which won't do any damage, just freely interact with enemies and with each other


Understanding SpaceNode, BodyNode and HitboxNode
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We need to learn about 3 new types of nodes which we need to simulate the physics in the game:

* :code:`SpaceNode` - it represents physical simulation environment. Typically, a scene will need just one SpaceNode, but you can have more if needed. SpaceNode has the following properties:
  
  * :code:`gravity` - a Vector. A force affecting all BodyNodes added to that SpaceNode. Default is zero vector (no gravity).
  * :code:`damping` - a float between 0 and 1, representing friction forces in the simulation space. The smaller it is, the faster a freely moving objects will slow down. Default is 1 (no damping)

.. raw:: html

	<p></p>

* :code:`BodyNode` - represents a physical body. It has the same properties as Node (in fact it inherits from the Node class) but adds a few new ones, such as:

  * :code:`body_type` - enum value, determining the type of the body node, check out :ref:`types of body nodes <types_of_body_nodes>`
  * :code:`mass` - a float, heavier objects will hit harder :)
  * :code:`velocity` - a Vector. Vector's rotation is objects' movement direction and vector's length is how fast the object is moving. Default is zero vector (no velocity).
  * :code:`angular_velocity` - a float. How fast the object is rotating around its center. Positive and negative values represent clockwise and anti-clockwise rotation speed respectively. Default is zero.
  * :code:`force` - a Vector, representing a force working on the object. The force vector is reset to zero on each frame. Non-zero force applied each frame will cause the object to accelerate. Default is zero vector (no force).
  * and few others (out of scope of the tutorial, check out the API reference on :class:`physics.BodyNode` for more info)

.. raw:: html

	<p></p>

* :code:`HitboxNode` - represents an area of a BodyNode which can collide with other HitboxNodes. A BodyNode can have multiple HitboxNodes. A BodyNode without HitboxNodes has all physical properties calculated normally but won't collide with anything! HitboxNode properties include:

  * :code:`shape` - defines a shape of the hitbox, must be an instance of :code:`kaa.geometry.Circle` or :code:`kaa.geometry.Polygon`
  * :code:`mask` - user-defined enum.IntFlag, indicating "what type of object I am"
  * :code:`collision_mask` - user-defined enum.IntFlag, indicating "what type(s) of objects I can collide with"
  * :code:`trigger_id` - a user-defined ID used for collision handler function

When working with regular Nodes, we could build any tree-like structures we wanted, with multiple levels of nested Nodes. When working with physical Nodes some restrictions apply:

* BodyNode must be a child of a SpaceNode. It cannot be a child of other node type.
* BodyNode cannot have other BodyNodes as children. It can have regular Nodes as children though.
* HitboxNode must be a child of BodyNode. It cannot be a child of any other node type. BodyNode can have any number of HitboxNodes (including zero).
* HitboxNode cannot have another HitboxNode as a child, it can have regular Node children though.

.. note::

	Space node doesn't have to be a child of a root node, in fact it can be anywhere in the node tree but for clarity it's recommended to have it as a direct child of the root node.

.. note::

    Physics engine available in kaa is a wrapper for an `excellent 2D physics engine written in C++ named Chipmunk <https://chipmunk-physics.net/>`_.
    Kaa surfaces a lot of Chipmunk methods and properties, but not all yet. New features are coming soon!


Why a BodyNode cannot have other BodyNodes as children ?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As you'll work on more complex games you'll notice that the most significant restriction is that BodyNode cannot
have other BodyNodes as children. It means we cannot have a tree-like structure of colliding objects, the list of
physical objects in the scene must be a flat list!. It may seem like a serious
constraint, but there are good reasons for it. The purpose of physics engine is to calculate object's position,
rotation, velocity etc. based on environment properties (gravity, damping) and interactions (e.g. collisions) with
other dynamic objects. A node whose transformations (position, rotation) would be calculated
in relation to its parent, regardless of the physical environment (like it is with regular Nodes) simply stops being a
physical node and becomes just a picture drawn on the screen.

Having said that, there are ways in which you can simulate a more complex or hierarchical structure of physical objects

* Apply all BodyNode transformations manually. In other words do the calculations on your own and set the object's position and/or rotation manually.
* Spatial queries - it allows to programatically ask a question like "here's a polygon (circle, segment), tell me which HitboxNodes/BodyNodes it collides with"
* Joints - this feature is to be implemented next. You will be able to connect BodyNodes with 'joints' and they will work together.


.. _types_of_body_nodes:

Types of BodyNodes
~~~~~~~~~~~~~~~~~~

A :code:`BodyNode` can be one of three types. This is determined by setting :code:`body_type` property on a :code:`BodyNode`.

* static (:code:`kaa.physics.BodyNodeType.static`) - this node cannot change position or rotation. Basically a performance hint for the engine. Useful for non-moving platforms, walls etc.
* kinematic (:code:`kaa.physics.BodyNodeType.kinematic`) - the node can move but does not have a mass (you can set the mass but it won't change its behavior) therefore no environmental effects (such as damping or gravity) can affect it. When colliding with other objects it will behave as a static object. Using kinemtaic bodies is useful when you're interested just in detecting a collision and handle all consequences on your own.
* dynamic (:code:`kaa.physics.BodyNodeType.dynamic`) - fully dynamic node. Useful for a 'free' objects which you add to the environment and let the engine work out all the physics.


Implement the first BodyNode with a hitbox
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

    PLAYER_SPEED = 150
    FORCE_GUN_BULLET_SPEED = 300
    MACHINE_GUN_BULLET_SPEED = 1200
    GRENADE_LAUNCHER_BULLET_SPEED = 200

Finally, let's make the :code:`Player` object to inherit from a :code:`BodyNode`, making it a physical object. Let's
give it a mass of 1. Let's also add a hitbox node to the player!

.. code-block:: python
    :caption: objects/player.py

    import settings
    from kaa.physics import BodyNode, BodyNodeType, HitboxNode
    from kaa.geometry import Vector, Polygon
    from common.enums import WeaponType, HitboxMask

    class Player(BodyNode): # changed from kaa.Node

        def __init__(self, position, hp=100):
            super().__init__(body_type=BodyNodeType.dynamic, mass=1,
                             z_index=10, sprite=registry.global_controllers.assets_controller.player_img, position=position)
            # create a hitbox and add it as a child node to the Player
            self.add_child(HitboxNode(
                shape=Polygon([Vector(-10, -25), Vector(10, -25), Vector(10, 25), Vector(-10, 25), Vector(-10, -25)]),
                mask=HitboxMask.player,
                collision_mask=HitboxMask.enemy,
                trigger_id=settings.COLLISION_TRIGGER_PLAYER
            ))
            # .......... rest of the function ...........

As we can see, we've added a rectangular hitbox, with mask 'player' and told the engine it should collide with hitboxes
whose mask is 'enemy' - we will add those soon. We have also set a trigger_id for a hitbox (basically, a custom integer
number) - the meaning of this ID will also become clear soon.

A few important remarks about Polygons of hitboxes:

* `they must be convex <https://www.google.pl/search?q=convex+shape&tbm=isch&source=univ&sa=X&ved=2ahUKEwjr9pnJ5M7lAhW9AhAIHeVXCRMQsAR6BAgJEAE&biw=1920&bih=967>`_
* Polygon's coordinates are relative to the node origin
* they don't need to be closed - the first and the last point don't have to be the same. Kaa will close them automatically.

Run the game and make sure everything works. The gameplay did not change at all, but our hero is now a physical object!

Remember the naive implementation of player movement (setting player's position on WSAD keys pressed)? From physic's
engine standpoint manual change of objects position makes no sense. Let's set player's :code:`velocity` instead,
and let the physics engine calculate the position.

.. code-block:: python
    :caption: controllers/player_controller.py

    def update(dt):
        self.player.velocity=Vector(0,0) # reset velocity to zero, if no keys are pressed the player will stop

        if self.scene.input.keyboard.is_pressed(Keycode.w):
            self.player.velocity += Vector(0, -settings.PLAYER_SPEED)
        if self.scene.input.keyboard.is_pressed(Keycode.s):
            self.player.velocity += Vector(0, settings.PLAYER_SPEED)
        if self.scene.input.keyboard.is_pressed(Keycode.a):
            self.player.velocity += Vector(-settings.PLAYER_SPEED, 0)
        if self.scene.input.keyboard.is_pressed(Keycode.d):
            self.player.velocity += Vector(settings.PLAYER_SPEED, 0)
        # ...... rest of the function ........

Run the game and make sure it works. Player's position will now be calculated by the physics engine, and we don't
need to worry about frame duration - it's all handled automatically by the physics engine.

Drawing hitboxes on the screen
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Hitbox nodes are invisible by default, but sometimes it's good to see them (e.g. to check if they're positioned correctly).
We can do that by setting :code:`color` property. Using :code:`z_index` is also advisable to make the hitbox node
be drawn on top of its :code:`BodyNode`.

.. code-block:: python

    from kaa.colors import Color

    # to make hitbox node visible just set its color and a high enough z_index
    hitbox_node.color = Color(1, 0, 1, 0.3)
    hitbox_node.z_index = 1000

Feel free to experiment with setting player's hitbox color, then move on to the next section.

Adding more BodyNodes
~~~~~~~~~~~~~~~~~~~~~

We have the player with a gun in hand but where are the enemies? Let's add some. First, let's write an :code:`Enemy`
class. Just like the player, the enemy must be a :code:`BodyNode` because we want it to be a physical object with a
hitbox node attached.

.. code-block:: python
    :caption: objects/enemy.py

    from kaa.physics import BodyNodeType, BodyNode, HitboxNode
    from kaa.geometry import Vector, Polygon
    from common.enums import HitboxMask
    import registry
    import settings
    from kaa.transitions import NodeSpriteTransition
    import random

    class Enemy(BodyNode):

        def __init__(self, position, hp=100, *args, **kwargs):
            # node's properties
            super().__init__(body_type=BodyNodeType.dynamic, mass=1,
                             z_index=10, position=position,
                             transition=NodeSpriteTransition(registry.global_controllers.assets_controller.enemy_frames,
                                                             duration=max(200, random.gauss(400,100)), loops=0),
                             *args, **kwargs)
            # create a hitbox and add it as a child node to the Enemy
            self.add_child(HitboxNode(
                shape=Polygon([Vector(-8, -19), Vector(8, -19), Vector(8, 19), Vector(-8, 19), Vector(-8, -19)]),
                mask=HitboxMask.enemy,
                collision_mask=HitboxMask.all,
                trigger_id=settings.COLLISION_TRIGGER_ENEMY,
            ))
            # custom properties
            self.hp = hp

We're using the already known features: creating an animation loop (using :code:`NodeSpriteTransition`), and adding
a hitbox as a child node.

Next, let's write :code:`EnemiesController` class which will have methods such as :code:`add_enemy` and
:code:`remove_enemy`. It will also have an :code:`update()` function where we will implement enemies AI. We shall
add some initial enemies to the scene in the :code:`__init__`.

.. code-block:: python
    :caption: controllers/enemies_controller.py

    import random
    from objects.enemy import Enemy
    from kaa.geometry import Vector

    class EnemiesController:

        def __init__(self, scene):
            self.scene = scene
            self.enemies = []
            # add some initial enemies
            self.add_enemy(Enemy(position=Vector(200, 200), rotation_degrees=random.randint(0, 360)))
            self.add_enemy(Enemy(position=Vector(1500, 600), rotation_degrees=random.randint(0, 360)))
            self.add_enemy(Enemy(position=Vector(1000, 400), rotation_degrees=random.randint(0, 360)))
            self.add_enemy(Enemy(position=Vector(1075, 420), rotation_degrees=random.randint(0, 360)))
            self.add_enemy(Enemy(position=Vector(1150, 440), rotation_degrees=random.randint(0, 360)))

        def add_enemy(self, enemy):
            self.enemies.append(enemy)  # add to the internal list
            self.scene.space.add_child(enemy)  # add to the scene

        def remove_enemy(self, enemy):
            self.enemies.remove(enemy)  # remove from the internal list
            enemy.delete()  # remove from the scene

        def update(self, dt):
            pass


Let's put the controller in the scene and hook up the :code:`update()`:

.. code-block:: python
    :caption: scenes/gameplay.py

    from controllers.enemies_controller import EnemiesController

    class GameplayScene(Scene):

        def __init__(self):
            # ... rest of the function ....
            self.enemies_controller = EnemiesController(self)

        def update(self, dt):
            self.player_controller.update(dt)
            self.enemies_controller.update(dt)
            # ... rest of the function

Run the game. We have the enemies on the scene! They're animated but not moving yet. They're regular physical objects, as you
run into them they'll collide with you and with each other. Since we're not applying any forces to enemies yet
it looks as if they were on an ice rink :)

Let's add a feature of spawning enemies by pressing SPACE. The enemy shall be spawned at current mouse pointer position.

.. code-block:: python
    :caption: controllers/player_controller.py

    import random
    from objects.enemy import Enemy

    class PlayerController:

        def update(self, dt):
            # .... rest of the function
            for event in self.scene.input.events():
                if event.keyboard_key:
                    # ... other keyboard events ....
                    elif event.keyboard_key.key == Keycode.space:
                        self.scene.enemies_controller.add_enemy(Enemy(position=self.scene.input.mouse.get_position(),
                            rotation_degrees=random.randint(0,360)))

Run the game and see how you can spawn them by pressing space bar! Cool isn't it?

You can take a moment to make some experiments, for instance:

* try setting :code:`damping` on the :code:`SpaceNode` (in scenes/gameplay.py) to a very low value e.g. 0.01 and see how it works! Values greater than 1 will result in a funny effect of objects accelerating just by moving in the environment.
* try giving enemies different masses (e.g. randomly) and observe how it affects them as they collide with each other.

We now know everything to implement shooting the Force Gun - it will basically shoot a dynamic BodyNode objects
which will collide with enemies, player and with each other. We're going to give those nodes a lifetime of 10 seconds.

Let's implement the bullet object first. It's going to be really simple: a BodyNode with a random mass, a circular
hitbox and a lifetime of 10 seconds.

.. code-block:: python
    :caption: objects/bullets/force_gun_bullet.py

    import random
    from kaa.physics import BodyNode, BodyNodeType, HitboxNode
    from kaa.geometry import Circle
    import registry
    import settings
    from common.enums import HitboxMask


    class ForceGunBullet(BodyNode):

        def __init__(self, *args, **kwargs):
            super().__init__(sprite=registry.global_controllers.assets_controller.force_gun_bullet_img,
                             z_index=30,
                             body_type=BodyNodeType.dynamic,
                             mass=random.uniform(0.5, 8),  # a random mass,
                             lifetime=10000, # will be removed from the scene automatically after 10 secs
                             *args, **kwargs)
            self.add_child(HitboxNode(shape=Circle(radius=10),
                                      mask=HitboxMask.bullet,
                                      collision_mask=HitboxMask.all,
                                      trigger_id=settings.COLLISION_TRIGGER_FORCE_GUN_BULLET))


Next, let's add methods for shooting in the :code:`WeaponBase` class and in the :code:`ForceGun` class:

.. code-block:: python
    :caption: objects/weapons/base.py

    from kaa.nodes import Node
    from kaa.geometry import Vector


    class WeaponBase(Node):

        def __init__(self, *args, **kwargs):
            super().__init__(z_index=20, *args, **kwargs)
            self.cooldown_time_remaining = 0

        def shoot_bullet(self):
            raise NotImplementedError  # must be implemented in the derived class

        def get_cooldown_time(self):
            raise NotImplementedError  # must be implemented in the derived class

        def get_initial_bullet_position(self):
            player_pos = self.parent.position
            player_rotation = self.parent.rotation_degrees
            weapon_length = 50  # the bullet won't originate in the center of the player position but 50 pixels from it
            result = player_pos + Vector.from_angle_degrees(player_rotation).normalize()*weapon_length
            return result


.. code-block:: python
    :caption: objects/weapons/force_gun.py

    import registry
    import settings
    from objects.bullets.force_gun_bullet import ForceGunBullet
    from objects.weapons.base import WeaponBase
    from kaa.geometry import Vector

    class ForceGun(WeaponBase):

        def __init__(self):
            # node's properties
            super().__init__(sprite=registry.global_controllers.assets_controller.force_gun_img)

        def shoot_bullet(self):
            bullet_position = self.get_initial_bullet_position()
            bullet_velocity = Vector.from_angle_degrees(self.parent.rotation_degrees) * settings.FORCE_GUN_BULLET_SPEED
            self.scene.space.add_child(ForceGunBullet(position=bullet_position, velocity=bullet_velocity))
            # reset cooldown time
            self.cooldown_time_remaining =  self.get_cooldown_time()

        def get_cooldown_time(self):
            return 0.250

The maths in the :code:`shoot_bullet` and :code:`get_initial_bullet_position` is fairly simple, but let's highlight
a few things here. :code:`get_initial_bullet_position` basically returns a player's position offset by 50 pixels
towards the direction where the player is rotated (where he points his gun). This way the bullet will spawn at the end of the weapon's barrel.
Spawning it in the center of the player would not look good! We're using Vector's method :code:`from_angle_degrees` to create a
normal (length of 1) vector rotated in the direction of the player, multiply by 50 and add player position. :code:`shoot_bullet`
is even easier, it just adds a bullet velocity, again, creating vector rotated at direction where player is pointing
his gun and then multiplying by bullet speed. Finally we set the cooldown time to weapon's value.

The last thing is to wire it all up in the :code:`PlayerController` inside the :code:`update()` function:

.. code-block:: python
    :caption: controllers/player_controller.py

    from kaa.input import Keycode, MouseButton

    class PlayerController:
        # .... rest of the class ....

        def update(self, dt):
            # .... rest of the function ....

            # Handle weapon logic
            if self.player.current_weapon is not None:
                # decrease weapons cooldown time by dt
                self.player.current_weapon.cooldown_time_remaining -= dt
                # if left mouse button pressed and weapon is ready to shoot, then, well, shoot a bullet!
                if self.scene.input.mouse.is_pressed(MouseButton.left) and self.player.current_weapon.cooldown_time_remaining<0:
                    self.player.current_weapon.shoot_bullet()

Run the game! You can now shoot them with the force gun! How cool is it?

Did you get :code:`NotImplementedError`? It's because other weapons are not implemented, just look at the code! Change
to ForceGun by pressing 3 and then try shooting. Better? Much better!

The game slowly starts looking like a playable thing. We can move around, spawn enemies and shoot our Force Gun at them.

Let's now do shooting the machine gun!

Kinematic BodyNodes
~~~~~~~~~~~~~~~~~~~

Let's start with the machine gun bullet object. It's similar to Force Gun bullet but will use different sprite and
will have a rectangular hitbox that collides only with enemies.

The most important difference though is that we'll make it a kinematic body type. As
said before this body type is useful when we want to handle collisions entirely on our own.

First let's add the machine gun bullet object and implement shooting logic:

.. code-block:: python
    :caption: objects/bullets/machine_gun_bullet.py

    import random
    import registry
    import settings
    from kaa.physics import BodyNode, BodyNodeType, HitboxNode
    from kaa.geometry import Polygon, Vector
    from common.enums import HitboxMask


    class MachineGunBullet(BodyNode):

        def __init__(self, *args, **kwargs):
            super().__init__(sprite=registry.global_controllers.assets_controller.machine_gun_bullet_img,
                             z_index=30,
                             body_type=BodyNodeType.kinematic, # MG bullets are kinematic bodies
                             lifetime=3000, # will be removed from the scene automatically after 3 secs
                             *args, **kwargs)
            self.add_child(HitboxNode(shape=Polygon([Vector(-13, -4), Vector(13,-4), Vector(13,4), Vector(-13,4), Vector(-13,-4)]),
                                      mask=HitboxMask.bullet, # tell physics engine about object type
                                      collision_mask=HitboxMask.enemy, # tell physics engine which objects it can collide with
                                      trigger_id=settings.COLLISION_TRIGGER_MG_BULLET # ID to be used in custom collision handling function
                                      ))


.. code-block:: python
    :caption: objects/weapons/machine_gun.py

    import registry
    import settings
    from objects.bullets.machine_gun_bullet import MachineGunBullet
    from objects.weapons.base import WeaponBase
    from kaa.geometry import Vector


    class MachineGun(WeaponBase):

        def __init__(self):
            # node's properties
            super().__init__(sprite=registry.global_controllers.assets_controller.machine_gun_img)

        def shoot_bullet(self):
            bullet_position = self.get_initial_bullet_position()
            bullet_velocity = Vector.from_angle_degrees(self.parent.rotation_degrees) * settings.MACHINE_GUN_BULLET_SPEED
            self.scene.space.add_child(MachineGunBullet(position=bullet_position, velocity=bullet_velocity,
                                                        rotation_degrees=self.parent.rotation_degrees))
            # reset cooldown time
            self.cooldown_time_remaining =  self.get_cooldown_time()

        def get_cooldown_time(self):
            return 0.100


The above is very similar to the force gun. You may run the game and see how it looks. The main difference is that
the machine gun bullets don't bounce back when colliding with enemies. In fact they're not affected at all by
any collisions, and behave as if they had very large mass, pushing enemies with great energy. It's because they're
kinematic bodies. We'll fix that in a moment, by writing our own collision handler.

Collisions handling
~~~~~~~~~~~~~~~~~~~

Let's implement a collision handler function to process collisions between machine gun bullet and enemy.
This is where :code:`trigger_id` values are being used. Put the following code in the
:code:`controllers/collisions_controller.py`:

.. code-block:: python
    :caption: controllers/collisions_controller.py

    import settings

    class CollisionsController:

        def __init__(self, scene):
            self.scene = scene
            self.space = self.scene.space
            self.space.set_collision_handler(settings.COLLISION_TRIGGER_MG_BULLET, settings.COLLISION_TRIGGER_ENEMY,
                                             self.on_collision_mg_bullet_enemy)

        def on_collision_mg_bullet_enemy(self, arbiter, mg_bullet_pair, enemy_pair):
            print("Detected a collision between MG bullet object {} hitbox {} and Enemy object {} hitbox {}".format(
                mg_bullet_pair.body, mg_bullet_pair.hitbox, enemy_pair.body, enemy_pair.hitbox))


The line where we call :code:`set_collision_handler` on the scene's :code:`SpaceNode` is where we tell the engine
that we want our function to be called each time a collision between MG bullet and enemy occurs. We're using
hitbox :code:`trigger_id` here.

It is very important to realize that **a collision handler function can be called multiple times for given pair of
colliding objects (even multiple times per frame)**. This can happen if object's hitboxes touch for the first time,
then they either overlap or touch each other for some time and finally - they separate. The collision handler
function will be called every frame, as long as the hitboxes touch or overlap. When they make apart, the collision
handler function stops being called.

Collision handler function always has the three parameters:

* :code:`arbiter` - arbiter object that includes additional information about collision. It has the following properties:

  * :code:`space` - a :code:`SpaceNode` where collision occurred.
  * :code:`phase` - an enum value (:code:`kaa.physics.CollisionPhase`), indicating collision phase. Available values are:

    * :code:`kaa.physics.CollisionPhase.begin` - indicates that collision betwen two objects has started (their hitboxes have just touched or overlapped)
    * :code:`kaa.physics.CollisionPhase.pre_solve` - indicates that two hitboxes are still in contact (touching or overlapping). It is called before the engine calculates the physics (e.g. velocities of both colliding objects)
    * :code:`kaa.physics.CollisionPhase.post_solve` - like pre_solve, but called after the engine calculates the physics for the objects.
    * :code:`kaa.physics.CollisionPhase.separate` - indicates that hitboxes of our two objects have separated - the collision has ended

.. raw:: html

	<p></p>

* two "collision_pair" objects, corresponding with trigger_ids. Each collision pair object has two properties:

  * :code:`body` - referencing :code:`BodyNode` which collided
  * :code:`hitbox` - referencing :code:`HitboxNode` which collided (remember that body nodes can have multiple hitboxes - here we can know which of them has collided!)

Next, let's  hook up the controller with the scene in :code:`scenes/gameplay.py`'s :code:`__init__`:

.. code-block:: python
    :caption: scenes/gameplay.py

    from controllers.collisions_controller import CollisionsController

    class GameplayScene(Scene):

        def __init__(self):
            # ......... rest of the function .........
            self.collisions_controller = CollisionsController(self)

Run the game and shoot the machine gun at enemies to see that collision handler function is called (the print message appears in your std out)

Now, let's implement enemies "staggering" when hit. Stagger will simply be a number of miliseconds when alternative frame
is displayed.

.. code-block:: python
    :caption: objects/enemy.py

    class Enemy(BodyNode):

        def __init__(self, position, hp=100, *args, **kwargs):
            # ......... rest of the function .......
            self.stagger_time_left = 0

        def stagger(self):
            # use the "stagger" sprite
            self.sprite = registry.global_controllers.assets_controller.enemy_stagger_img
            # stagger stops enemy from moving:
            self.velocity = Vector(0, 0)
            # track time for staying in the "staggered" state
            self.stagger_time_left = 150

        def recover_from_stagger(self):
            # start using the standard sprite animation again
            self.transition=NodeSpriteTransition(registry.global_controllers.assets_controller.enemy_frames,
                                                             duration=max(200, random.gauss(400, 100)), loops=0)

            self.stagger_time_left = 0


And track stagger time and recovery in the enemies controller:

.. code-block:: python
    :caption: controllers/enemies_controller.py

    class EnemiesController:
        # ........ rest of the class ..........

        def update(self, dt):
            for enemy in self.enemies:
                # handle enemy stagger time and stagger recovery
                if enemy.stagger_time_left > 0:
                    enemy.stagger_time_left -= dt
                    if enemy.stagger_time_left <= 0:
                        enemy.recover_from_stagger()


Finally let's implement the proper collision handling logic when a machine gun bullet collides with an enemy. We
would apply 10 HP damage and add a blood splatter animation at a place where collision occurred. If enemy HP drops
below zero we remove the enemy from the scene and play enemy death animation.

.. code-block:: python
    :caption: controllers/collisions_controller.py

    import math
    import settings
    import registry
    import random
    from kaa.physics import CollisionPhase
    from kaa.nodes import Node
    from kaa.geometry import Alignment

    class CollisionsController:
        # ....... rest of the class ........

        def on_collision_mg_bullet_enemy(self, arbiter, mg_bullet_pair, enemy_pair):
            print("Detected a collision between MG bullet object {} hitbox {} and Enemy object {} hitbox {}".format(
                mg_bullet_pair.body, mg_bullet_pair.hitbox, enemy_pair.body, enemy_pair.hitbox))

            if arbiter.phase == CollisionPhase.begin:
                enemy = enemy_pair.body
                enemy.hp -= 10
                # add the blood splatter animation to the scene
                self.scene.root.add_child(Node(z_index=900,
                                               transition=NodeSpriteTransition(
                                                   registry.global_controllers.assets_controller.blood_splatter_frames,
                                                   duration=140),
                                               position=enemy.position, rotation=mg_bullet_pair.body.rotation + math.pi,
                                               lifetime=140))
                # add a random bloodstain - make smaller ones more likely since it's a small arms hit :)
                self.scene.root.add_child(Node(z_index=1, sprite=random.choices(
                    registry.global_controllers.assets_controller.bloodstain_imgs, weights=[5, 3, 1, 0.5])[0],
                                               position=enemy.position, rotation=mg_bullet_pair.body.rotation + math.pi,
                                               lifetime=random.randint(20000, 40000)))
                if enemy.hp <= 0:
                    # show death animation
                    self.scene.root.add_child(Node(z_index=1,
                                                   transition=NodeSpriteTransition(random.choice(
                                                       registry.global_controllers.assets_controller.enemy_death_frames),
                                                       duration=450),
                                                   position=enemy.position, rotation=enemy.rotation,
                                                   origin_alignment=Alignment.right,
                                                   lifetime=random.randint(10000, 20000)))
                    # remove enemy node from the scene
                    self.scene.enemies_controller.remove_enemy(enemy)
                else:
                    enemy.stagger()

                mg_bullet_pair.body.delete()  # remove the bullet from the scene
                return 0 # tell the engine to ignore this collision

The bullet-enemy collision handling logic is rather self-explanatory but let's highlight a few things

First, note that we remove objects from the scene at the end of the function. Remember that when a :code:`delete()`
is called on an object we can no longer use its properties, even if we only want to read them!

Next, notice :code:`return 0`. This tells the engine to ignore the collision effects. Normally, the bullet
(kinematic body node) would push the enemy (dynamic body node), but we don't want this to happen - we just want the
bullet to be destroyed on collision and we apply 'stagger'.

Run the game and enjoy shooting at enemies with machine gun, blood splatters and bodies falling down :)


Static BodyNodes
~~~~~~~~~~~~~~~~

We won't add any static BodyNodes to the game, but they're the simplest form of nodes: they can collide with other
objects but they themselves don't move. Use static BodyNodes when you're sure that an object won't transform in any
way (move, scale or rotate). Using static BodyNodes instead of dynamic/kinematic BodyNodes with no velocity improves
the performance.


Applying velocity to BodyNodes manually
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Let's implement a simple AI for our enemies. Let's make each enemy be in one of the two modes:

* Moving to a waypoint - we'll pick a random point on the screen and enemy will move towards it, when it reaches it we'll randomize another point
* Moving towards player - enemy will simply move towards player's current position in a straight line

Let's define an enum:

.. code-block:: python
    :caption: common/enums.py

    class EnemyMovementMode(enum.Enum):
        MoveToWaypoint = 1
        MoveToPlayer = 2

Then, let's add damping (a drag force working in entire space) to slow down enemies when they're moving freely
due to collisions impulses (eg from Force gun bullet)

.. code-block:: python
    :caption: scenes/gameplay.py

    # inside __init__:
    self.space = SpaceNode(damping=0.3)


Next, let's modify the :code:`Enemy` class:

.. code-block:: python
    :caption: objects/enemy.py

    import random
    from common.enums import EnemyMovementMode

    class Enemy(BodyNode):

        def __init__(self, position, hp=100, *args, **kwargs):
            # ....... rest of the function  .......

            # 75% enemies will move towards player and 25% will move randomly
            if random.randint(0, 100) < 75:
                self.movement_mode = EnemyMovementMode.MoveToPlayer
            else:
                self.movement_mode = EnemyMovementMode.MoveToWaypoint
            self.current_waypoint = None  # for those which move to a waypoint, we'll keep its corrdinates here
            self.randomize_new_waypoint()  # and randomize new waypoint

            self.acceleration_per_second = 300  # how fast will enemy accelerate
            self.max_velocity = random.randint(75, 125)  # we'll make enemy stop accelerating if velocity is above this value

        # ........ other methods ......

        def randomize_new_waypoint(self):
            self.current_waypoint = Vector(random.randint(50, settings.VIEWPORT_WIDTH-50),
                                           random.randint(50, settings.VIEWPORT_HEIGHT-50))

Finally, let's implement the movement logic in the :code:`EnemiesController` class

.. code-block:: python
    :caption: controllers/enemies_controller.py

    from common.enums import EnemyMovementMode

    class EnemiesController:
        # ....... rest of the class ....

        def update(self, dt):
            player_pos = self.scene.player_controller.player.position

            for enemy in self.enemies:
                # handle enemy stagger time and stagger recovery
                if enemy.stagger_time_left > 0:
                    enemy.stagger_time_left -= dt
                    if enemy.stagger_time_left <= 0:
                        enemy.recover_from_stagger()

                # handle enemy movement
                if enemy.movement_mode == EnemyMovementMode.MoveToWaypoint:
                    # rotate towards the current waypoint:
                    enemy.rotation_degrees = (enemy.current_waypoint - enemy.position).to_angle_degrees()
                    # # if we're less than 10 units from the waypoint, we randomize a new one!
                    if (enemy.current_waypoint - enemy.position).length() <= 10:
                        enemy.randomize_new_waypoint()
                elif enemy.movement_mode == EnemyMovementMode.MoveToPlayer:
                    # rotate towards the player:
                    enemy.rotation_degrees = (player_pos - enemy.position).to_angle_degrees()
                else:
                    raise Exception('Unknown enemy movement mode: {}'.format(enemy.movement_mode))

                # if enemy velocity is lower than max velocity, then increment velocity. Otherwise do nothing - the enemy
                # will be a freely moving object until the damping slows it down below max speed
                if enemy.velocity.length() < enemy.max_velocity:
                    # increment the velocity
                    enemy.velocity += Vector.from_angle_degrees(enemy.rotation_degrees).normalize()*\
                                      (enemy.acceleration_per_second*dt/1000)



Run the game and check it out. 75% of the enemies will walk towards the player while the other ones will wander
randomly. What we're doing here is we accelerate enemies by incrementing their velocity every frame (as discussed
before we're taking using dt in the formula to make it independent from the frame duration). We stop the velocity
incremantation if enemy velocity exceeds the max value. When they're above max velocity they will behave as freely
moving objects and the drag force in the environment ("damping") will slow them down until they're below the max
speed and start accelerating again.

An interesting effect of this model is inertia. Enemies can't change movement direction immediately where they stand,
they need to decelerate and accelerate again. To lower the inertia you may increase the acceleration speed. For
the freely moving enemies you may increase damping. Feel free to experiment with different values.


Applying impulses
~~~~~~~~~~~~~~~~~

Sometimes we don't want to apply velocity each frame. Instead we want to generate a single impulse that will affect
object's velocity just once. A good example is the explosion that can push objects back. Let's illustrate this
on the final weapon we'll have in the game: a grenade launcher. We want the grenade launcher to have the following features:

* Slow rate of fire (cooldown time of 1 second)
* Grenade exploding on collision with enemy, showing explosion animation
* Explosion dealing damage to all enemies in some radius, the further from the explosion center, the less damage dealt
* Explosion pushing all enemies in some radius, the further from the explosion center, the weaker the push back impulse
* We want pushing force to be a single-frame "impulse" applied to velocity, not some force applied each frame.

Let's get to it.

First, let's implement the grenade launcher bullet and grenade shooting logic. It is very similar to the
machine gun logic, just using different sprite and a different hitbox shape for bullet, and a bigger cooldown time.

.. code-block:: python
    :caption: objects/bullets/grenade_launcher_bullet.py

    import random
    from kaa.physics import BodyNodeType, HitboxNode, BodyNode
    from kaa.geometry import Circle
    import registry
    import settings
    from common.enums import HitboxMask


    class GrenadeLauncherBullet(BodyNode):

        def __init__(self, *args, **kwargs):
            super().__init__(sprite=registry.global_controllers.assets_controller.grenade_launcher_bullet_img,
                             z_index=30,
                             body_type=BodyNodeType.kinematic,  # as we want to handle collision effects on our own
                             lifetime=5000,  # will be removed from the scene automatically after 5 secs
                             rotation_degrees=random.uniform(0, 360),  # a random rotation between 0 and 360 degs
                             *args, **kwargs)
            self.add_child(HitboxNode(shape=Circle(radius=6),  # circular hitbox
                  mask=HitboxMask.bullet,  # we are bullet
                  collision_mask=HitboxMask.enemy,  # want to collide with objects whose mask is enemy
                  trigger_id=settings.COLLISION_TRIGGER_GRENADE_LAUNCHER_BULLET  # used when registering collision handler function
                  ))


.. code-block:: python
    :caption: objects/weapons/grenade_launcher.py

    import registry
    import settings
    import random
    from objects.bullets.grenade_launcher_bullet import GrenadeLauncherBullet
    from objects.weapons.base import WeaponBase
    from kaa.geometry import Vector


    class GrenadeLauncher(WeaponBase):

        def __init__(self):
            # node's properties
            super().__init__(sprite=registry.global_controllers.assets_controller.grenade_launcher_img)

        def shoot_bullet(self):
            bullet_position = self.get_initial_bullet_position()
            bullet_velocity = Vector.from_angle_degrees(self.parent.rotation_degrees) * settings.GRENADE_LAUNCHER_BULLET_SPEED
            self.scene.space.add_child(GrenadeLauncherBullet(position=bullet_position, velocity=bullet_velocity))
            # reset cooldown time
            self.cooldown_time_remaining =  self.get_cooldown_time()

        def get_cooldown_time(self):
            return 1.0


Then, let's write a function that will apply explosion effects, such as dealing damage and pushing enemies back
Here's where we reset enemy velocity thus generating an impulse which will push them back away from the explosion
center.

.. code-block:: python
    :caption: controllers/enemies_controller.py

    import random
    import registry
    import math
    from common.enums import EnemyMovementMode
    from objects.enemy import Enemy
    from kaa.geometry import Vector, Alignment
    from kaa.nodes import Node

    class EnemiesController:

    # ..... rest of the class ....

        def apply_explosion_effects(self, explosion_center, damage_at_center=100, blast_radius=200,
                                    pushback_force_at_center=500, pushback_radius=300):
            enemies_to_remove = []
            for enemy in self.enemies:
                # get the distance to the explosion
                distance_to_explosion = enemy.position.distance(explosion_center)

                # if within pushback radius...
                if distance_to_explosion<=pushback_radius:
                    # calculate pushback value, the further from the center, the smaller it is
                    pushback_force_val = pushback_force_at_center * (1 - (distance_to_explosion/pushback_radius))
                    # apply the pushback force by resetting enemy velocity
                    enemy.velocity = (enemy.position-explosion_center).normalize()*pushback_force_val

                # if within blast radius...
                if distance_to_explosion<=blast_radius:
                    # calculate damage, the further from the center, the smaller it is
                    damage = damage_at_center * (1 - (distance_to_explosion/blast_radius))
                    # apply damage
                    enemy.hp -= int(damage)
                    # add the blood splatter animation over the enemy
                    self.scene.root.add_child(Node(z_index=900,
                                                   transition=NodeSpriteTransition(
                                                       registry.global_controllers.assets_controller.blood_splatter_frames,
                                                       duration=140),
                                                   position=enemy.position, rotation=(enemy.position-explosion_center).to_angle() + math.pi,
                                                   lifetime=140))

                    if enemy.hp < 0:  # IZ DED!
                        # show the death animation (pick random sprite from few animations we have loaded from one png file)
                        self.scene.root.add_child(Node(z_index=1,
                                                       transition=NodeSpriteTransition(random.choice(
                                                           registry.global_controllers.assets_controller.enemy_death_frames),
                                                           duration=450),
                                                       position=enemy.position, rotation=enemy.rotation,
                                                       origin_alignment=Alignment.right,
                                                       lifetime=random.randint(10000,20000)))
                        # mark enemy for removal:
                        enemies_to_remove.append(enemy)

            # removed killed enemies
            for dead_enemy in enemies_to_remove:
                self.remove_enemy(dead_enemy)


Finally let's write a collision handler that will show explosion animation and call the :code:`apply_explosion_effect`
function we've just written.

.. code-block:: python
    :caption: controllers/collisions_controller.py

    class CollisionsController:

        def __init__(self, scene):

            # ....... rest of the function .........

            self.space.set_collision_handler(settings.COLLISION_TRIGGER_GRENADE_LAUNCHER_BULLET, settings.COLLISION_TRIGGER_ENEMY,
                                             self.on_collision_grenade_enemy)

        # ...... rest of the class .......

        def on_collision_grenade_enemy(self, arbiter, grenade_pair, enemy_pair):

            if arbiter.phase == CollisionPhase.begin:
                # show explosion animation
                self.scene.root.add_child(Node(transition=NodeSpriteTransition(
                    registry.global_controllers.assets_controller.explosion_frames, duration=12*75),
                    position=grenade_pair.body.position, z_index=1000, lifetime=12*75))
                # apply explosion effects to enemies (deal damage & push them back)
                self.scene.enemies_controller.apply_explosion_effects(grenade_pair.body.position)

                grenade_pair.body.delete()  # remove the grenade from the scene
                return 0

Run the game, spawn a lot of enemies by pressing SPACE and have fun with the grenade launcher :) Be sure to verify
they're being pushed back by the explosion and taking damage!

That concludes chapter 5. Let's :doc:`move on to chapter 6 </tutorial/part06>`, where we'll add some music and
sound effects to our game.