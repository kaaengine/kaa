:mod:`input` --- Handling input from keyboard, mouse and controllers
====================================================================
.. module:: input
    :synopsis: Handling input from keyboard, mouse and controllers

:class:`InputManager` reference
-------------------------------

.. class:: InputManager

Input manager object can be accessed via :ref:`Scene.input <Scene.input>` property. It has two main features:

* Gives you access to specialized managers: :class`MouseManager`, :class:`KeyboardManager`, :class:`ControllerManager` and :class:`SystemManager` - they offer methods to actively check for input from your code. For instance, you can ask the :class:`KeyboardManager` if given key is pressed or released.
* Gives you access to a stream of events via the :meth:`events()` method. For example, an event gets published when user pressed/released a key on a keyboard or clicks a mouse button. Check out the :class:`Event` documentation for a list of all available events.

Instance Properties:

.. _InputManager.keyboard:
.. attribute:: InputManager.keyboard

    A get accessor returning :class:`KeyboardManager` object which exposes methods to check for keyboard input.
    See the :class:`KeyboardManager` documentation for a full list of available methods.

.. _InputManager.mouse:
.. attribute:: InputManager.mouse

    A get accessor returning :class:`MouseManager` object which exposes methods to check for mouse input.
    See the :class:`MouseManager` documentation for a full list of available methods.

.. _InputManager.controller:
.. attribute:: InputManager.controller

    A get accessor returning :class:`ControllerManager` object which exposes methods to check for controller input.
    See the :class:`ControllerManager` documentation for a full list of available methods.

.. _InputManager.system:
.. attribute:: InputManager.system

    A get accessor returning :class:`SystemManager` object which exposes methods to check for system input.
    See the :class:`SystemManager` documentation for a full list of available methods.

Instance Methods:

.. method:: InputManager.events()

    Returns a list of :class:`Event` objects that ocurred during the last frame. Check out the :class:`Event`
    for a full documentation on events.

:class:`KeyboardManager` reference
----------------------------------

.. class:: KeyboardManager

Keyboard manager can be accessed via the :ref:`InputManager.keyboard <InputManager.keyboard>` property.

It allows to check the state (pressed or released) of given key.

Instance methods:

.. method:: KeyboardManager.is_pressed(keycode)

    Checks if a specific key is pressed - keycode param must be a :class:`Keycode` value.

    .. code-block:: python

        from kaa.input import KeyCode

        # somewhere inside a Scene instance...
        if self.input.keyboard.is_pressed(Keycode.w):
            # ... do something if w is pressed
        if self.input.keyboard.is_pressed(Keycode.W):
            # ... do something if W is pressed
        if self.input.keyboard.is_pressed(Keycode.return_):
            # ... do something if ENTER key is pressed


.. method:: KeyboardManager.is_released(keycode)

    Checks if a specific key is released - keycode param must be a :class:`Keycode` value.

    .. code-block:: python

        from kaa.input import Keycode

        # somewhere inside a Scene instance...
        if self.input.keyboard.is_released(Keycode.w):
            # ... do something if w is released
        if self.input.keyboard.is_released(Keycode.W):
            # ... do something if W is released
        if self.input.keyboard.is_released(Keycode.return_):
            # ... do something if ENTER key is released

:class:`MouseManager` reference
-------------------------------

.. class:: MouseManager

Mouse manager can be accessed via the :ref:`InputManager.mouse <InputManager.mouse>` property.

The manager allows to check for the mouse buttons state (pressed/released). It also
allows to get the mouse pointer position.

Instance methods:

.. method:: MouseManager.is_pressed(mousebutton)

    Checks if given mouse button is pressed - mousebutton param must be a :class:`MouseButton` value.

    .. code-block:: python

        from kaa.input import MouseButton

        #somewhere inside a Scene instance...
        if self.input.mouse.is_pressed(MouseButton.left):
            # do something if the left mouse button is pressed

.. method:: MouseManager.is_released(mousebutton)

    Checks if given mouse button is released - mousebutton param must be a :class:`MouseButton` value.

    .. code-block:: python

        from kaa.input import MouseButton

        #somewhere inside a Scene instance...
        if self.input.mouse.is_released(MouseButton.middle):
            # do something if the middle mouse button is released

.. method:: MouseManager.get_position()

    Returns current mouse pointer position as a :class:`geometry.Vector`

    .. code-block:: python

        #somewhere inside a Scene instance...
        pos = self.input.mouse.get_position():
        print(pos)  # V[145.234, 345.343]


:class:`ControllerManager` reference
------------------------------------

.. class:: ControllerManager

Controller Manager can be accessed via the :ref:`InputManager.controller <InputManager.controller>` property.

The manager exposes methods for checking the state of controller's buttons, sticks and triggers. All major controller
types are supported.

.. _controller_id_example:

Unlike mouse or keyboard, multiple controllers can be connected and used simultaneously, therefore all manager methods
require passing a controller ID.

You can get the controller ID when controller is first connected. Kaa engine will publish a :class:`ControllerEvent`
having :code:`connected` flag set to :code:`True`. An :class:`id` field on the event is the controller ID you're looking
for.

When a controller disconnects, you will receive a :class:`ControllerEvent` with :code:`connected` flag set
to :code:`True`.

Your game code should always keep track of all currently connected controllers (their IDs).

Below is a basic example of keeping track of connected controller IDs and checking few selected properties of each
connected controller:

.. code-block:: python

    from kaa.engine import Engine, Scene
    from kaa.geometry import Vector
    from kaa.input import Keycode, ControllerButton, ControllerAxis

    class MyScene(Scene):

        def __init__(self):
            self.connected_controller_ids = []
            self.frame_count = 0

        def update(self, dt):
            self.frame_count += 1
            for event in self.input.events():

                if event.controller:
                    if event.controller.added:
                        print('New controller connected: id is {}'.format(event.controller.id))
                        self.connected_controller_ids.append(event.controller.id)
                    elif event.controller.removed:
                        print('Controller disconnected: id is {}'.format(event.controller.id))
                        self.connected_controller_ids.remove(event.controller.id)

                if event.system and event.system.quit:
                    self.engine.quit()

            # Check a few properties of each connected controller:
            for controller_id in self.connected_controller_ids:
                a_button_pressed = self.input.controller.is_pressed(ControllerButton.a, controller_id)
                b_button_pressed = self.input.controller.is_pressed(ControllerButton.b, controller_id)
                left_stick_x = self.input.controller.get_axis_motion(ControllerAxis.left_x, controller_id)
                left_stick_y = self.input.controller.get_axis_motion(ControllerAxis.left_y, controller_id)
                print('Controller {}. A pressed:{}, B pressed:{}, left stick pos: {},{}'.format(controller_id,
                    a_button_pressed, b_button_pressed, left_stick_x, left_stick_y))


    with Engine(virtual_resolution=Vector(400, 200)) as engine:
        scene = MyScene()
        engine.window.size = Vector(400, 200)
        engine.window.center()
        engine.run(scene)

Instance methods

.. method:: ControllerManager.is_connected(controller_id)

    Checks connection status of a given controller_id.

.. method:: ControllerManager.is_pressed(controller_button, controller_id)

    Checks if given controller button is pressed. The controller_button param must be a :class:`ControllerButton` type.
    Check out the :ref:`example above <controller_id_example>` on how to obtain the controller_id.

    For example, to check the state of B button on controller 0:

    .. code-block:: python

        from kaa.input import ControllerButton

        # somewhere in the Scene class:
        if self.input.controller.is_pressed(ControllerButton.b, 0):
            print('B is pressed on controller 0!')


.. method:: ControllerManager.is_released(controller_button, controller_id)

    Checks if given controller button is released on given controller. The controller_button param
    must be a :class:`ControllerButton` type. Check out the :ref:`example above <controller_id_example>` on how to
    obtain the controller_id.

    For example, to check the state of B button on controller 2:

    .. code-block:: python

        from kaa.input import ControllerButton

        # somewhere in the Scene class:
        if self.input.controller.is_released(ControllerButton.b, 2):
            print('B is released on controller 2!')


.. method:: ControllerManager.is_axis_pressed(axis, controller_id)

    Checks if given stick axes or trigger is in non-zero position. The axis param must be
    of :class:`ControllerAxis` type. Check out the :ref:`example above <controller_id_example>` on how to obtain
    the controller_id.

    For example, to check if controller 1 left trigger is pressed:

    .. code-block:: python

        from kaa.input import ControllerAxis

        # somewhere in the Scene class:
        if self.input.controller.is_axis_pressed(ControllerAxis.trigger_left, 1):
            print('Left trigger is pressed!')

.. method:: ControllerManager.is_axis_released(axis, controller_id)

    Same as above, but checks if given stick axes or trigger is in a zero position. The axis param must be
    of :class:`ControllerAxis` type. Check out the :ref:`example above <controller_id_example>` on how to obtain the
    controller_id.

.. method:: ControllerManager.get_axis_motion(axis, controller_id)

    Gets an exact value of given stick axes motion or trigger as a number between 0 (stick axes or trigger in
    zero position) and 1 (stick axes or trigger in max position). The axis param must be  of :class:`ControllerAxis`
    type. Check out the :ref:`example above <controller_id_example>` on how to obtain the controller_id.

    For example, to check the state of controller 0 left trigger:

    .. code-block:: python

        from kaa.input import ControllerAxis

        # somewhere in the Scene class:
        val = self.input.controller.get_axis_motion(ControllerAxis.trigger_right, 0):
        print('Controller 0, pulling left trigger {} percent :)'.format(val*100))


.. method:: ControllerManager.get_name(controller_id)

    Returns a name of a controller. Check out the :ref:`example above <controller_id_example>` on how to
    obtain the controller_id.

.. method:: ControllerManager.get_triggers(controller_id)

    Returns state of both triggers in a single :class:`geometry.Vector` object. Vector's x value is left trigger and
    vector's y is right trigger. Check out the :ref:`example above <controller_id_example>` on how to obtain the
    controller_id.

    The values returned are between 0 (trigger is fully released) to 1 (trigger is fully pressed)

.. method:: ControllerManager.get_sticks(compound_axis, controller_id)

    Returns state of given stick as a :class`geometry.Vector`.

    The compound_axis parameter must be of :class:`CompoundControllerAxis` type.

    Check out the :ref:`example above <controller_id_example>` on how to obtain the controller_id.

    For example, to get the controller 1 left stick position:

    .. code-block:: python

        # somewhere in the Scene class:
        val = self.input.controller.get_axis_motion(CompoundControllerAxis.left_stick, 1):
        print('Controller 1, left stick position is {}'.format(val))


:class:`SystemManager` reference
--------------------------------

.. class:: SystemManager

TODO


:class:`Event` reference
------------------------

.. class:: Event

TODO

:class:`KeyboardEvent` reference
--------------------------------

.. class:: KeyboardEvent

TODO

:class:`MouseEvent` reference
-----------------------------

.. class:: MouseEvent

TODO

:class:`ControllerEvent` reference
----------------------------------

.. class:: ControllerEvent

TODO

:class:`AudioEvent` reference
-----------------------------

.. class:: AudioEvent

TODO

:class:`WindowEvent` reference
------------------------------

.. class:: WindowEvent

TODO

:class:`SystemEvent` reference
------------------------------

.. class:: SystemEvent

TODO


:class:`Keycode` reference
--------------------------

.. class:: Keycode

TODO


:class:`MouseButton` reference
------------------------------

.. class:: MouseButton

TODO

:class:`ControllerButton` reference
-----------------------------------

.. class:: ControllerButton

Enum type for referencing controller buttons when working with :class:`ControllerManager` methods and :class:`ControllerEvent`
events. Note that left and right triggers are not buttons, they're considered axis (see :class:`ControllerAxis`)

Available values are:

* :code:`ControllerButton.a`
* :code:`ControllerButton.b`
* :code:`ControllerButton.x`
* :code:`ControllerButton.y`
* :code:`ControllerButton.back`
* :code:`ControllerButton.guide`
* :code:`ControllerButton.start`
* :code:`ControllerButton.left_stick`
* :code:`ControllerButton.right_stick`
* :code:`ControllerButton.left_shoulder`
* :code:`ControllerButton.right_shoulder`
* :code:`ControllerButton.dpad_up`
* :code:`ControllerButton.dpad_down`
* :code:`ControllerButton.dpad_left`
* :code:`ControllerButton.dpad_right`


:class:`ControllerAxis` reference
---------------------------------

.. class:: ControllerAxis

Enum type for referencing controller axes when working with :class:`ControllerManager` methods and
:class:`ControllerEvent` events.

Available values are:

* :code:`ControllerAxis.left_y`
* :code:`ControllerAxis.left_x`
* :code:`ControllerAxis.right_x`
* :code:`ControllerAxis.right_y`
* :code:`ControllerAxis.trigger_left`
* :code:`ControllerAxis.trigger_right`


:class:` CompoundControllerAxis` reference
------------------------------------------

.. class:: CompoundControllerAxis

Enum type for referencing sticks (left or right) when working with some of :class:`ControllerManager` methods.

Available values are:

* :code:`CompoundControllerAxis.left_stick`
* :code:`CompoundControllerAxis.right_stick`

