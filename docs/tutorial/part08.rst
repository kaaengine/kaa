Part 8: Working with multiple scenes
====================================

So far we have had just one Scene in our game, the :code:`GameplayScene`. Let's add two more: for the title screen
and for the pause screen. Even though we'll have 3 scenes created in the game, only one of them can be active at a time.
It means that only active scene will render its nodes on the screen, run the :code:`update()` loop and receive input
events. The other scenes will become "freezed" until one of them is activated again. Their :code:`update()` loops won't
be called, no input events will be published to them, no nodes present in those scenes will be drawn on the screen etc.

How to activate a new scene
~~~~~~~~~~~~~~~~~~~~~~~~~~~

To make another scene active, get an engine object first, and then call :code:`change_scene(new_scene)` method.

To get an engine:

.. code-block:: python

    from kaa.engine import get_engine
    engine = get_engine()
    engine.change_scene(some_new_scene)

Each scene has the engine object stored under :code:`self.engine` so you can get it from there as well:

.. code-block:: python

    # .... inside kaa.engine.Scene class method ....
    self.engine.change_scene(some_new_scene)

How to create a new scene
~~~~~~~~~~~~~~~~~~~~~~~~~

Let's write two more scenes:

* :code:`GameTitleScene` - Will be activated when the game starts. The scene will be a welcome screen, showing a logo and allowing to start the game or exit it.
* :code:`PauseScene` - Will be activated when pressing ESC during gameplay. Will show a simple screen allowing to abort game (return to title screen) or resume game (return to gameplay scene)


.. code-block:: python
    :caption: scenes/title_screen.py

    import registry
    import settings
    from kaa.engine import Scene
    from kaa.input import Keycode, Mousecode
    from kaa.nodes import Node
    from kaa.geometry import Vector, Alignment
    from kaa.fonts import TextNode


    class TitleScreenScene(Scene):

        def __init__(self):
            super().__init__()
            self.root.add_child(Node(sprite=registry.global_controllers.assets_controller.title_screen_background_img,
                                     z_index=0, position=Vector(0,0), origin_alignment=Alignment.top_left))
            self.root.add_child(TextNode(font=registry.global_controllers.assets_controller.font_2, font_size=30,
                                         position=Vector(settings.VIEWPORT_WIDTH/2, 500), text="Click to start the game",
                                         z_index=1, origin_alignment=Alignment.center))
            self.root.add_child(TextNode(font=registry.global_controllers.assets_controller.font_2, font_size=30,
                                         position=Vector(settings.VIEWPORT_WIDTH/2, 550), text="Press ESC to exit",
                                         z_index=1, origin_alignment=Alignment.center))
    def update(self, dt):

        for event in self.input.events():

            if event.system:
                if event.system.quit:
                    self.engine.quit()

            if event.keyboard:
                if event.keyboard.is_pressing(Keycode.escape):
                    self.engine.quit()

            if event.mouse:
                if event.mouse.is_pressing(MouseButton.left):
                    self.engine.change_scene(registry.scenes.gameplay_scene)

Nothing unusual here, just the stuff we already know: the scene is pretty static, with just a background image and
two labels. Mouse click changes the scene to gameplay and ESC quits the game. It won't work yet, because registry
object does not store gameplay_scene yet, but we'll get there.

For now, let's add the pause scene. It is very similar to the title screen scene:

.. code-block:: python
    :caption: scenes/pause.py

    import registry
    import settings
    from kaa.engine import Scene
    from kaa.input import Keycode
    from kaa.geometry import Vector, Alignment
    from kaa.fonts import TextNode


    class PauseScene(Scene):

        def __init__(self):
            super().__init__()
            self.root.add_child(TextNode(font=registry.global_controllers.assets_controller.font_2, font_size=40,
                                         position=Vector(settings.VIEWPORT_WIDTH/2, 300), text="GAME PAUSED",
                                         z_index=1, origin_alignment=Alignment.center))
            self.root.add_child(TextNode(font=registry.global_controllers.assets_controller.font_2, font_size=30,
                                         position=Vector(settings.VIEWPORT_WIDTH/2, 550), text="Press ESC to resume",
                                         z_index=1, origin_alignment=Alignment.center))
            self.root.add_child(TextNode(font=registry.global_controllers.assets_controller.font_2, font_size=30,
                                         position=Vector(settings.VIEWPORT_WIDTH/2, 650), text="Press q to abort",
                                         z_index=1, origin_alignment=Alignment.center))


        def update(self, dt):
            for event in self.input.events():
                if event.is_pressing(Keycode.escape):
                    self.engine.change_scene(registry.scenes.gameplay_scene)
                if event.is_pressing(Keycode.q):
                    self.engine.change_scene(registry.scenes.title_screen_scene)
                if event.is_quit():
                    self.engine.quit()


Let's now make a small modification to the :code:`GameplayScene` allowing to change scene to pause, when player
presses ESC.

.. code-block:: python
    :caption: scenes/gameplay.py

    def update(self, dt):
        # .... cut other code ....

        for event in self.input.events():
            # .... cut other code ....
            if event.keyboard:
                if event.keyboard.is_pressing(Keycode.escape):
                    self.engine.change_scene(registry.scenes.pause_scene)

Finally, let's create all our scenes in the :code:`main.py` and add them to the registry to make the :code:`change_scene`
calls work!

.. code-block:: python
    :caption: main.py

    from scenes.pause import PauseScene
    from scenes.title_screen import TitleScreenScene

    with Engine(virtual_resolution=Vector(settings.VIEWPORT_WIDTH, settings.VIEWPORT_HEIGHT)) as engine:
        # .... rest of the function ....

        # initialize scenes and remember them in the registry
        registry.scenes.gameplay_scene = GameplayScene()
        registry.scenes.title_screen_scene = TitleScreenScene()
        registry.scenes.pause_scene = PauseScene()
        engine.run(registry.scenes.title_screen_scene)


Run the game. Isn't it much better with all those different screens? I think it is!

Starting a new game
~~~~~~~~~~~~~~~~~~~

If you test the flow of the game, you'll notice the following bug: aborting game and then starting new game just returns to the
previous state of the scene: all monsters are where they were left, frag count is not reset and so on. It's because
:code:`change_scene` does not destroy scene state it just runs a new scene and freezes all other scenes, as we stated earlier.

A bug needs fixing! Let's refactor the :code:`TitleScreenScene` a little bit:

.. code-block:: python
    :caption: scenes/title_screen.py


    class TitleScreenScene(Scene):
        # .... rest of the class ....

        def start_new_game(self):
            registry.scenes.gameplay_scene = GameplayScene()
            self.engine.change_scene(registry.scenes.gameplay_scene)

    def update(self, dt):
        for event in self.input.events():
            # ... cut other code ...
            if event.mouse and event.mouse.is_pressing(Mousecode.left):
                self.start_new_game()


We simply create the new instance of GameplayScene before telling engine to change to that scene. Run the game
again and enjoy the full experience of multiple scenes :)

Scene's on_enter and on_exit methods
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Scene has two methods :code:`on_enter` and :code:`on_exit`. They're being used when you call :code:`change_scene` so
you can do some additional initialization or cleanup before the scene loads.

.. code-block:: python

    class Gameplay(Scene):

        def on_enter(self):
            # do something when active scene changes TO this scene.

        def on_exit(self):
            # do something when active scene changes FROM this scene.


Let's move on to :doc:`the next part of the tutorial </tutorial/part09>` where we'll learn few things about the camera.