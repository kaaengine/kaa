Part 1: Engine and window
=========================

By the end of this tutorial you will code a complete game: a top-down shooter with animations, physics, sounds,
basic AI, HUD display and multiple scenes. You will be surprised how easy and intuitive it is with the kaa engine.

With just about 400 lines of python code you'll build this game:

.. raw:: html

    <iframe width="1150" height="646" src="https://www.youtube.com/embed/PkX2RQNLYUs" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>


Parts 1 and 2 of the tutorial are explaining basic concepts of the engine - you shouldn't skip them, even if you're an
experienced developer. The actual game development starts in Part 3.

We encourage you to make experiments on your own during the tutorial. If you get lost in the process,
just check out the tutorial code - `it's available in this git repository <https://github.com/PawelRoman/kaa-tutorial>`_

Have fun!

Installing kaaengine
~~~~~~~~~~~~~~~~~~~~

To install kaaengine:

.. code-block:: none

    pip install kaaengine

**NOTE** Kaaengine requires python 3.X. The tutorial assumes you're using python 3.6.X or newer.

Hello world!
~~~~~~~~~~~~

To run a game you need to declare and create the first scene, initialize the engine and run the scene. Create a folder
for your game and create a file named main.py inside the folder. It will be an "entry point" of your game. Put
the following code inside main.py:

.. code-block:: python

    from kaa.engine import Engine, Scene
    from kaa.geometry import Vector


    class MyScene(Scene):

        def update(self, dt):  # this method is your game loop
            pass  # your game code will live here!

    if __name__ == "__main__":
        with Engine(virtual_resolution=Vector(800, 600)) as engine:
            my_scene = MyScene()  # create the scene
            engine.run(my_scene)  # run the scene


Start the game by running:

.. code-block:: none

    python main.py

You should see a 800x600 window with a black background. Congratulations, you got the game running!

Understanding virtual resolution
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Let's now explain what virtual resolution is and how it's different from window size. When writing a game you would
like to have a consistent way of referencing coordinates, independent from the screen resolution the game is running on.
So for example when you draw some image on position (100, 200) you would like it to always be the same (100, 200) position
on 1366x768 laptop screen, 1920x1060 full HD monitor or any other of `dozens display resolutions out there. <https://en.wikipedia.org/wiki/Display_resolution#/media/File:Vector_Video_Standards8.svg>`_

That's where virtual resolution concept comes in. You declare a resolution for your game just once, when initializing the
engine, and the engine will always use exactly this resolution. If you run the game in a window larger than declared
virtual resolution, the engine will stretch the game's frame buffer (actual draw area). If you run it in a window
smaller than declared virtual resolution, the engine will shrink it.

Let's test this feature by declaring window size different than the virtual resolution. Let's also tell the renderer to
paint the frame buffer with a different color so we can see the results.

Add the following imports to your code:

.. code-block:: python

    from kaa.colors import Color

Then modify the block where the engine is initialized:

.. code-block:: python

    with Engine(virtual_resolution=Vector(800, 600)) as engine:
        # set window properties
        engine.window.size = Vector(1000, 600)
        engine.window.title = "My first kaa game!"
        # set renderer's properties
        engine.renderer.clear_color = Color(0.1, 0.1, 0.1, 1)  # using RGBA with values between 0 and 1
        # create the scene and run it
        my_scene = MyScene()
        engine.run(my_scene)


Run the game again. This time you will see a 1000x600 window with a 800x600 area colored in light gray. The 800x600 area
is the frame buffer, or in other words: the area accessible for the engine to draw your game contents. The engine won't be able
to draw anything outside the frame buffer area. The size of the area is 800x600 because that's the virtual_resolution
we set when initializing the engine.

Try resizing the game window and see how the engine shrinks or stretches out the frame buffer area. As you may expect, anything your game
will draw inside the area will shrink or stretch accordingly.

You have probably noticed that the engine tries to maintain the aspect ratio (width to height proportions) of the grey drawable area.
We call this "adaptive stretch mode" - this is the default mode. It works like this:

.. code-block:: python

    from kaa.engine import VirtualResolutionMode

And then pass it when initalizing the engine:

.. code-block:: python

    with Engine(virtual_resolution=Vector(800, 600), virtual_resolution_mode=VirtualResolutionMode.adaptive_stretch) as engine:
        ...

You can tell the engine to use the following modes when adjusting your virtual resolution to the window:

* :code:`VirtualResolutionMode.adaptive_stretch` - the default mode. The drawable area will adapt to window size, maintaining aspect ratio and leaving black padded areas outside
* :code:`VirtualResolutionMode.aggresive_stretch` - the drawable area will always fill the entire window - aspect ratio may not be maintained while stretching.
* :code:`VirtualResolutionMode.no_stretch` - no stretching applied, leaving black padded areas if window is larger than virtual resolution size

.. note::

    It is possible to change the virtual resolution size and mode even as the game is running.

Fullscreen mode
~~~~~~~~~~~~~~~

Running the game in fullscreen is very easy:

.. code-block:: python

    engine.window.fullscreen = True

The engine will resize the window to fit the entire screen and remove window's top bar and borders. If you select the
window size manually in addition to setting fullscreen to True, the selected size will be ignored.

Kaa engine allows to alt-tab out of the game running in fullscreen.

.. note::

    It is possible to toggle fullscreen mode and change other window properties even as the game is running.

End of Part 1 - full code
~~~~~~~~~~~~~~~~~~~~~~~~~

Feel free to experiment with window and renderer properties. Then use the following main.py content below
and proceed to :doc:`Part 2 of the tutorial </tutorial/part02>`

.. code-block:: python

    from kaa.engine import Engine, Scene, VirtualResolutionMode
    from kaa.geometry import Vector

    class MyScene(Scene):

        def update(self, dt):
            pass


    with Engine(virtual_resolution=Vector(800, 600)) as engine:
        # set  window properties
        engine.window.size = Vector(800, 600)
        engine.window.title = "My first kaa game!"
        # initialize and run the scene
        my_scene = MyScene()
        engine.run(my_scene)


