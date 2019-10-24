Part 3: Organizing the game code
================================

We've learned how to draw objects on the screen, transform them (move, rotate, scale) and use animations. Let's
start writing the actual game!

We don't want to put everything in main.py, so let's create a better structure for the game files and folders and clean
up the code we wrote before.

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
                machine_gun.py
                force_gun.py
            bullets/
                __init__.py
                machine_gun_bullet.py
                force_gun_bullet.py
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

.. code-block::
    :caption: settings.py

    # Let's use full HD as a base resolution for our game!
    VIEWPORT_WIDTH = 1920
    VIEWPORT_HEIGHT = 1080

Then registry.py:

.. code-block::
    :caption: registry.py

    class Registry: # serious name, to look like a pro. In fact won't do anything - will just serve as a bag for objects :))
        pass

    global_controllers = Registry()
    scenes = Registry()

Keep scenes in separate .py files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Then, let's create empty Gameplay scene, and add the already known window event handling code:

.. code-block::
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

.. code-block::
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

.. code-block::
    :caption: controllers/assets_controller.py

    import os
    from kaa.sprites import Sprite


    class AssetsController:

        def __init__(self):
            # Load all Images:
            self.player_img = Sprite(os.path.join('assets', 'gfx', 'player.png'))


As stated above, we want the assets controller to initialize just once and then be globally visible.
Let's modify the :code:`main.py` in a following way:

.. code-block::
    :caption: main.py

    with Engine(virtual_resolution=Vector(settings.VIEWPORT_WIDTH, settings.VIEWPORT_HEIGHT)) as engine:
        # initialize global controllers and keep them in the registry
        registry.global_controllers.assets_controller = AssetsController()
        ..... rest of the code .....


It's good to keep scenes in a global registry too
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It's practical to store scene instances in the registry as well. That will make them accessible from
anywhere in the code. Let's modify the :code:`main.py` in a following way:

.. code-block::
    :caption: main.py

    with Engine(virtual_resolution=Vector(settings.VIEWPORT_WIDTH, settings.VIEWPORT_HEIGHT)) as engine:
        ..... previous code .....
        # initialize scenes and keep them in the registry
        registry.scenes.gameplay_scene = GameplayScene()
        engine.run(registry.scenes.gameplay_scene)


Write classes for your in-game objects and inherit from kaa.Node
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It would much better if we could add a :code:`<Player>` object to a scene, not just some generic :code:`<Node>`, right? Let's do this.

Let's write a Player class that would extend kaa's Node. :code:`<Player>` instance will represent a character controlled
by the player.

.. code-block::
    :caption: objects/player.py

    pass

Move objects management logic to specialized classes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
