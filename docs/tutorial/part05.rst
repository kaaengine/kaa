Part 5: Physics
===============

In this chapter we will implement physics in the game. We will add enemies which we will be able to shoot with 3 weapons:

* Machine gun - will shoot regular bullets, which will deal damage to enemies they hit.
* Grenade launcher - grenades will explode on collision (triggering already known explosion animation) and deal damage to enemies in certain radius and apply force pushing enemies away
* Force gun - will shoot a large bullets which won't do any damage, just freely interact with enemies and with each other


Understanding SpaceNode, BodyNode and HitboxNode
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We need to learn about 3 new types of nodes which we need to simulate the physics in the game:

* :code:`SpaceNode` - it represents physical simulation environment. Typically, a scene will need just one SpaceNode. SpaceNode has the following properties:

 * :code:`gravity` - a Vector. A force affecting all BodyNodes added to that SpaceNode. Default is zero vector (no gravity).
 * :code:`damping` - a float between 0 and 1, representing friction forces in the simulation space. The smaller it is, the faster a freely moving objects will slow down. Default is 1 (no damping)
 * width/height dimensions are not meanigful for the SpaceNode - it always covers the whole scene

* :code:`BodyNode` - represents a physical body. It has the same properties as Node (in fact it inherits from the Node class) but adds a few new ones, such as:

  * :code:`mass` - a float, heavier objects will hit harder :)
  * :code:`velocity` - a Vector. Vector's rotation is objects' movement direction and vector's length is how fast the object is moving. Default is zero vector (no velocity).
  * :code:`angular_velocity` - a float. How fast the object is rotating around its center. Positive and negative values represent clockwise and anti-clockwise rotation speed respectively. Default is zero.
  * :code:`moment` - short explanation TBD
  * and few others.

* :code:`HitboxNode` - represents an area of a BodyNode which can collide with other HitboxNodes. A BodyNode can have multiple HitboxNodes. A BodyNode without HitboxNodes has all physical properties calculated normally but won't collide with anything! HitboxNode properties include:

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
    Kaa surfaces a lot of Chipmunk methods and properties, but not all yet. New features are coming soon!


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

    PLAYER_SPEED = 150
    FORCE_GUN_BULLET_SPEED = 300
    MACHINE_GUN_BULLET_SPEED = 500
    GRENADE_LAUNCHER_BULLET_SPEED = 400

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
            # create a hitbox and add it as a child node to the Player
            self.add_child(HitboxNode(
                shape=Polygon([Vector(-8, -19), Vector(8, -19), Vector(8, 19), Vector(-8, 19), Vector(-8, -19)]),
                mask=HitboxMask.player,
                collision_mask=HitboxMask.enemy,
                trigger_id=settings.COLLISION_TRIGGER_PLAYER
            ))
            # .......... rest of the function ...........

As we can see, we've added a rectangular hitbox, with mask 'player' and told the engine it should collide with hitboxes
whose mask is 'enemy' - we will add those soon. We have also set a trigger_id for a hitbox (basically, a custom integer
number) - the meaning of this ID will also become clear soon.

A few important remarks about Polygons of hitboxes:

* they must be closed (the first and the last point must be the same)
* `they must be convex <https://www.google.pl/search?q=convex+shape&tbm=isch&source=univ&sa=X&ved=2ahUKEwjr9pnJ5M7lAhW9AhAIHeVXCRMQsAR6BAgJEAE&biw=1920&bih=967>`_
* Polygon's coordinates are relative to the node origin

Run the game and make sure everything works. The gameplay did not change at all, but our hero is now a physical object!

Remember the naive implementation of player movement (setting player's position on WSAD keys pressed)? From physic's
engine standpoint such manual change of position would mean that the player is teleporting. It doesn't make sense.
Instead, let's set player's :code:`velocity` on pressing WSAD keys and let the physics engine calculate the position!

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

adding more BodyNodes
~~~~~~~~~~~~~~~~~~~~~

We have the player with a gun in hand but where are the enemies? Let's add some. First, let's write an :code:`Enemy`
class.

.. code-block:: python
    :caption: objects/enemy.py

    from kaa.physics import BodyNodeType, BodyNode, HitboxNode
    from kaa.geometry import Vector, Polygon
    from common.enums import HitboxMask
    import registry
    import settings


    class Enemy(BodyNode):

        def __init__(self, position, hp=100):
            # node's properties
            super().__init__(body_type=BodyNodeType.dynamic, mass=1,
                             z_index=10, sprite=registry.global_controllers.assets_controller.enemy_img, position=position)
            # create a hitbox and add it as a child node to the Enemy
            self.add_child(HitboxNode(
                shape=Polygon([Vector(-8, -19), Vector(8, -19), Vector(8, 19), Vector(-8, 19), Vector(-8, -19)]),
                mask=HitboxMask.enemy,
                collision_mask=HitboxMask.all,
                trigger_id=settings.COLLISION_TRIGGER_ENEMY,
            ))
            # custom properties
            self.hp = hp


Next, let's write :code:`EnemiesController` class which will have methods such as :code:`add_enemy` and
:code:`remove_enemy`. It will also have an :code:`update()` function where we will implement enemies AI. We shall
add some enemies to the scene in the :code:`__init__`.

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

Run the game. We have the enemies on the scene! They're not moving yet but they're regular physical objects, as you
run into them they collide with the player and with each other. Since we're not applying any forces to enemies yet
it looks as if they were on an ice rink :)

Let's add a feature of spawning enemies by pressing SPACE. The enemy shall be spawned at current mouse pointer position.

.. code-block:: python
    :caption: controllers/player_controller.py

    class PlayerController:

        def update(self, dt):
            # .... rest of the function
            for event in self.scene.input.events():
                # .... other key pressing checks ....
                elif event.is_pressing(Keycode.space):
                    self.scene.enemies_controller.add_enemy(Enemy(position=self.scene.input.get_mouse_position(), rotation_degrees=random.randint(0,360)))

Run the game and see how you can spawn them! Cool isn't it?

You can take a moment to make some experiments, for instance:
* try setting :code:`damping` on the :code:`SpaceNode` (in scenes/gameplay.py) to a very low value e.g. 0.01 and see how it works! Values greater than 1 will result in a funny effect pushed objects actually accelerating!
* try giving enemies different masses (e.g. randomly) and observe how it affects them as they collide with each other.

We know know everything to implement shooting the Force Gun - it will basically shoot a dynamic BodyNode objects
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
                             mass=random.uniform(0.5, 2),  # a random mass,
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

        def __init__(self, position):
            # node's properties
            super().__init__(sprite=registry.global_controllers.assets_controller.force_gun_img, position=position)

        def shoot_bullet(self):
            bullet_position = self.get_initial_bullet_position()
            bullet_velocity = Vector.from_angle_degrees(self.parent.rotation_degrees) * settings.FORCE_GUN_BULLET_SPEED
            self.scene.space.add_child(ForceGunBullet(position=bullet_position, velocity=bullet_velocity))
            # reset cooldown time
            self.cooldown_time_remaining =  self.get_cooldown_time()

        def get_cooldown_time(self):
            return 250

The maths in the :code:`shoot_bullet` and :code:`get_initial_bullet_position` is fairly simple, but let's highlight
a few things here. :code:`get_initial_bullet_position` basically returns a player's position offset by 50 pixels
towards the direction where the player is rotated (where he points his gun). This way the bullet will spawn at the end of the weapon's barrel.
Spawning it in the center of the player would not look good! We're using Vector's method `from_angle_degrees` to create a
normal (length of 1) vector rotated in the direction of the player, multiply by 50 and add player position. :code:`shoot_bullet`
is even easier, it just adds a bullet velocity, again, creating vector rotated at direction where player is pointing
his gun and then multiplying by bullet speed. Finally we set the cooldown time to weapon's value.

The last thing is to wire it all up in the :code:`PlayerController` inside the :code:`update()` function:

.. code-block:: python
    :caption: controllers/player_controller.py

    from kaa.input import Keycode, Mousecode

    class PlayerController:
        # .... rest of the class ....

        def update(self, dt):
            # .... rest of the function ....

            # Handle weapon logic
            if self.player.current_weapon is not None:
                # decrease weapons cooldown time by dt
                self.player.current_weapon.cooldown_time_remaining -= dt
                # if left mouse button pressed and weapon is ready to shoot, then, well, shoot a bullet!
                if self.scene.input.is_pressed(Mousecode.left) and self.player.current_weapon.cooldown_time_remaining<0:
                    self.player.current_weapon.shoot_bullet()

Run the game! You can now shoot them with the force gun! How cool is it?

Did you get :code:`NotImplementedError`? It's because other weapons are not implemented, just look at the code! Change
to ForceGun by pressing 3 and then try shooting. Better? Much better!

The game starts looking like a playable thing. We can move around, spawn enemies (space) and shoot our Force Gun at them.

kinematic BodyNodes
~~~~~~~~~~~~~~~~~~~


static BodyNodes
~~~~~~~~~~~~~~~~

