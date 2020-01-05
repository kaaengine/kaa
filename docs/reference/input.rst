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

System Manager can be accessed via the :ref:`InputManager.system <InputManager.system>` property.

The manager exposes methods for working with system related input such as clipboard.

Instance methods:

.. method:: SystemManager.get_clipboard_text()

    Gets text from the system clipboard

.. method:: SystemManager.set_clipboard_text(text)

    Puts the :code:`text` in the system clipboard


:class:`Event` reference
------------------------

.. class:: Event

As the game is running, a lot of things happen: the player may press or release keyboard keys
or mouse buttons, interact with controller, he can also interact with the window in which your game is running, e.g.
maximize or minimize it, and so on. Kaa engine detects all those events and makes them available via
:meth:`InputManager.events()` method. The method returns a list of all events that ocurred during the previous frame,
which means it is cleared on every frame (no events are retained).

Each :class:`Event` object has identical structure with the following properties:

* :code:`system` - gives access to :class:`SystemEvent` properties and methods if this event is a system related event, otherwise it will be :code:`None`
* :code:`window` - gives access to :class:`WindowEvent` properties and methods if this event is a window related event, otherwise it will be :code:`None`
* :code:`keyboard` - gives access to :class:`KeyboardEvent` properties and methods if this event is a keyboard related event, otherwise it will be :code:`None`
* :code:`mouse` - gives access to :class:`MouseEvent` properties and methods if this event is a mouse related event, otherwise it will be :code:`None`
* :code:`controller` - gives access to :class:`ControllerEvent` properties and methods if this event is a controller related event, otherwise it will be :code:`None`
* :code:`audio` - gives access to :class:`AudioEvent` properties and methods if this event is an audio related event, otherwise it will be :code:`None`

Depending on the type of the event only one property will be non-null while all the other properties will be null.
This design usually results in a following way of handling events in the code:

.. code-block:: python

    # ... inside a Scene...
    def update(self, dt):

        for event in self.input.events():
            if event.system:
                # do something if it's a system event
            elif event.window:
                # do something if it's a window event
            elif event.keyboard:
                # do something if it's a keyboard event
            elif event.mouse:
                # do something if it's a mouse event
            elif event.controller:
                # do something if it's a controller event
            elif event.audio:
                # do something if it's audio event


:class:`KeyboardEvent` reference
--------------------------------

.. class:: KeyboardEvent

Represents an event of pressing or releasing a keyboard key.

Instance methods:

.. method:: KeyboardEvent.is_pressing(keycode)

    Returns :code:`True` if given :class:`Keycode` was pressed

.. method:: KeyboardEvent.is_releasing(keycode)

    Returns :code:`True` if given :class:`Keycode` was released


TODO: need to add the 'text' property returning a string with a text, now it needs an iteration through all KeyCodes...


:class:`MouseEvent` reference
-----------------------------

.. class:: MouseEvent

Represents a mouse related event, such as mouse button click, mouse wheel scroll or a mouse pointer motion.

Instance properties:

.. attribute:: MouseEvent.motion

    A bool flag indicating if the event is motion related. If :code:`True`, then the
    :code:`position` property can be read to find the mouse position.

.. attribute:: MouseEvent.position

    Returns mouse pointer position as :class:`geometry.Vector`. The :code:`position` property is relevant only if
    :code:`motion` flag is :code:`True`, otherwise it will be a zero vector.

    .. code-block:: python

        # ... inside a Scene instance...
        for event in self.input.events():
            if event.mouse:
                if event.mouse.motion:
                    print("Mouse motion: {}. Position is: {}.".format(event.mouse.motion, event.mouse.position))

.. attribute:: MouseEvent.wheel

    A bool flag indicating if the event is related to mouse wheel. If :code:`True`, then the
    :code:`scroll` property can be read to find out whether the wheel was scrolled up or down

.. attribute:: MouseEvent.scroll

    Returns a :class:`geometry.Vector` indicating whether the mouse wheel was scrolled up or down. The :code:`y`
    property in the returned vector holds the value, the :code:`x` will always be zero.

    .. code-block:: python

        # ... inside a Scene instance...
        for event in self.input.events():
            if event.mouse:
                if event.mouse.wheel:
                    print("Mouse wheel: {}. Scroll is: {}.".format(event.mouse.wheel, event.mouse.scroll))


.. attribute:: MouseEvent.button

    A bool flag indicating if the event is related to mouse button. If :code:`True`, then you should use methods
    :meth:`MouseEvent.is_pressing` or :meth:`MouseEvent.is_releasing` to identify which mouse button was pressed
    or released.

    TODO: need to do that better because right now is_pressing and is_releassing require user to iterate over all
    possible MouseButton values to find out which button was pressed or released!

Instance methods:

.. method:: MouseEvent.is_pressing(mouse_button)

    Returns :code:`True` if this event represents pressing of given mouse button.

    The mouse_button paramter must be a :class:`MouseButton` value.

.. method:: MouseEvent.is_releasing(mouse_button)

    Returns :code:`True` if this event represents releasing of given mouse button.

    The mouse_button paramter must be a :class:`MouseButton` value.


:class:`ControllerEvent` reference
----------------------------------

.. class:: ControllerEvent

Represents controller related event such as connecting/disconencting a controller or changing the state of
a button, stick or trigger.

Instance properties:

.. attribute:: ControllerEvent.id

    Since multiple controllers can be connected simultaneously there is a need to tell them apart. Each event holds
    an id which identifies the controller.

.. attribute:: ControllerEvent.added

    A bool flag - when :code:`True` it means the event represents connecting a new controler.

.. attribute:: ControllerEvent.removed

    A bool flag - when :code:`True` it means the event represents disconnecting a controler.

.. attribute:: ControllerEvent.button

    A bool flag indicating if the event is related to controller button. If :code:`True`, then you may use methods
    :meth:`ControllerEvent.is_pressing` or :meth:`ControllerEvent.is_releasing` to identify which button was pressed
    or released.

.. attribute:: ControllerEvent.axis

    A bool flag indicating if the event is related to controller axis motion. If :code:`True`, then you may use
    the :meth:`ControllerEvent.axis_motion()` method to find which axes has changed.


Instance methods:

.. method:: ControllerEvent.is_pressing(controller_button)

    Returns :code:`True` if this event represents pressing given controller button.

    The controller_button paramter must be a :class:`ControllerButton` value.

.. method:: ControllerEvent.is_releasing(mouse_button)

    Returns :code:`True` if this event represents releasing given controller button.

    The controller_button paramter must be a :class:`ControllerButton` value.

.. method:: ControllerEvent.axis_motion(controller_axes)

    Returns :code:`True` if this event represents a motion of given controller axes.

    The controller_axes must be a :class:`ControllerAxis` value.

:class:`AudioEvent` reference
-----------------------------

.. class:: AudioEvent

Represents an audio related event.

Instance methods:

.. method:: music_finished()

    Returns :code:`True` if current music track finished playing.


:class:`WindowEvent` reference
------------------------------

.. class:: WindowEvent

Represents a window related event.

Instance properties:

.. attribute:: WindowEvent.size

    Window size as :class:`geometry.Vector`

.. attribute:: WindowEvent.position

    Window position as :class:`geometry.Vector`

Instance methods:

.. method:: WindowEvent.shown()

    Returns :code:`True` if the window was shown.

.. method:: WindowEvent.exposed()

    Returns :code:`True` if the window was exposed.

.. method:: WindowEvent.moved()

    Returns :code:`True` if the window was moved.

.. method:: WindowEvent.resized()

    Returns :code:`True` if the window was resized.

.. method:: WindowEvent.minimized()

    Returns :code:`True` if the window was minimized.

.. method:: WindowEvent.maximized()

    Returns :code:`True` if the window was maximized.

.. method:: WindowEvent.restored()

    Returns :code:`True` if the window was restored.

.. method:: WindowEvent.enter()

    TODO: ???

.. method:: WindowEvent.leave()

    TODO: ???

.. method:: WindowEvent.focus_gained()

    Returns :code:`True` if the window gained a focus.

.. method:: WindowEvent.focus_lost()

    Returns :code:`True` if the window lost a focus.

.. method:: WindowEvent.close()

    Returns :code:`True` if the window was closed.


:class:`SystemEvent` reference
------------------------------

.. class:: SystemEvent

Represents a system related event.

Instance method:

.. method:: SystemEvent.quit()

    Returns :code:`True` if the game proces is terminating.

.. method:: SystemEvent.clipboard_updated()

    Returns :code:`True` if the system clipboard was updated. You may call :meth:`SystemManager.get_clipboard_text()`
    method to check the text in the system clipboard.


:class:`Keycode` reference
--------------------------

.. class:: Keycode

Enum type for referencing keyboard keys when working with :class:`KeyboardManager` and :class:`KeyboardEvent`.

Available values are:

* :code:`Keycode.unknown`
* :code:`Keycode.return_`
* :code:`Keycode.escape`
* :code:`Keycode.backspace`
* :code:`Keycode.tab`
* :code:`Keycode.space`
* :code:`Keycode.exclaim`
* :code:`Keycode.quotedbl`
* :code:`Keycode.hash`
* :code:`Keycode.percent`
* :code:`Keycode.dollar`
* :code:`Keycode.ampersand`
* :code:`Keycode.quote`
* :code:`Keycode.leftparen`
* :code:`Keycode.rightparen`
* :code:`Keycode.asterisk`
* :code:`Keycode.plus`
* :code:`Keycode.comma`
* :code:`Keycode.minus`
* :code:`Keycode.period`
* :code:`Keycode.slash`
* :code:`Keycode.num_0`
* :code:`Keycode.num_1`
* :code:`Keycode.num_2`
* :code:`Keycode.num_3`
* :code:`Keycode.num_4`
* :code:`Keycode.num_5`
* :code:`Keycode.num_6`
* :code:`Keycode.num_7`
* :code:`Keycode.num_8`
* :code:`Keycode.num_9`
* :code:`Keycode.colon`
* :code:`Keycode.semicolon`
* :code:`Keycode.less`
* :code:`Keycode.equals`
* :code:`Keycode.greater`
* :code:`Keycode.question`
* :code:`Keycode.at`
* :code:`Keycode.leftbracket`
* :code:`Keycode.backslash`
* :code:`Keycode.rightbracket`
* :code:`Keycode.caret`
* :code:`Keycode.underscore`
* :code:`Keycode.backquote`
* :code:`Keycode.a`
* :code:`Keycode.b`
* :code:`Keycode.c`
* :code:`Keycode.d`
* :code:`Keycode.e`
* :code:`Keycode.f`
* :code:`Keycode.g`
* :code:`Keycode.h`
* :code:`Keycode.i`
* :code:`Keycode.j`
* :code:`Keycode.k`
* :code:`Keycode.l`
* :code:`Keycode.m`
* :code:`Keycode.n`
* :code:`Keycode.o`
* :code:`Keycode.p`
* :code:`Keycode.q`
* :code:`Keycode.r`
* :code:`Keycode.s`
* :code:`Keycode.t`
* :code:`Keycode.u`
* :code:`Keycode.v`
* :code:`Keycode.w`
* :code:`Keycode.x`
* :code:`Keycode.y`
* :code:`Keycode.z`
* :code:`Keycode.A`
* :code:`Keycode.B`
* :code:`Keycode.C`
* :code:`Keycode.D`
* :code:`Keycode.E`
* :code:`Keycode.F`
* :code:`Keycode.G`
* :code:`Keycode.H`
* :code:`Keycode.I`
* :code:`Keycode.J`
* :code:`Keycode.K`
* :code:`Keycode.L`
* :code:`Keycode.M`
* :code:`Keycode.N`
* :code:`Keycode.O`
* :code:`Keycode.P`
* :code:`Keycode.Q`
* :code:`Keycode.R`
* :code:`Keycode.S`
* :code:`Keycode.T`
* :code:`Keycode.U`
* :code:`Keycode.V`
* :code:`Keycode.W`
* :code:`Keycode.X`
* :code:`Keycode.Y`
* :code:`Keycode.Z`
* :code:`Keycode.capslock`
* :code:`Keycode.F1`
* :code:`Keycode.F2`
* :code:`Keycode.F3`
* :code:`Keycode.F4`
* :code:`Keycode.F5`
* :code:`Keycode.F6`
* :code:`Keycode.F7`
* :code:`Keycode.F8`
* :code:`Keycode.F9`
* :code:`Keycode.F10`
* :code:`Keycode.F11`
* :code:`Keycode.F12`
* :code:`Keycode.printscreen`
* :code:`Keycode.scrolllock`
* :code:`Keycode.pause`
* :code:`Keycode.insert`
* :code:`Keycode.home`
* :code:`Keycode.pageup`
* :code:`Keycode.delete`
* :code:`Keycode.end`
* :code:`Keycode.pagedown`
* :code:`Keycode.right`
* :code:`Keycode.left`
* :code:`Keycode.down`
* :code:`Keycode.up`
* :code:`Keycode.numlockclear`
* :code:`Keycode.kp_divide`
* :code:`Keycode.kp_multiply`
* :code:`Keycode.kp_minus`
* :code:`Keycode.kp_plus`
* :code:`Keycode.kp_enter`
* :code:`Keycode.kp_1`
* :code:`Keycode.kp_2`
* :code:`Keycode.kp_3`
* :code:`Keycode.kp_4`
* :code:`Keycode.kp_5`
* :code:`Keycode.kp_6`
* :code:`Keycode.kp_7`
* :code:`Keycode.kp_8`
* :code:`Keycode.kp_9`
* :code:`Keycode.kp_0`
* :code:`Keycode.kp_period`
* :code:`Keycode.application`
* :code:`Keycode.power`
* :code:`Keycode.kp_equals`
* :code:`Keycode.F13`
* :code:`Keycode.F14`
* :code:`Keycode.F15`
* :code:`Keycode.F16`
* :code:`Keycode.F17`
* :code:`Keycode.F18`
* :code:`Keycode.F19`
* :code:`Keycode.F20`
* :code:`Keycode.F21`
* :code:`Keycode.F22`
* :code:`Keycode.F23`
* :code:`Keycode.F24`
* :code:`Keycode.execute`
* :code:`Keycode.help`
* :code:`Keycode.menu`
* :code:`Keycode.select`
* :code:`Keycode.stop`
* :code:`Keycode.again`
* :code:`Keycode.undo`
* :code:`Keycode.cut`
* :code:`Keycode.copy`
* :code:`Keycode.paste`
* :code:`Keycode.find`
* :code:`Keycode.mute`
* :code:`Keycode.volumeup`
* :code:`Keycode.volumedown`
* :code:`Keycode.kp_comma`
* :code:`Keycode.kp_equalsas400`
* :code:`Keycode.alterase`
* :code:`Keycode.sysreq`
* :code:`Keycode.cancel`
* :code:`Keycode.clear`
* :code:`Keycode.prior`
* :code:`Keycode.return2`
* :code:`Keycode.separator`
* :code:`Keycode.out`
* :code:`Keycode.oper`
* :code:`Keycode.clearagain`
* :code:`Keycode.crsel`
* :code:`Keycode.exsel`
* :code:`Keycode.kp_00`
* :code:`Keycode.kp_000`
* :code:`Keycode.thousandsseparator`
* :code:`Keycode.decimalseparator`
* :code:`Keycode.currencyunit`
* :code:`Keycode.currencysubunit`
* :code:`Keycode.kp_leftparen`
* :code:`Keycode.kp_rightparen`
* :code:`Keycode.kp_leftbrace`
* :code:`Keycode.kp_rightbrace`
* :code:`Keycode.kp_tab`
* :code:`Keycode.kp_backspace`
* :code:`Keycode.kp_a`
* :code:`Keycode.kp_b`
* :code:`Keycode.kp_c`
* :code:`Keycode.kp_d`
* :code:`Keycode.kp_e`
* :code:`Keycode.kp_f`
* :code:`Keycode.kp_xor`
* :code:`Keycode.kp_power`
* :code:`Keycode.kp_percent`
* :code:`Keycode.kp_less`
* :code:`Keycode.kp_greater`
* :code:`Keycode.kp_ampersand`
* :code:`Keycode.kp_dblampersand`
* :code:`Keycode.kp_verticalbar`
* :code:`Keycode.kp_dblverticalbar`
* :code:`Keycode.kp_colon`
* :code:`Keycode.kp_hash`
* :code:`Keycode.kp_space`
* :code:`Keycode.kp_at`
* :code:`Keycode.kp_exclam`
* :code:`Keycode.kp_memstore`
* :code:`Keycode.kp_memrecall`
* :code:`Keycode.kp_memclear`
* :code:`Keycode.kp_memadd`
* :code:`Keycode.kp_memsubtract`
* :code:`Keycode.kp_memmultiply`
* :code:`Keycode.kp_memdivide`
* :code:`Keycode.kp_plusminus`
* :code:`Keycode.kp_clear`
* :code:`Keycode.kp_clearentry`
* :code:`Keycode.kp_binary`
* :code:`Keycode.kp_octal`
* :code:`Keycode.kp_decimal`
* :code:`Keycode.kp_hexadecimal`
* :code:`Keycode.lctrl`
* :code:`Keycode.lshift`
* :code:`Keycode.lalt`
* :code:`Keycode.lgui`
* :code:`Keycode.rctrl`
* :code:`Keycode.rshift`
* :code:`Keycode.ralt`
* :code:`Keycode.rgui`
* :code:`Keycode.mode`
* :code:`Keycode.audionext`
* :code:`Keycode.audioprev`
* :code:`Keycode.audiostop`
* :code:`Keycode.audioplay`
* :code:`Keycode.audiomute`
* :code:`Keycode.mediaselect`
* :code:`Keycode.www`
* :code:`Keycode.mail`
* :code:`Keycode.calculator`
* :code:`Keycode.computer`
* :code:`Keycode.ac_search`
* :code:`Keycode.ac_home`
* :code:`Keycode.ac_back`
* :code:`Keycode.ac_forward`
* :code:`Keycode.ac_stop`
* :code:`Keycode.ac_refresh`
* :code:`Keycode.ac_bookmarks`
* :code:`Keycode.brightnessdown`
* :code:`Keycode.brightnessup`
* :code:`Keycode.displayswitch`
* :code:`Keycode.kbdillumtoggle`
* :code:`Keycode.kbdillumdown`
* :code:`Keycode.kbdillumup`
* :code:`Keycode.eject`
* :code:`Keycode.sleep`

:class:`MouseButton` reference
------------------------------

.. class:: MouseButton

Enum type for referencing mouse buttons when working with :class:`MouseManager` and :class:`MouseEvent`.

Available values are:

* :code:`MouseButton.left`
* :code:`MouseButton.middle`
* :code:`MouseButton.right`
* :code:`MouseButton.x1`
* :code:`MouseButton.x2`


:class:`ControllerButton` reference
-----------------------------------

.. class:: ControllerButton

Enum type for referencing controller buttons when working with :class:`ControllerManager` and :class:`ControllerEvent`.
Note that left and right triggers are not buttons, they're considered axis (see :class:`ControllerAxis`)

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

Enum type for referencing controller axes when working with :class:`ControllerManager` and
:class:`ControllerEvent`.

Available values are:

* :code:`ControllerAxis.left_y`
* :code:`ControllerAxis.left_x`
* :code:`ControllerAxis.right_x`
* :code:`ControllerAxis.right_y`
* :code:`ControllerAxis.trigger_left`
* :code:`ControllerAxis.trigger_right`


:class:`CompoundControllerAxis` reference
------------------------------------------

.. class:: CompoundControllerAxis

Enum type for referencing sticks (left or right) when working with some of :class:`ControllerManager` methods.

Available values are:

* :code:`CompoundControllerAxis.left_stick`
* :code:`CompoundControllerAxis.right_stick`

