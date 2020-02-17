:mod:`engine` --- Engine and Scenes: The core of your game
==========================================================
.. module:: engine
    :synopsis: Engine and Scenes: The core of your game

:class:`Engine` reference
-------------------------

Constructor:

.. class:: Engine(virtual_resolution, virtual_resolution_mode=None, show_window=True)

    Engine instance is the first object you need to create to run the game.

    Parameters:

    * virtual_resolution - required. A :class:`geometry.Vector` with width/height of the virtual resolution (see :ref:`virtual_resolution <Engine.virtual_resolution>` for more information).
    * virtual_resolution_mode - a :class:`VirtualResolutionMode` value.
    * show_window - if you pass False, the engine will start with a hidden window. Useful if you want to run kaa related stuff in a non-windowed environment, for example, when you want to run unit tests from a terminal window. Or when you want to start the game with a hidden window and show it manually later.

    Game's 'entry point' is the :meth:`Engine.run` method which takes in a :class:`Scene` instance as a required
    parameter. Calling :code:`run` will make the kaa engine run the scene, i.e. call its :meth:`Scene.update` method
    in a loop.

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

    Be sure to check out the :ref:`virtual_resolution <Engine.virtual_resolution>` documentation for more information on
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
    your game. If you run the game in a window larger than the declared virtual resolution, the engine will stretch the
    game's frame buffer (actual draw area). If you run it in a window smaller than declared virtual resolution, the
    engine will shrink it.

    There are different policies available for stretching and shrinking the area. You can control it by setting the
    :ref:`virtual_resolution_mode <Engine.virtual_resolution_mode>` property.

    Although it is possible to change the virtual resolution (even as the game is running), we don't recommend it
    unless you have a good reason to do that.


.. _Engine.virtual_resolution_mode:
.. attribute:: Engine.virtual_resolution_mode

    Gets or sets virtual resolution mode. See :class:`VirtualResolutionMode` documentation for a list of possible values.

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

.. _Engine.renderer:
.. attribute:: Engine.renderer

    A get accessor to the :class:`Renderer` object which exposes kaa renderer properties such as
    frame buffer clear color. Check out the :class:`Renderer` documentation for a list of all available properties.

    .. code-block:: python

        from kaa.engine import get_engine
        from kaa.colors import Color

        engine = get_engine()
        engine.renderer.clear_color = Color(1, 0, 0, 1) #set the clear color to red (dunno why we'd do that but we can!)

.. _Engine.audio:
.. attribute:: Engine.audio

    A get accessor to the :class:`AudioManager` object which exposes global audio properties
    such as the master volume for sound effects or music. See the :class:`AudioManager` documentation for a
    list of all available properties.

    .. code-block:: python

        from kaa.engine import get_engine

        engine = get_engine()
        engine.audio.master_sound_volume = 0.5 # 50% of the max volume (sfx)
        engine.audio.master_music_volume = 0.75 # 75% of the max volume (music)
        engine.audio.mixing_channels = 100 # set number of max sounds we'll be able to play simultaneously

Instance methods:

.. method:: Engine.change_scene(new_scene)

    Use this method to change the active scene. Only one scene can be active at a time.

    Active scene is being rendered by the renedrer and has its :code:`update()` method called.

    A non-avtive scene remains 'frozen': it does not lose state (no objects are ever removed by deactivating a Scene)
    but its :code:`update()` method is not being called and nothing is being rendered.

    Example of having two scenes and toggling between them:

    .. code-block:: python

        from kaa.input import Keycode
        from kaa.engine import Engine, Scene
        from kaa.colors import Color
        from kaa.geometry import Vector
        from kaa.fonts import TextNode, Font
        import os

        SCENES = {}

        class TitleScreenScene(Scene):

            def __init__(self, font):
                super().__init__()
                self.root.add_child(TextNode(font=font, font_size=30, position=Vector(500, 500),
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

            def __init__(self, font):
                super().__init__()
                self.label = TextNode(font=font, font_size=30, position=Vector(1000, 500), color=Color(1, 0, 0, 1),
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
            font = Font(os.path.join('assets', 'fonts', 'DejaVuSans.ttf'))  # MUST create all kaa objects inside engine context!
            SCENES['title_screen_scene'] = TitleScreenScene(font)
            SCENES['gameplay_scene'] = GameplayScene(font)
            engine.window.fullscreen = True
            engine.run(SCENES['title_screen_scene'])


.. method:: Engine.get_displays()

    Returns a list of all available :class:`Display` objects (monitors) present in the system. See the
    :class:`Display` documentation for a full list of display properties avaiable.

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

    Starts running a scene instance, by calling its :code:`update` method in a loop. You'll need to call this method
    just once, to run the first scene of your game. To change between scenes use the :meth:`Engine.change_scene` method.

.. method:: Engine.stop()

    Description TODO....

:class:`Scene` reference
------------------------

Constructor:

.. class:: Scene()

    The Scene instance is a place where all your in-game objects will live. You should write your own scene class by
    inheriting from this type. Scene main features are:

    * Each Scene must define a :meth:`Scene.update` method which will be called by the engine on every frame.
    * Use the :meth:`Node.add_child` method on Scene's :ref:`root node <Scene.root>` to add objects (Nodes) to the Scene. :doc:`Read more about Nodes </reference/nodes>`.
    * Use the :ref:`input <Scene.input>` property to access :class:`input.InputManager` which:

      * exposes a lot of methods to actively check for input from mouse, keyboard, controllers etc.
      * includes an events list which occurred during the current frame (mouse, keyboard, controllers, music, etc.)

    * Use the :ref:`camera <Scene.camera>` property to control the camera

    The Scene constructor does not take any parameters. As stated above, you should never instantiate a Scene directly
    but write your own scene class that inherit from it. Use the Scene's constructor to add initial objects to the scene

    .. code-block:: python

        from kaa.engine import Scene

        def MyScene(Scene):

            def __init__(self, *args, **kwargs):
                super().__init__(*args, **kwargs)
                # initialize the scene here, e.g. add some initial objects to the scene...

            def update(self, dt):
                pass

        with Engine(virtual_resolution=Vector(800, 600)) as engine:
            scene = MyScene()
            engine.run(scene)



Instance properties:

.. _Scene.camera:
.. attribute:: Scene.camera

    A get accessor to the :class:`Camera` object which contains properties and methods for manipulating the camera
    (moving, rotating, etc.). See the :class:`Camera` documentation for a full list of available properties and methods.

    .. code-block:: python

        from kaa.engine import Scene
        from kaa.geometry import Vector

        def MyScene(Scene):

            def __init__(self):
                self.camera.position = Vector(-200, 400)
                self.camera.rotation_degrees = 45
                self.camera.scale = Vector(2.0, 2.0)


.. _Scene.engine:
.. attribute:: Scene.engine

    Returns :class:`Engine` instance.

.. _Scene.input:
.. attribute:: Scene.input

    A get accessor to the :class:`input.InputManager` object which offers methods and properties to actively check for
    input from mouse, keyboard, controllers etc. It also allows to consume events published by
    those devices, by the system or by the kaa engine itself. Check out the
    :class:`input.InputManager` documentation for a full list of available features.

    .. code-block:: python

        from kaa.engine import Scene
        from kaa.geometry import Vector
        from kaa.input import Keycode, MouseButton

        def MyScene(Scene):

            def update(self, dt):

                # actively check if a "W" key is pressed
                if self.input.is_pressed(Keycode.w):
                    # .... do something
                # consume all events that occurred during the frame:
                for event in self.input.events():
                    # .... do something


.. _Scene.root:
.. attribute:: Scene.root

    All objects which you will add to the scene (or remove from the scene) are called Nodes. Nodes can
    form a tree-like structure, that is: a Node can have many child Nodes, and exacly one parent Node. Each Scene has
    a "root" node, accessible by this property.

    Refer to the :doc:`nodes </reference/nodes>` documentation for more information on how the nodes work.

    .. code-block:: python

        from kaa.engine import Scene
        from kaa.nodes import Node
        from kaa.sprites import Sprite

        def MyScene(Scene):

            def __init__(self):
                super().__init()
                self.arrow_sprite = Sprite(os.path.join('assets', 'gfx', 'arrow.png'))
                self.arrow_node = Node(sprite=self.arrow_sprite, position=Vector(200, 200))
                self.root.add_child(self.arrow_node)


.. _Scene.time:
.. attribute:: Scene.time

    Returns a lifetime of a Scene, in miliseconds. The counter is being incremented only if the Scene is active.


Instance methods:

.. method:: Scene.update(dt)

    An update method is called every frame. The dt parameter is a previous frame duration, in miliseconds.
    Most of your game logic will live inside the update method.

    .. code-block:: python

        from kaa.engine import Scene
        from kaa.nodes import Node
        from kaa.sprites import Sprite

        def MyScene(Scene):

            def __init__(self):
                super().__init()
                self.arrow_sprite = Sprite(os.path.join('assets', 'gfx', 'arrow.png'))
                self.arrow_node = Node(sprite=self.arrow_sprite, position=Vector(200, 200))
                self.root.add_child(self.arrow_node)

            def update(self, dt)
                self.arrow_node.rotation_degrees += 20 * dt / 1000  # rotate the arrow 20 degrees per second, clockwise


.. method:: Scene.on_enter()

    This method is called when the scene is activated (either by :meth:`Engine.run`, or by :meth:`Engine.change_scene`)
    giving you opportunity to write some logic each time that happens.

.. method:: Scene.on_exit()

    Same as :meth:`Scene.on_enter` but is called just before the scene gets deactivated via the
    :meth:`Engine.change_scene`.


:class:`Window` reference
-------------------------

.. class:: Window

Window object exposes properties and methods for the game window. Changing the :code:`fullscreen` flag will make the
game run in a fullscreen or windowed mode. If you run the game in the windowed mode, you can resize or reposition the
window using properties such as :code:`position`, :code:`size` or methods such as :code:`center`.

Instance properties:

.. attribute:: Window.fullscreen

Gets or sets the fullscreen mode. Expects bool value. Setting fullscreen to :code:`True` will remove the
window's borders and title bar and stretch it to fit the entire screen.

It is possible to toggle between fullscreen and windowed mode as the game is running.

    .. code-block:: python

        from kaa.engine import get_engine

        engine = get_engine()
        engine.window.fullscreen = True

.. attribute:: Window.size

Gets or sets the size of the window, using :class:`geometry.Vector`.

Note that if you set the :code:`fullscreen` to :code:`True` the window will not only resize automatically to fit the
entire screen but will also drop its borders and the top bar. Resizing the window programatically makes most sense if the
game already runs in the windowed mode (with :code:`window.fullscreen=False`).

    .. code-block:: python

        from kaa.engine import get_engine
        from kaa.geometry import Vector

        engine = get_engine()
        engine.window.size = Vector(500, 300)  # sets the window size to 500x300


.. attribute:: Window.position

Gets or sets the position of the window on the screen, using :class:`geometry.Vector`. Passing Vector(0,0) will
align the window with the top left corner of the screen.

Just like with the :code:`size` attribute, changing window position makes sense only if using windowed mode
(:code:`window.fullscreen=False`).

    .. code-block:: python

        from kaa.engine import get_engine
        from kaa.geometry import Vector

        engine = get_engine()
        engine.window.position = Vector(0, 0)


.. attribute:: Window.title

Gets or sets the title of the window.

    .. code-block:: python

        from kaa.engine import get_engine

        engine = get_engine()
        engine.window.title = "Git Gud or Get Rekt!"


Instance methods:

.. method:: Window.center()

    Positions the window in the center of the screen. Makes most sense if using windowed
    mode (:code:`window.fullscreen=False`)

.. method:: Window.maximize()

    Maximizes the window.

.. method:: Window.minimize()

    Minimizes the window.

.. method:: Window.show()

    Shows the window.

.. method:: Window.hide()

    Hides the window.

.. method:: Window.restore()

    Restores the window. TODO: what does that mean?


:class:`Renderer` reference
---------------------------

.. class:: Renderer

Renderer object can be accessed via :ref:`Engine.renderer <Engine.renderer>` property. It exposes renderer properties.

Instance properties:

.. attribute:: Renderer.clear_color

Gets or sets the clear color (:class:`colors.Color`) for the drawable area (the frame buffer).

An example of 800x600 frame buffer colored in green, running in the 1200x1000 window using :code:`no_stretch` mode:

    .. code-block:: python

        from kaa.engine import Engine, Scene, VirtualResolutionMode
        from kaa.colors import Color
        from kaa.geometry import Vector

        class MyScene(Scene):

            def update(self, dt):
                # handles system event of pressing "X" or ALT+F4 to close the window:
                for event in self.input.events():
                    if event.system and event.system.quit:
                        self.engine.quit()

        with Engine(virtual_resolution=Vector(800, 600),
                    virtual_resolution_mode=VirtualResolutionMode.no_stretch) as engine:

            scene = MyScene()
            engine.window.size = Vector(1200, 1000)
            engine.renderer.clear_color = Color(0, 1.0, 0, 1) # RGBA format
            engine.run(scene)

.. _engine.AudioManager:

:class:`AudioManager` reference
-------------------------------

.. class:: AudioManager

Audio Manager gives access to global audio settings, such as master sound volume. Audio Manager can be accessed
via the :class:`Engine.audio <Engine.audio>` property on the Engine instance.

Instance properties:

.. attribute:: AudioManager.master_volume

Gets or sets the master volume level for sounds and music, using value between 0 (0% volume) and 1 (100% volume).

Master volume affects sound effects and music tracks volume played with :meth:`audio.Sound.play()` and
:meth:`audio.Music.play()` respectively.

.. code-block:: python

    from kaa.engine import get_engine

    # somwhere inside Scene....
    self.engine.master_volume = 1.0  # sets master volume to 100%
    my_sound.play(volume=0.7)  # plays a sound with 70% volume
    self.engine.master_volume = 0.1  # sets master volume to 10%
    my_sound.play(volume=0.5)  # pays a sound with 5% volume (50% sound volume * 10% master volume = 5% final volume)


.. attribute:: AudioManager.master_sound_volume

Gets or sets the default volume level for sound effects. Using value between 0 (0% volume) and 1 (100% volume).
Master sound volume level affects sound effects volume played with :meth:`audio.Sound.play()`

.. code-block:: python

    from kaa.engine import get_engine

    # somwhere inside Scene class ....
    self.engine.master_sound_volume = 1.0  # sets master sfx volume to 100%
    my_sound.play(volume=0.7)  # plays a sound with 70% volume
    self.engine.master_volume = 0.1  # sets master volume to 10%
    my_sound.play(volume=0.5)  # pays a sound with 5% volume (50% sound volume * 10% master sfx volume = 5% final volume)


.. attribute:: AudioManager.master_music_volume

Gets or sets the default master volume level for music. Using value between 0 (0% volume) and 1 (100% volume).
Master music volume level affects music tracks volume played with :meth:`audio.Music.play()`.

.. code-block:: python

    from kaa.engine import get_engine

    # somwhere inside Scene....
    self.engine.master_music_volume = 1.0  # sets master music volume to 100%
    my_music.play(volume=0.7)  # plays a music track with 70% volume
    self.engine.master_music_volume = 0.1  # sets master music volume to 10%
    my_music.play(volume=0.5)  # pays music track with 5% volume (50% sound volume * 10% master music volume = 5% final volume)


.. _AudioManager.mixing_channels:
.. attribute:: AudioManager.mixing_channels

Gets or sets the maximum number of sound effects that can be played simultaneously with :meth:`audio.Sound.play()`.
Note that you can never play more than one music track simultaneously.


:class:`Display` reference
-------------------------------

.. class:: Display

Stores display device properties. A list of Display objects can be obtained by calling :meth:`Engine.get_displays()`.

Instance Properties:

.. attribute:: Display.index

Read only. Returns display index (integer).

.. attribute:: Display.name

Read only. Returns display name.

.. attribute:: Display.position

Read only. Returns display position as :class:`geometry.Vector`.

.. attribute:: Display.size

Read only. Returns display resolution as :class:`geometry.Vector`.


:class:`Camera` reference
-------------------------------

.. class:: Camera

A camera projects the image of the 2D scene onto the screen. You can move, rotate or scale the camera by setting its
properties.

.. note::

    There isn't a "global" camera - each Scene has its own. Since only
    one scene can run at a time, only active Scene's camera is being used to project the image.

Instance properties:

.. attribute:: Camera.position

    Gets or sets the camera position, using `geometry.Vector`.

    .. code-block:: python

        from kaa.geometry import Vector

        # somewhere inside Scene:
        self.camera.position = Vector(123.45, 678.9)

.. attribute:: Camera.rotation

    Gets or sets the camera rotation, in radians

    .. code-block:: python

        from kaa.geometry import Vector
        import math

        # somewhere inside Scene:
        self.camera.rotation = math.pi / 4

.. attribute:: Camera.rotation_degrees

    Gets or sets the camera rotation, in degrees

    .. code-block:: python

        from kaa.geometry import Vector
        import math

        # somewhere inside Scene:
        self.camera.rotation_degrees = 180 # show the scene upside down


.. attribute:: Camera.scale

    Gets or sets the scale for the camera (using `geometry.Vector`). In other words, manipulating this property
    allows for a zoom-in / zoom-out effects. Each axis (x and y) can be manipulated independently, so if you
    zoom in on X axis and zoom out on Y the image projected by the camera will appear stretched.

    .. code-block:: python

        from kaa.geometry import Vector
        import math

        # somewhere inside Scene:
        self.camera.scale= Vector(1.5, 1.5) # 50% zoom-in


Instance methods:

.. method:: Camera.unproject_position(position)

Takes a position (`geometry.Vector`), applies all camera transformations (position, scale, rotation) to that position
and returns the result. Usfule when you have applied some transformations to the camera and want to know the actual
position of given point (e.g. mouse position)

Full example:

    .. code-block:: python

        import os
        from kaa.engine import Engine, Scene
        from kaa.geometry import Vector
        from kaa.input import MouseButton
        from kaa.fonts import TextNode, Font


        class MyScene(Scene):

            def __init__(self, font):
                self.root.add_child(TextNode(font=font, font_size=30, position=Vector(400, 300), z_index=10,
                    text="This is a static text, it never rotates itself. Click to rotate the camera 45 degrees"))

            def update(self, dt):

                for event in self.input.events():
                    if event.system and event.system.quit:
                        self.engine.quit()
                    if event.mouse and event.mouse.is_pressing(MouseButton.left):
                        position = self.input.mouse.get_position()
                        unproj_position = self.camera.unproject_position(position)
                        print(f'Before the camera rotation: Mouse position {position} -> unproject -> {unproj_position}')
                        # let's now rotate the camera 45 degrees and check the result
                        self.camera.rotation_degrees += 45
                        unproj_position = self.camera.unproject_position(position)
                        print(f'After camera rotation: Mouse position {position} -> unproject -> {unproj_position}')


        with Engine(virtual_resolution=Vector(800,600)) as engine:
            font = Font(os.path.join('assets', 'fonts', 'DejaVuSans.ttf'))
            engine.run(MyScene(font))



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