Part 9: The camera
==================

Camera projects the scene into your 2D display. Controlling the camera allows us to add few extra visual effects.

Getting the camera
~~~~~~~~~~~~~~~~~~

Camera is available directly in the scene:

.. code-block:: python

    class SomeScene(kaa.engine.Scene):

        def foo(self):
            hi_i_am_camera = self.camera # the camera is here!


Camera properties
~~~~~~~~~~~~~~~~~

The camera object has the following properties:

* :code:`position` - allows to move the camera
* :code:`rotation` - allows to rotate the camera (using radians)
* :code:`rotation_degrees` - allows to rotate the camera (using degrees)
* :code:`scale` - allows for applying a zoom in / zoom out effect

The camera object has also the following method:

* :code:`unproject_position(position_vector)` - a helper function that transforms a current screen position into absolute position by applying current camera transformations. Practical use is illustrated below.

Full Example
~~~~~~~~~~~~

Let's use the camera in our game:

* arrow keys to move the camera up, down, left right
* page up and page down keys to change the camera's scale up and down
* home and end keys to rotate the camera clockwise and anti-clockwise

Let's add the following code to the :code:`GameplayScene`

.. code-block:: python
    :caption: scenes/gameplay.py

    class GameplayScene(Scene):
        # ... rest of the class ...

        def update(self, dt):
            # ... other code ....

            if self.input.keyboard.is_pressed(Keycode.left):
                self.camera.position -= Vector(-0.1 * dt, 0)
            if self.input.keyboard.is_pressed(Keycode.right):
                self.camera.position -= Vector(0.1 * dt, 0)
            if self.input.keyboard.is_pressed(Keycode.up):
                self.camera.position -= Vector(0, -0.1 * dt)
            if self.input.keyboard.is_pressed(Keycode.down):
                self.camera.position -= Vector(0, 0.1 * dt)

            if self.input.keyboard.is_pressed(Keycode.pageup):
                self.camera.scale -= Vector(0.001*dt, 0.001*dt)
            if self.input.keyboard.is_pressed(Keycode.pagedown):
                self.camera.scale += Vector(0.001*dt, 0.001*dt)

            if self.input.keyboard.is_pressed(Keycode.home):
                self.camera.rotation_degrees += 0.03 * dt
            if self.input.keyboard.is_pressed(Keycode.end):
                self.camera.rotation_degrees -= 0.03 * dt

Run the game and see how you can control the camera in the gameplay scene using arrow keys, page up/down and home/end
keys.

Have you noticed? When you transform the camera (especially when you rotate it) and then shoot your guns, the bullets
don't fly where they should... If the mouse pointer is in the (0,0) position i.e. top-left of the screen, the bullets
don't fly to that exact place but to the top-left corner **of the projected image of the scene**. It's not a bug,
it's a feature! Point (0,0) of the scene always is a (0,0) regardless of transformations applied to the camera!

In other words, if we apply a transformation to the camera we also need to apply the same transformation to
the :code:`get_mouse_position()` function! That's where camera's :code:`unproject_position(position_vector)` function
can help.

Let's modify the code in :code:`PlayerController` where :code:`get_mouse_position()` is used.

.. code-block:: python
    :caption: controllers/player_controller.py

    # that fragment inside update() function....
    elif event.keyboard_key.key == Keycode.space:
        self.scene.enemies_controller.add_enemy(Enemy(position=self.scene.camera.unproject_position(
            self.scene.input.mouse.get_position()), rotation_degrees=random.randint(0,360)))

    # another fragment inside update() function:
    mouse_pos = self.scene.camera.unproject_position(self.scene.input.mouse.get_position())


Run the game again and verify that shooting guns and spawning enemies have been fixed.

Moving the player is more interesting problem, but we won't change it now. After all, the player always moves the same way
it's just the way we look at it that changes!


There isn't a "global" camera, each scene has its own
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Each scene has its own camera, so if you apply transformation to a camera in scene A, and then change the scene to B
then the camera in scene B will not be affected by those transformations!

That's all you need to know about camera for now. Let's move on to the :doc:`next part of the tutorial </tutorial/part10>`.