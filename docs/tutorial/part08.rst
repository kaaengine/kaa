Part 8: Working with multiple scenes
====================================

So far we have had just one Scene in our game, the :code:`GameplayScene`. Let's add two more: for the title screen
and for the pause screen. Even though we'll have 3 scenes created and initialized only one of them can be activa at a time.
It means that only active scene will render its nodes on the screen and run the :code:`update()` loop. The other scenes
will be "freezed" until one of them is activated.

How to write a new scene
~~~~~~~~~~~~~~~~~~~~~~~~

Let's write two more scenes:

* :code:`GameTitleScene` - Will be activated when game starts. The scene will be a welcome screen: showing game logo and allowing to start the game or exit it.
* :code:`PauseScene` - Will be activated when pressing ESC during gameplay. Will show a simple screen allowing to abort game (return to title screen) or resume game (return to gameplay scene)

