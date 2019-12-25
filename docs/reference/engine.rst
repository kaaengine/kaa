:mod:`engine` --- Engine and Scenes: The core of your game
==========================================================
.. module:: engine
    :synopsis: Engine and Scenes: The core of your game

:class:`Engine` reference
-------------------------

Engine instance is the main object of your game. You should create just one Engine instance.

Constructor:

.. class:: Engine(virtual_resolution, virtual_resolution_mode=None, show_window=True)

    * virtual_resolution - required. A :class:`geometry.Vector` with width/height of the virtual resolution (see :ref:`virtual_resolution <Engine.virtual_resolution>` for more information).
    * virtual_resolution_mode - a :class:`VirtualResolutionMode` value.
    * show_window - if you pass False, the engine will start with a hidden window. This is useful mainly if you want to run kaa related stuff in a non-windowed environment, for example, when you want to run unit tests from a terminal window.

    A typical "Hello World" kaa game (showing just an empty window) would look like the following:

    .. code-block:: python

        from kaa.engine import Engine, Scene
        from kaa.geometry import Vector

        class MyScene(Scene):

            def update(self, dt):
                # handles system event of pressing "X" or ALT+F4 to close the window:
                for event in self.input.events():
                    if event.system and event.system.quit:
                        self.engine.quit()

        with Engine(virtual_resolution=Vector(800, 600)) as engine:
            scene = MyScene()
            engine.run(scene)


    To run the game in a fullscreen Full HD sized window, using 800x600 frame buffer:

    .. code-block:: python

        with Engine(virtual_resolution=Vector(800, 600)) as engine:
            scene = MyScene()
            engine.window.size = Vector(1920, 1080)
            engine.window.fullscreen = True
            engine.run(scene)

    To run the game in a 1200x1000 window, using 800x600 frame buffer size, without stretching the frame buffer to
    fit the whole window size, giving window a title, and setting fame buffer clear color to green:

    .. code-block:: python

        from kaa.engine import Engine, Scene, VirtualResolutionMode
        from kaa.colors import Color
        from kaa.geometry import Vector

        with Engine(virtual_resolution=Vector(800, 600),
                    virtual_resolution_mode=VirtualResolutionMode.no_stretch) as engine:

            scene = MyScene()
            engine.window.size = Vector(1200, 1000)
            engine.window.fullscreen = False
            engine.window.title = "Welcome to the wonderful world of kaa engine"
            engine.renderer.clear_color = Color(0, 1.0, 0, 1) # RGBA format
            engine.run(scene)

    Be sure to check out the :class:`VirtualResolutionMode` documentation for more information on
    what virtual resolution concept is and how it is different than window size.

Instance properties:

.. attribute:: Engine.current_scene

    Read only. Returns an active :class:`Scene`. More complex games will have multiple scenes but the engine can run
    only one scene at a time. Only the active scene will have its :code:`update()` method called by the engine.

    Use :meth:`Engine.change_scene` method to change an active scene.

.. _Engine.virtual_resolution:
.. attribute:: Engine.virtual_resolution

    Gets or sets the virtual resolution size. Expects :class:`geometry.Vector` as a value, representing
    resolution's width and height.

    When writing a game you would like to have a consistent way of referencing coordinates, independent from the screen
    resolution the game is running on. So for example when you draw some image on position (100, 200) you would like it
    to always be the same (100, 200) position on the 1366x768 laptop screen, 1920x1060 full HD monitor or any other
    of `dozens display resolutions out there. <https://en.wikipedia.org/wiki/Display_resolution#/media/File:Vector_Video_Standards8.svg>`_

    That's where virtual resolution concept comes in. You (typically) declare a virtual resolution for your game just
    once, when initializing the engine, and the engine will always use exactly this resolution when you draw stuff in
    your game. If you run the game in a window larger than declared virtual resolution, the engine will stretch the
    game's frame buffer (actual draw area). If you run it in a window smaller than declared virtual resolution, the
    engine will shrink it.

    There are different policies available for stretching and shrinking the area. You can control it by setting the
    :ref:`virtual_resolution_mode <Engine.virtual_resolution_mode>` property.

    Although it is possible to change the virtual resolution (even as the game is running), we don't recommend it
    unless you have a good reason to do that.

.. _Engine.virtual_resolution_mode:
.. attribute:: Engine.virtual_resolution_mode

    Gets or sets virtual resolution mode. See :class:`VirtualResolutionMode` for a list of possible values.

    It is possible to change the virtual resolution mode, even as the game is running.

    .. code-block:: python

        from kaa.engine import get_engine, VirtualResolutionMode

        engine = get_engine()
        engine.virtual_resolution_mode = VirtualResolutionMode.aggresive_stretch


.. attribute:: Engine.window

    A get accessor to the :class:`Window` object which exposes game window properties such as window size,
    title, or fullscreen flag and allows to change them.

    .. note::

       It is perfectly safe to change the window size or fullscreen mode, even in the game runtime.

    Check out the :class:`Window` documentation for a list of all available properties and methods.

    .. code-block:: python

        from kaa.engine import get_engine
        from kaa.geometry import Vector

        engine = get_engine()
        engine.window.title = "Hello world"
        engine.window.fullscreen = False
        engine.window.size = Vector(1920, 1080)

.. attribute:: Engine.renderer

    A get accessor to the :class:`Renderer` object which exposes kaa renderer properties such as
    frame buffer clear color. Check out the :class:`Renderer` for a list of all available properties.

    .. code-block:: python

        from kaa.engine import get_engine
        from kaa.colors import Color

        engine = get_engine()
        engine.renderer.clear_color = Color(1, 0, 0, 1) #set the clear color to red (dunno why we'd do that but we can!)

.. attribute:: Engine.audio

    A get accessor to the :class:`AudioManager` object which exposes global audio properties
    such as the master volume for sound effects or music. See the :class:`AudioManager>` for a
    list of all available properties.

    .. code-block:: python

        from kaa.engine import get_engine

        engine = get_engine()
        engine.audio.master_sound_volume = 0.5 # 50% of the max volume (sfx)
        engine.audio.master_music_volume = 0.75 # 75% of the max volume (music)
        engine.audio.mixing_channels = 100 # set number of max sounds we'll be able to play simultaneously

Instance methods:

.. method:: Engine.change_scene(new_scene)

    Use this method to change the active scene. Only one scene can be active at a time. All non-active scenes
    are 'frozen' (their :code:`update()` method is not called).

    Example of having two scenes and toggling between them:

    .. code-block:: python

        from kaa.input import Keycode
        from kaa.engine import Engine, Scene
        from kaa.colors import Color
        from kaa.geometry import Vector
        from kaa.fonts import TextNode, Font
        import os

        SCENES = {}
        FONT = None


        class TitleScreenScene(Scene):

            def __init__(self):
                super().__init__()
                self.root.add_child(TextNode(font=FONT, font_size=30, position=Vector(500, 500),
                                             text="This is the title screen, press enter to start the game.",
                                             color=Color(1, 1, 0, 1)))

            def update(self, dt):
                for event in self.input.events():
                    if event.system and event.system.quit:
                        self.engine.quit()
                    if event.keyboard:
                        if event.keyboard.is_pressing(Keycode.return_):
                            self.engine.change_scene(SCENES['gameplay_scene'])


        class GameplayScene(Scene):

            def __init__(self):
                super().__init__()
                self.label = TextNode(font=FONT, font_size=30, position=Vector(1000, 500), color=Color(1, 0, 0, 1),
                                      text="This is gameplay, press q to get back to the title screen. I'm rotating BTW.")
                self.root.add_child(self.label)

            def update(self, dt):
                for event in self.input.events():
                    if event.system and event.system.quit:
                        self.engine.quit()
                    if event.keyboard:
                        if event.keyboard.is_pressing(Keycode.q):
                            self.engine.change_scene(SCENES['title_screen_scene'])
                self.label.rotation_degrees += dt*20 / 1000


        with Engine(virtual_resolution=Vector(1920, 1080)) as engine:
            FONT = Font(os.path.join('assets', 'fonts', 'DejaVuSans.ttf'))  # MUST create all kaa objects inside engine context!
            SCENES['title_screen_scene'] = TitleScreenScene()
            SCENES['gameplay_scene'] = GameplayScene()
            engine.window.fullscreen = True
            engine.run(SCENES['title_screen_scene'])


.. method:: Engine.get_displays()

    Returns a list of all available displays (monitors) present in the system, along with their properties such as
    resolution. See the :class:`Display` documentation for a list of all available properties.

    .. code-block:: python

        from kaa.engine import get_engine

        engine = get_engine()
        for display in engine.get_displays():
            print(display)

.. method:: Engine.quit()

    Destroys the engine and closes the window. Call this method when the player wants to leave the game or to
    handle the quit event received from the system on closing the window (e.g. by ALT+F4 or pressing "X")

    .. code-block:: python

        from kaa.engine import Scene
        from kaa.input import Keycode

        class MyScene(Scene):

            def update(self, dt):

                for event in self.input.events():
                    if event.system and event.system.quit:
                        # handle the system event of pressing "X" or ALT+F4 to close the window:
                        self.engine.quit()

                    if event.keyboard and event.keyboard.is_pressing(Keycode.q):
                        # quit the game on pressing the Q key
                        self.engine.quit()


.. method:: Engine.run(scene)

    Starts running a scene instance. You'll need to call this method just once, to run the first scene of your game.
    To change between scenes use the :meth:`Engine.change_scene` method.

.. method:: Engine.stop()

    Description TODO....

:class:`Scene` reference
------------------------

The Scene instance is a place where all your in-game objects will live. You should write your own scene class by
inheriting from this type. Most common scene features are:

* Each Scene must implement a :meth:`Scene.update` function which will be called by the engine on every frame.
* Use the :ref:`root <Scene.root>` property to add objects (Nodes) to the Scene. :doc:`Read more about Nodes </reference/nodes>`.
* Use the :ref:`input <Scene.input>` property to access :class:`InputManager` which:

  * exposes a lot of methods to actively check for input from mouse, keyboard, controllers etc.
  * includes an events list which occurred during the current frame (mouse, keyboard, controllers, music, etc.)

* Use the :ref:`camera <Scene.camera>` property to control the camera

Constructor:

.. class:: Scene()

    The Scene constructor does not take any parameters.

Attributes:

.. _Scene.camera:
.. attribute:: Scene.camera

    A get accessor to the :class:`Camera` object which contains properties and methods for manipulating the camera
    (moving, rotating, etc.). See the :class:`Camera` documentation for a full list of properties and methods.

.. _Scene.engine:
.. attribute:: Scene.engine

    TODO

.. _Scene.input:
.. attribute:: Scene.input

    TODO

.. _Scene.root:
.. attribute:: Scene.root

    TODO

.. _Scene.time:
.. attribute:: Scene.time

    TODO



Instance methods:

.. method:: Scene.update()

    TODO

.. method:: Scene.on_enter()

    TODO

.. method:: Scene.on_exit()

    TODO

:class:`InputManager` reference
-------------------------------

.. class:: InputManager

Overview TODO

:class:`Window` reference
-------------------------

.. class:: Window

Overview TODO

Attributes:

.. attribute:: Window.size

    TODO

:class:`Renderer` reference
---------------------------

.. class:: Renderer

Overview TODO


.. _engine.AudioManager:

:class:`AudioManager` reference
-------------------------------

.. class:: AudioManager

Overview TODO

:class:`Display` reference
-------------------------------

.. class:: Display

Overview TODO

:class:`Camera` reference
-------------------------------

.. class:: Camera

Overview TODO


:class:`VirtualResolutionMode` reference
----------------------------------------

.. class:: VirtualResolutionMode

VirtualResolutionMode is an enum type which you can pass when creating the :class:`engine.Engine` instance.

It tells the engine how it should stretch the virtual resolution (set via the :code:`virtual_resolution` property).

* :code:`VirtualResolutionMode.adaptive_stretch` - the default mode. The drawable area will adapt to window size, maintaining aspect ratio and leaving black padded areas outside
* :code:`VirtualResolutionMode.aggresive_stretch` - the drawable area will always fill the entire window - aspect ratio may not be maintained while stretching.
* :code:`VirtualResolutionMode.no_stretch` - no stretching applied, leaving black padded areas if window is larger than virtual resolution size


:meth:`get_engine` reference
----------------------------

.. function:: get_engine

This function provides a convenient way of getting an engine instance from anywhere in your code.

    .. code-block:: python

        from kaa.engine import get_engine

        engine = get_engine()
