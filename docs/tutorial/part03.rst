Part 3: Organizing the game code
================================

We've learned how to add objects to the nodes tree (draw them on the screen), how to transform them (move, rotate, scale),
add child nodes to other nodes and how to use animations. Let's start writing the actual game!

The game will be a top-down shooter with 3 weapons: machine gun, grenade launcher and force gun (will
shoot non-lethal bullets which will push enemies away) and one type of enemy (a zombie). Enemies will have a basic AI with
two behavior patterns: walk towards the player or just walk towards randomly selected point. We will implement
some animations such as explosions and blood splatters. We'll use kaa's physics system to detect collisions between
bullets and enemies as well as between characters in the game (player and enemies).  We'll add some sound effects and
music for a better experience. We will also learn how to draw text and how to control a camera.
Finally, we'll learn how to add more scenes, such as main screen or pause screen and how to switch between them.

It would not look good if we put all that stuff in main.py, so let's create a better structure for the game files and folders first.
We'll also clean up the code we wrote before.

Before we begin
~~~~~~~~~~~~~~~

From this point on we're writing the actual game and the tutorial will have a lot of code in form of snippets.

Be aware that there will be two types of code examples:

1) A general example that explains a mechanism existing in the code:

.. code-block:: python

    def foo()
        print('Hello world')

2) An actual code of the game we're coding. Those code snippets will have a blue header bar telling you which file
you should put the code in. For example, this code should be put in :code:`folder/subfolder/foo.py`

.. code-block:: python
    :caption: folder/subfolder/foo.py

    def bar():
        print('hello sailor!')

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
                base.py
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

settings.py is a config file for our game

registry.py is a module to store global variables - we'll be able to import them from just everywhere in the game code.

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

Let's create a stub of a Gameplay scene in :code:`scenes/gameplay.py`

.. code-block:: python
    :caption: scenes/gameplay.py

    from kaa.engine import Scene

    class GameplayScene(Scene):

        def __init__(self):
            super().__init__()

        def update(self, dt):
            pass


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

Our main.py looks very pro now! Run the game to make sure it works. You should see an empty, black screen.
Press Alt+F4 to close it.

Load assets just once, from one place, and make them visible from everywhere
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Proper assets management is very important. In Part 2 of the tutorial we have created Sprite objects
inside Scene's __init__. It might work OK in a small game, but in the long run it's not a good idea because some scenes can be destroyed
and created again. If we load assets inside scene's __init__ - we would re-load the same assets files from disk each time scene is reset (e.g. when
player starts a new game).

Scene's :code:`__init__` should only create Nodes needed to initialize the scene. Sprites and other assets-related
objects are immutable, so should be created only once, when the game starts. That's what our :code:`AssetsController`
class is for. Let's edit the :code:`assets_controller.py` file:

.. code-block:: python
    :caption: controllers/assets_controller.py

    import os
    from kaa.sprites import Sprite, split_spritesheet
    from kaa.geometry import Vector

    class AssetsController:

        def __init__(self):
            # Load images:
            self.background_img = Sprite(os.path.join('assets', 'gfx', 'background.png'))
            self.title_screen_background_img = Sprite(os.path.join('assets', 'gfx', 'title-screen.png'))
            self.player_img = Sprite(os.path.join('assets', 'gfx', 'player.png'))
            self.machine_gun_img = Sprite(os.path.join('assets', 'gfx', 'machine-gun.png'))
            self.force_gun_img = Sprite(os.path.join('assets', 'gfx', 'force-gun.png'))
            self.grenade_launcher_img = Sprite(os.path.join('assets', 'gfx', 'grenade-launcher.png'))
            self.machine_gun_bullet_img = Sprite(os.path.join('assets', 'gfx', 'machine-gun-bullet.png'))
            self.force_gun_bullet_img = Sprite(os.path.join('assets', 'gfx', 'force-gun-bullet.png'))
            self.grenade_launcher_bullet_img = Sprite(os.path.join('assets', 'gfx', 'grenade-launcher-bullet.png'))
            self.enemy_stagger_img = Sprite(os.path.join('assets', 'gfx', 'enemy-stagger.png'))
            # few variants of bloodstains, put them in the same list so we can pick them randomly later
            self.bloodstain_imgs = [Sprite(os.path.join('assets', 'gfx', f'bloodstain{i}.png')) for i in range(1, 5)]

            # Load spritesheets
            self.enemy_spritesheet = Sprite(os.path.join('assets', 'gfx', 'enemy.png'))
            self.blood_splatter_spritesheet = Sprite(os.path.join('assets', 'gfx', 'blood-splatter.png'))
            self.explosion_spritesheet = Sprite(os.path.join('assets', 'gfx', 'explosion.png'))
            # enemy-death.png has a few death animations, so make this a list
            self.enemy_death_spritesheet = Sprite(os.path.join('assets','gfx','enemy-death.png'))

            # use the spritesheets to create framesets
            self.enemy_frames = split_spritesheet(self.enemy_spritesheet, frame_dimensions=Vector(33, 74))
            self.blood_splatter_frames = split_spritesheet(self.blood_splatter_spritesheet, frame_dimensions=Vector(50, 50))
            self.explosion_frames = split_spritesheet(self.explosion_spritesheet, frame_dimensions=Vector(100, 100), frames_count=75)

            self.enemy_death_frames = [
                split_spritesheet(self.enemy_death_spritesheet.crop(Vector(0, i*74), Vector(103*9, 74)),
                                  frame_dimensions=Vector(103, 74)) for i in range(0, 5)
            ]

The code is using things we've learned in previous chapter: creating a new Sprite, using crop method and using
split_spritesheet to prepare individual animation frames which we'll use later.

Feel free to review the contents of the :code:`assets/gfx` folder to verify we're loading the files correctly.

As stated above, we want the assets controller to initialize just once and then be globally visible.
Let's modify the :code:`main.py` in a following way:

.. code-block:: python
    :caption: main.py

    import registry
    from controllers.assets_controller import AssetsController

    with Engine(virtual_resolution=Vector(settings.VIEWPORT_WIDTH, settings.VIEWPORT_HEIGHT)) as engine:
        # initialize global controllers and keep them in the registry
        registry.global_controllers.assets_controller = AssetsController()
        # ..... rest of the code .....

It's good to keep scenes in a global registry too
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It's practical to store scene instances in the registry as well. That will make them accessible from
anywhere in the code. Let's modify that part of :code:`main.py` where GameplayScene is created:

.. code-block:: python
    :caption: main.py

    with Engine(virtual_resolution=Vector(settings.VIEWPORT_WIDTH, settings.VIEWPORT_HEIGHT)) as engine:
        # ..... previous code .....
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

        def __init__(self):
            # node's properties
            super().__init__(sprite=registry.global_controllers.assets_controller.machine_gun_img)

.. code-block:: python
    :caption: objects/weapons/force_gun.py

    import registry
    from objects.weapons.base import WeaponBase


    class ForceGun(WeaponBase):

        def __init__(self):
            # node's properties
            super().__init__(sprite=registry.global_controllers.assets_controller.force_gun_img)


.. code-block:: python
    :caption: objects/weapons/grenade_launcher.py

    import registry
    from objects.weapons.base import WeaponBase


    class GrenadeLauncher(WeaponBase):

        def __init__(self):
            # node's properties
            super().__init__(sprite=registry.global_controllers.assets_controller.grenade_launcher_img)


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

    import enum


    class WeaponType(enum.Enum):
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
            if self.current_weapon is not None:
                self.current_weapon.delete()  # delete the weapon's node from the scene
            if new_weapon == WeaponType.MachineGun:
                weapon = MachineGun()  # position relative to the Player
            elif new_weapon == WeaponType.GrenadeLauncher:
                weapon = GrenadeLauncher()
            elif new_weapon == WeaponType.ForceGun:
                weapon = ForceGun()
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
            self.scene.root.add_child(self.player)

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

Finally, let's run the game! We should see the player in the middle of the screen, holding the machine gun.

Finally, let's add some nicer background (black background is not fun).

.. code-block:: python
    :caption: scenes/gameplay.py

    import registry
    import settings
    from kaa.nodes import Node
    from kaa.geometry import Vector
    # ... other imports...

    class GameplayScene(Scene):

        def __init__(self):
            super().__init__()
            self.root.add_child(Node(sprite=registry.global_controllers.assets_controller.background_img,
                                     position=Vector(settings.VIEWPORT_WIDTH/2, settings.VIEWPORT_HEIGHT/2),
                                     z_index=0))
            # .... rest of the function ....

Run the game and enjoy the sights.

Let's move on to the :doc:`Part 4 of the tutorial </tutorial/part04>` where we'll learn how to handle input from mouse and
keyboard.