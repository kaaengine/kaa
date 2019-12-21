Part 4: Handling Input
======================

We have our hero drawn on the screen, holding a machine gun. In this chapter we will implement the following
input-related stuff:

* move our hero around with WSAD keys,
* cycle weapons by pressing tab key
* switch to selected weapon by pressing 1,2 and 3
* look around by moving the mouse
* shoot by pressing left mouse button.

The best place to handle input is :code:`update(dt)` function. But we don't want to put everything in the
scene's :code:`update(dt)` as the code would grow too large. Let's add an :code:`update(dt)` function to
:code:`PlayerController` class:

.. code-block:: python
    :caption: controllers/player_controller.py

    class PlayerController:

    # .... rest of the class .....

    def update(self, dt):
        pass

Then let's call that method from the :code:`GameplayScene`:

.. code-block:: python
    :caption: scenes/gameplay.py

    class GameplayScene(Scene):

        # ...... rest of the class .........

        def update(self, dt):
            self.player_controller.update(dt)

            #....... rest of the method .........


Two ways for handling input
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Kaa offers two ways for handling input.

* Active. You can actively check given key's status (pressed, released etc.). You do that by calling appropriate methods:

  * Scene's :code:`input.keyboard` methods for keyboard (e.g. :code:`input.keyboard.is_pressed(KeyCode.esc)`)
  * Scene's :code:`input.mouse` methods for mouse (e.g. :code:`input.keyboard.is_pressed(MouseButton.left)`)
  * Scene's :code:`input.controller` methods for controllers (e.g. :code:`input.controller.is_pressed(ControllerButton.a)`)
  * Scene's :code:`input.system` methods for system (e.g. :code:`system.get_clipboard_text()`)

* Passive. You can iterate through events returned by the Scene's :code:`input.events()` method to check for input events (keystrokes, mouse clicks, controller sticks moved, etc.).

Handling input from keyboard (active)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The function which you can call at any time and get an answer if a keyboard key is up or down is
:code:`input.keyboard.is_pressed()`. Let's use it in our :code:`player_controller.py`:

.. code-block:: python
    :caption: controllers/player_controller.py

    from kaa.input import Keycode

    class PlayerController:

        # .... rest of the class .....

        def update(self, dt):
            if self.scene.input.keyboard.is_pressed(Keycode.w):
                self.player.position += Vector(0, -3)
            if self.scene.input.keyboard.is_pressed(Keycode.s):
                self.player.position += Vector(0, 3)
            if self.scene.input.keyboard.is_pressed(Keycode.a):
                self.player.position += Vector(-3, 0)
            if self.scene.input.keyboard.is_pressed(Keycode.d):
                self.player.position += Vector(3, 0)


Run the game and see how our hero can now move using WSAD keys!

.. note::
    To check if a key is in "released" state use :code:`scene.input.keyboard.is_released()`

But hey, wasn't something like this an example of a bad practice? We just hardcoded hero's speed to
3 pixels (actually: 3 units of virtual resolution) per frame, ignoring the dt value! It means if the dt is 15 miliseconds
the hero will move the same distance as when the frame takes 10 times longer (dt is 150 miliseconds). Also, shouldn't
hero speed value be defined in settings.py and imported from there rather just put directly in the code like some "magic number"?

Yup, those are all valid points. Don't worry - we'll refactor that code later, when we start working with the physics.

Let's now implement a function to cycle through weapons. Add the following code to the :code:`Player` class:

.. code-block:: python
    :caption: controllers/player.py

    class Player(Node):

        # .... rest of the class ....

        def cycle_weapons(self):
            if self.current_weapon is None:
                return
            elif isinstance(self.current_weapon, MachineGun):
                self.change_weapon(WeaponType.GrenadeLauncher)
            elif isinstance(self.current_weapon, GrenadeLauncher):
                self.change_weapon(WeaponType.ForceGun)
            elif isinstance(self.current_weapon, ForceGun):
                self.change_weapon(WeaponType.MachineGun)

Pretty self explanatory. Now let's try calling this function when tab key is pressed. Append the following code to
the :code:`update()` function in :code:`PlayerController`:

.. code-block:: python
    :caption: controllers/player_controller.py

    class PlayerController:

        # .... rest of the class .....

        def update(self, dt):
            # ....... rest of the function ........
            if self.scene.input.keyboard.is_pressed(Keycode.tab):
                self.player.cycle_weapons()


Run the game and press tab.... whoa!!! It makes our hero change weapons so fast! This is
because the :code:`update()` function is called by the engine as frequently as 60 times per second, so our
:code:`cycle_weapons()` function is called 60 times per second (as long as the tab key is pressed).

Let's fix this! There is another method of handling input from keyboard, it captures individual key strokes.

Handling input from keyboard (passive)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Let's remove the :code:`if self.scene.input.keyboard.is_pressed(Keycode.tab):` part from the update function inside
:code:`PlayerController` and put the following code instead:

.. code-block:: python
    :caption: controllers/player_controller.py

    from common.enums import WeaponType

    class PlayerController:

        # ..... rest of the class ........

        def update(self, dt):

            # ....... rest of the method .........

            for event in self.scene.input.events():
                if event.keyboard: # check if the event is a keyboard event
                    if event.keyboard.is_pressing(Keycode.tab):
                        self.player.cycle_weapons()
                    elif event.keyboard.is_pressing(Keycode.num_1):
                        self.player.change_weapon(WeaponType.MachineGun)
                    elif event.keyboard.is_pressing(Keycode.num_2):
                        self.player.change_weapon(WeaponType.GrenadeLauncher)
                    elif event.keyboard.is_pressing(Keycode.num_3):
                        self.player.change_weapon(WeaponType.ForceGun)

Run the game. Works much better now. It's because :code:`is_pressing` event is published on a first key stroke
and then in reasonable intervals (same as used when typing).

.. note::
    You can use :code:`event.keyboard.is_releasing()` to detect when a key was released.

We now have ability to move our hero, cycle through weapons with tab, and select weapon with 1, 2 and 3.

One more thing before we move on, it's annoying to press ALT+F4 to close the window, let's just bind it with pressing 'q'.
Let's update the :code:`update()` (no pun intended)

.. code-block:: python
    :caption: scenes/gameplay.py

    from kaa.input import Keycode

    class GameplayScene(Scene):

        # ....... rest of the class ...........

        def update(self, dt):
            self.player_controller.update(dt)

            for event in self.input.events():
                if event.keyboard: # check if it's a keyboard event
                    if event.keyboard.is_pressing(Keycode.q):
                        self.engine.quit()
                if event.system: # check if it's a system event
                    if event.system.quit:
                        self.engine.quit()


Getting mouse position (active)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Getting mouse position is very easy. All we need is to call :code:`input.mouse.get_position()` on our scene instance.

Let's get current mouse position and use it to rotate the player towards the mouse pointer.

.. code-block:: python
    :caption: controllers/player_controller.py

    class PlayerController:

        # ..... rest of the class ........

        def update(self, dt):

            # ....... rest of the method .........

            mouse_pos = self.scene.input.mouse.get_position()
            player_rotation_vector = mouse_pos - self.player.position
            self.player.rotation_degrees = player_rotation_vector.to_angle_degrees()

What happens here: to get a direction vector between positions A and B we need to substract those two vectors.
We then use :code:`to_angle_degrees()` on a vector to get a number between 0 and 360 representing vector's angle.
Finally we set player's rotation (in degrees) to the calculated value

Run the game. We can now walk with WSAD, change weapons with tab, 1, 2, and 3 keys, and we can aim! It starts looking good!
Let's now add a shooting mechanics!

Getting mouse button click events (active and passive)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Handling mouse click events, either actively or passively is very similar to handling keyboard events:

.. code-block:: python

    from kaa.input import MouseButton

    # active check if mouse key is pressed:
    if scene.input.mouse.is_pressed(MouseButton.left):
        # ..... do stuff ....

    # passive check (reading from events):
    for event in self.scene.input.events():
        if event.mouse: # check if it's a mouse event
            if event.mouse.is_pressing(MouseButton.right): # getting event
                # ..... do stuff .....

We will use the left mouse button click in the :doc:`next part of the tutorial </tutorial/part05>`, where we'll
implement shooting and collision handling.

