Part 3: Organizing the game code
================================

We've learned how to add objects to the nodes tree (draw them on the screen), how to transform them (move, rotate, scale),
add child nodes to other nodes and how to use animations. Let's start writing the actual game!

The game will be a top-down shooter with 3 weapons: machine gun, grenade launcher and force gun (will
shoot non-lethal bullets which will push enemies away) and one type of enemy (a zombie). Enemies will have a basic AI with
two behavior patterns: walk towards the player or just walk towards randomly selected point. We will implement
some animations such as explosions of blood splatters. We'll use kaa's physics system to detect collisions between
bullets and enemies as well as between characters in the game (player and enemies).  We'll use some sound effects and
music to improve the experience. We will also learn how to control a camera. Finally, we'll learn how to add more scenes, such as main screen
or pause screen and how to switch between them.

It would not look good if we put all that stuff in main.py, so let's create a better structure for the game files and folders first.
We'll also clean up the code we wrote before.

Structure of directories & files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Let's start with creating the proper folders and files hierarchy structure for our game. Create the following python packages
and files structure.

.. code-block:: none

    my_game/
        assets/
            ... all assets folder content here...
        common/
            __init__.py
            enums.py
        controllers/
            __init__.py
            assets_controller.py
            enemies_controller.py
            explosions_controller.py
            collisions_controller.py
            player_controller.py
        objects/
            weapons/
                __init__.py
                force_gun.py
                grenade_launcher.py
                machine_gun.py
            bullets/
                __init__.py
                force_gun_bullet.py
                grenade_launcher_bullet.py
                machine_gun_bullet.py
            __init__.py
            player.py
            enemy.py
            explosion.py
        scenes/
            __init__.py
            gameplay.py
            pause.py
            title_screen.py
        main.py
        registry.py
        settings.py

Controllers package will store classes to handle the game logic and manage objects.

Objects package will hold classes for different types of objects that will appear in the game.
To keep it clean we'll have one .py file for one object type.

Scenes package will hold scenes. Yes, our game will eventually have many scenes, we will get there later in the tutorial.

settings.py will be a config file for our game

registry.py will be a module to store class instances that need to be imported from just everywhere in the game code.

.. note::
    The organization above is just a suggestion, not some rigid convention required by the kaa engine.
    You can work out your own patterns for organizing the game files and folders, and use whatever works
    best for you. You don't need to follow naming conventions used in this tutorial. You can call controllers
    'managers', or re-name the entry module main.py to something else. Whatever works for you.

Storing global variables and objects
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Let's start with settings.py:

.. code-block:: python
    :caption: settings.py

    # Let's use full HD as a base resolution for our game!
    VIEWPORT_WIDTH = 1920
    VIEWPORT_HEIGHT = 1080

Then registry.py:

.. code-block:: python
    :caption: registry.py

    class Registry: # serious name, to look like a pro. In fact won't do anything - will just serve as a bag for objects :))
        pass

    global_controllers = Registry()
    scenes = Registry()

Keep scenes in separate .py files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Then, let's create empty Gameplay scene, and add the already known window event handling code:

.. code-block:: python
    :caption: scenes/gameplay.py

    from kaa.engine import Scene

    class GameplayScene(Scene):

        def __init__(self):
            super().__init__()

        def update(self, dt):

            for event in self.input.events():
                if event.is_quit():
                    self.engine.quit()

Keep the main.py clean
~~~~~~~~~~~~~~~~~~~~~~

Finally, let's now clean up the main.py. Generally, the main module should have as little lines as possible because
we want the entire game logic to be in controllers, objects and scenes classes.

.. code-block:: python
    :caption: main.py

    from kaa.engine import Engine
    from kaa.geometry import Vector
    import settings
    from scenes.gameplay import GameplayScene

    with Engine(virtual_resolution=Vector(settings.VIEWPORT_WIDTH, settings.VIEWPORT_HEIGHT)) as engine:
        # set window to fullscreen mode
        engine.window.fullscreen = True
        # initialize and run the scene
        gameplay_scene = GameplayScene()
        engine.run(gameplay_scene)

Our main.py looks very professional now! Run the game to make sure it works. You should see an empty, black screen.
Press Alt+F4 to close it.

Load assets just once, from one place, and make them visible from everywhere
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Proper assets management is very important. In Part 2 of the tutorial we have created Sprite objects
inside Scene's __init__. It might work OK in a small game, but in the long run it's not a good idea because some scenes can be destroyed
and created again. If we load assets inside scene's __init__ - we would re-load the same assets files from disk each time scene is reset (e.g. when
player starts a new game).

Scene's :code:`__init__` should only create Nodes needed to initialize the scene. Sprites and other assets-related
objects should be created only once, when the game starts. That's what our :code:`AssetsController` class is for.
Let's edit the :code:`assets_controller.py` file:

.. code-block:: python
    :caption: controllers/assets_controller.py

    import os
    from kaa.sprites import Sprite


    class AssetsController:

        def __init__(self):
            # Load all Images:
            self.player_img = Sprite(os.path.join('assets', 'gfx', 'player.png'))


As stated above, we want the assets controller to initialize just once and then be globally visible.
Let's modify the :code:`main.py` in a following way:

.. code-block:: python
    :caption: main.py

    with Engine(virtual_resolution=Vector(settings.VIEWPORT_WIDTH, settings.VIEWPORT_HEIGHT)) as engine:
        # initialize global controllers and keep them in the registry
        registry.global_controllers.assets_controller = AssetsController()
        ..... rest of the code .....


It's good to keep scenes in a global registry too
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It's practical to store scene instances in the registry as well. That will make them accessible from
anywhere in the code. Let's modify the :code:`main.py` in a following way:

.. code-block:: python
    :caption: main.py

    with Engine(virtual_resolution=Vector(settings.VIEWPORT_WIDTH, settings.VIEWPORT_HEIGHT)) as engine:
        ..... previous code .....
        # initialize scenes and keep them in the registry
        registry.scenes.gameplay_scene = GameplayScene()
        engine.run(registry.scenes.gameplay_scene)


Write classes for your in-game objects and inherit from kaa.Node
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It would look much better if we could add a :code:`<Player>` object to a scene, not just some generic :code:`<Node>`, right? Let's do this.

Let's write a Player class that extends kaa Node. :code:`<Player>` instance will represent a character controlled
by the player.

.. code-block:: python
    :caption: objects/player.py

    from kaa.nodes import Node
    import registry


    class Player(Node):

        def __init__(self, position, hp=100):
            # node's properties
            super().__init__(z_index=10, sprite=registry.global_controllers.assets_controller.player_img, position=position)
            # custom properties
            self.hp = hp
            self.current_weapon = None

By extending Node we can introduce our custom properties, such as player's hit points. Also, notice how we
imported and used our :code:`registry.py` to access the sprite stored in the assets controller.

Let's create classes for weapons the same way. They won't have any custom properties for now. We'll have a base
class, called WeaponBase extending Node, and all our wepons will then extend the WeaponBase.

.. code-block:: python
    :caption: objects/weapons/base.py

    from kaa.nodes import Node


    class WeaponBase(Node):

        def __init__(self, *args, **kwargs):
            super().__init__(z_index=20, *args, **kwargs)


.. code-block:: python
    :caption: objects/weapons/machine_gun.py

    import registry
    from objects.weapons.base import WeaponBase


    class MachineGun(WeaponBase):

        def __init__(self, position):
            # node's properties
            super().__init__(sprite=registry.global_controllers.assets_controller.machine_gun_img, position=position)

.. code-block:: python
    :caption: objects/weapons/force_gun.py

    import registry
    from objects.weapons.base import WeaponBase


    class ForceGun(WeaponBase):

        def __init__(self, position):
            # node's properties
            super().__init__(sprite=registry.global_controllers.assets_controller.force_gun_img, position=position)


.. code-block:: python
    :caption: objects/weapons/grenade_launcher.py

    import registry
    from objects.weapons.base import WeaponBase


    class GrenadeLauncher(WeaponBase):

        def __init__(self, position):
            # node's properties
            super().__init__(sprite=registry.global_controllers.assets_controller.grenade_launcher_img, position=position)


Implement object-related logic inside object classes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We need Player to hold a weapon. Let's implement a :code:`change_weapon` method in the :code:`Player` class. This method
will be responsible for putting weapon into player's hands :) or speaking more technically: it will replace weapon's
Node (which will be Player's child node) with a new one and remember currently selected weapon.

To hide the internals, we want the caller to only pass a simple enumerated value indicating new weapon, like so:

.. code-block:: python

    player.change_weapon(WeaponType.GrenadeLauncher)

Let's create weapon types enum first:

.. code-block:: python
    :caption: common/enums.py

    from enum import Enum


    class WeaponType(Enum):
        MachineGun = 1
        GrenadeLauncher = 2
        ForceGun = 3

And then add the change_weapon method in the :code:`Player` class:

.. code-block:: python
    :caption: objects/player.py

    from kaa.geometry import Vector
    from common.enums import WeaponType
    from objects.weapons.force_gun import ForceGun
    from objects.weapons.grenade_launcher import GrenadeLauncher
    from objects.weapons.machine_gun import MachineGun

    class Player(Node):

        def change_weapon(self, new_weapon):
            if self.change_weapon is not None:
                self.current_weapon.delete()  # delete the weapon's node from the scene
            if new_weapon == WeaponType.MachineGun:
                weapon = MachineGun(position=Vector(0, 0))  # position relative to the Player
            elif new_weapon == WeaponType.GrenadeLauncher:
                weapon = GrenadeLauncher(position=Vector(0, 0))
            elif new_weapon == WeaponType.ForceGun:
                weapon = ForceGun(position=Vector(0, 0))
            else:
                raise Exception('Unknown weapon type: {}'.format(new_weapon))
            self.add_child(weapon)  # add the weapon node as player's child node (to make the weapon move and rotate together with the player)
            self.current_weapon = weapon  # remember the current weapon


Let's make the player start with machine gun. Add this line at the end of :code:`Player`'s :code:`__init__`:

.. code-block:: python
    :caption: objects/player.py

    self.change_weapon(WeaponType.MachineGun)

Implement higher-tier logic in controller classes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Let's now write a controller class to manage a Player. Generally we want the controller classes to be used
for higher-tier logic such as interactions between in-game objects and other classes (controllers or other in-game
objects), managing collections, handling input, and so on...

Another important thing we want controllers to do is to add initial objects to the scene. Let's start with exactly that:

.. code-block:: python
    :caption: controllers/player_controller.py

    import settings
    from objects.player import Player
    from kaa.geometry import Vector

    class PlayerController:

        def __init__(self, scene):
            self.scene = scene
            self.player = Player(position=Vector(settings.VIEWPORT_WIDTH/2, settings.VIEWPORT_HEIGHT/2))
            self.scene.add_child(self.player)

.. note::
    As your code base will grow and you'll add more objects and controllers you will sometimes face a dillema where to
    put your code: in the object class, in the controller class or maybe even directly in the
    scene class? We can't give you precise answers here, just use common sense and general good programming practices
    for keeping your code clean.


Let's add the player controller to the scene:

.. code-block:: python
    :caption: scenes/gameplay.py

    from controllers.player_controller import PlayerController


    class GameplayScene(Scene):

        def __init__(self):
            super().__init__()
            self.player_controller = PlayerController(self)

Finally, let's run the game! We should see the player in the middle of the screen, holding the machine gun. But wait!
The weapon is drawn centrally on the player's head. Let's move it few pixels to the right. Modify that fragment
of the code in :code:`player.py`:

.. code-block:: python
    :caption: objects/player.py

    if new_weapon == WeaponType.MachineGun:
        weapon = MachineGun(position=Vector(20, 0))  # position relative to the Player
    elif new_weapon == WeaponType.GrenadeLauncher:
        weapon = GrenadeLauncher(position=Vector(23, 0))
    elif new_weapon == WeaponType.ForceGun:
        weapon = ForceGun(position=Vector(27.5, 0))

We moved weapons to the right (relative to player). Longer weapon sprites will be moved bit more.

.. note::
    There's a better way of positioning those weapons, not depending on hardcoding pixel offset based on the
    weapon's sprite width. Can you find it? Hint: use origin_alignment!

That should work. Run the game and see the player holding the machine gun properly, everything looking better.

Let's move on to the :doc:`Part 4 of the tutorial </tutorial/part04>` where we'll learn how to handle input from mouse and
keyboard.