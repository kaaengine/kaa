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

Each scene has engine object stored under :code:`self.scene` so you can get it from there as well:

.. code-block:: python

    # .... inside kaa.engine.Scene class method ....
    self.engine.change_scene(some_new_scene)

How to create a new scene
~~~~~~~~~~~~~~~~~~~~~~~~~

Let's write two more scenes:

* :code:`GameTitleScene` - Will be activated when game starts. The scene will be a welcome screen: showing game logo and allowing to start the game or exit it.
* :code:`PauseScene` - Will be activated when pressing ESC during gameplay. Will show a simple screen allowing to abort game (return to title screen) or resume game (return to gameplay scene)

