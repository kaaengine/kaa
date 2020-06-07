:mod:`input` --- Handling input from keyboard, mouse and controllers
====================================================================
.. module:: input
    :synopsis: Handling input from keyboard, mouse and controllers

:class:`InputManager` reference
-------------------------------

.. class:: InputManager

Input manager object can be accessed via :ref:`Scene.input <Scene.input>` property. It has three main features:

* Gives you access to specialized managers: :class:`MouseManager`, :class:`KeyboardManager`, :class:`ControllerManager` and :class:`SystemManager` - they offer methods to actively check for input from your code. For instance, you can ask the :class:`KeyboardManager` if given key is pressed or released.
* Gives you access to a list of events which ocurred during the frame. This is achieved by calling the :meth:`InputManager.events()` method. Check out the :class:`Event` documentation for a list of all available events that kaaengine detects.
* Allows you to subscribe to specific types of events by registering your own callback function. This is done using :meth:`InputManager.register_callback()` function.

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

    Returns a list of :class:`Event` objects that ocurred during the last frame. Check out the
    :class:`Event` instance documentation for details.

.. method:: InputManager.register_callback(event_type, callback_func)

    Registers a callback function which will be called when specific event type(s) occur. Allows for an easy consumption
    of events you're interested in.

    The :code:`event_type` parameter must be a specific :class:`Event` subtype. You can also pass an iterable of those.
    Represents event type(s) you want to subscribe to.

    The :code:`callback_func` must be a callable. It will get called each time given event type occurs, passing the event
    as parameter.

    .. code-block:: python

        from kaa.input import EventType

        def on_text_input(event):
            print('user typed this: {}'.format(event.keyboard_text.text))

        def on_mouse_event(event):
            print('mouse button/wheel stuff happened!')

        # somewhere inside a Scene instance...
        self.input.register_callback(Event.keyboard_text, on_text_input)
        self.input.register_callback([Event.mouse_button, Event.mouse_wheel], on_mouse_event)

    Only one callback for given event type can be registered at a time. Registering another callback with the same
    event type will overwrite the previous one:

    .. code-block:: python

        from kaa.input import EventType

        def on_text_input_1(event):
            print('1 - user typed this: {}'.format(event.keyboard_text.text))

        def on_text_input_2(event):
            print('2 - user typed this: {}'.format(event.keyboard_text.text))

        # somewhere inside a Scene instance...
        self.input.register_callback(Event.keyboard_text, on_text_input_1)
        # this will cancel the previous callback (i.e. on_text_input_1 will never be called):
        self.input.register_callback(Event.keyboard_text, on_text_input_2)

    If you pass :code:`None` as callback_func, it will unregister the currently existing callback for that even type or
    do nothing if no callback for that type is currently registered.

    .. code-block:: python

        from kaa.input import EventType

        def on_text_input(event):
            print('user typed this: {}'.format(event.keyboard_text.text))

        # somewhere inside a Scene instance...
        self.input.register_callback(Event.keyboard_text, on_text_input)
        self.input.register_callback(Event.keyboard_text, None) # unregisters the callback, on_text_input won't be called


:class:`KeyboardManager` reference
----------------------------------

.. class:: KeyboardManager

Keyboard manager can be accessed via the :ref:`InputManager.keyboard <InputManager.keyboard>` property.

It allows to check the state (pressed or released) of given key.

Instance methods:

.. method:: KeyboardManager.is_pressed(keycode)

    Checks if a specific key is pressed - keycode param must be a :class:`Keycode` enum value.

    .. code-block:: python

        from kaa.input import Keycode

        # somewhere inside a Scene instance...
        if self.input.keyboard.is_pressed(Keycode.w):
            # ... do something if w is pressed
        if self.input.keyboard.is_pressed(Keycode.W):
            # ... do something if W is pressed
        if self.input.keyboard.is_pressed(Keycode.return_):
            # ... do something if ENTER key is pressed


.. method:: KeyboardManager.is_released(keycode)

    Checks if a specific key is released - keycode param must be a :class:`Keycode` enum value.

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

Instance properties:

.. attribute:: MouseManager.relative_mode

    Gets or sets relative mode (as bool). Default is :code:`False`. Enabling relative mode has two effects: it
    hides the mouse pointer and it makes mouse motion events (:class:`MouseMotionEvent`) be published all the time
    (by default those events are published only if mouse moves within game's window). Disabling the relative mode
    shows the mouse pointer and makes mouse motion events be published only if mouse movement occurs within the
    window.


Instance methods:

.. method:: MouseManager.is_pressed(mousebutton)

    Checks if given mouse button is pressed - mousebutton param must be a :class:`MouseButton` enum value.

    .. code-block:: python

        from kaa.input import MouseButton

        #somewhere inside a Scene instance...
        if self.input.mouse.is_pressed(MouseButton.left):
            # do something if the left mouse button is pressed

.. method:: MouseManager.is_released(mousebutton)

    Checks if given mouse button is released - mousebutton param must be a :class:`MouseButton` enum value.

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

                if event.controller_device:
                    if event.controller_device.is_added:
                        print('New controller connected: id is {}'.format(event.controller_device.id))
                        self.connected_controller_ids.append(event.controller_device.id)
                    elif event.controller_device.is_removed:
                        print('Controller disconnected: id is {}'.format(event.controller_device.id))
                        self.connected_controller_ids.remove(event.controller_device.id)

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

    Checks if given controller button is pressed. The controller_button param must be a :class:`ControllerButton` enum
    value. Check out the :ref:`example above <controller_id_example>` on how to obtain the controller_id.

    For example, to check the state of B button on controller 0:

    .. code-block:: python

        from kaa.input import ControllerButton

        # somewhere in the Scene class:
        if self.input.controller.is_pressed(ControllerButton.b, 0):
            print('B is pressed on controller 0!')


.. method:: ControllerManager.is_released(controller_button, controller_id)

    Checks if given controller button is released on given controller. The controller_button param
    must be a :class:`ControllerButton` enum value. Check out the :ref:`example above <controller_id_example>` on how to
    obtain the controller_id.

    For example, to check the state of B button on controller 2:

    .. code-block:: python

        from kaa.input import ControllerButton

        # somewhere in the Scene class:
        if self.input.controller.is_released(ControllerButton.b, 2):
            print('B is released on controller 2!')


.. method:: ControllerManager.is_axis_pressed(axis, controller_id)

    Checks if given stick axes or trigger is in non-zero position. The axis param must be
    of :class:`ControllerAxis` enum value. Check out the :ref:`example above <controller_id_example>` on how to obtain
    the controller_id.

    For example, to check if controller 1 left trigger is pressed:

    .. code-block:: python

        from kaa.input import ControllerAxis

        # somewhere in the Scene class:
        if self.input.controller.is_axis_pressed(ControllerAxis.trigger_left, 1):
            print('Left trigger is pressed!')

.. method:: ControllerManager.is_axis_released(axis, controller_id)

    Same as above, but checks if given stick axes or trigger is in a zero position. The axis param must be
    of :class:`ControllerAxis` enum value. Check out the :ref:`example above <controller_id_example>` on how to obtain the
    controller_id.

.. method:: ControllerManager.get_axis_motion(axis, controller_id)

    Gets an exact value of given stick axes motion or trigger as a number between 0 (stick axes or trigger in
    zero position) and 1 (stick axes or trigger in max position). The axis param must be  of :class:`ControllerAxis`
    enum value. Check out the :ref:`example above <controller_id_example>` on how to obtain the controller_id.

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

    Returns state of given stick as a :class:`geometry.Vector`.

    The compound_axis parameter must be of :class:`CompoundControllerAxis` enum value.

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
maximize or minimize it, and so on. Kaa engine detects all those events and makes them consumable either via
:meth:`InputManager.events()` method or by registering a callback function :meth:`InputManager.register_callback()`.

Each :class:`Event` **instance** has identical structure with the following instance properties:

* :code:`type` - returns event type
* :code:`timestamp` - returns time of the event occurrence
* :code:`system` - stores :class:`SystemEvent` instance if this event is a system related event, otherwise it will be :code:`None`
* :code:`window` - stores :class:`WindowEvent` instance if this event is a window related event, otherwise it will be :code:`None`
* :code:`keyboard_key` - stores :class:`KeyboardKeyEvent` instance if this event is a keyboard key related event, otherwise it will be :code:`None`
* :code:`keyboard_text` - stores :class:`KeyboardTextEvent` instance if this event is a keyboard text related event, otherwise it will be :code:`None`
* :code:`mouse_button` - stores :class:`MouseButtonEvent` instance if this event is a mouse button related event, otherwise it will be :code:`None`
* :code:`mouse_motion` - stores :class:`MouseMotionEvent` instance if this event is a mouse motion related event, otherwise it will be :code:`None`
* :code:`mouse_wheel` - stores :class:`MouseWheelEvent` instance if this event is a mouse wheel related event, otherwise it will be :code:`None`
* :code:`controller_device` - stores :class:`ControllerDeviceEvent` instance if this event is a controller device related event, otherwise it will be :code:`None`
* :code:`controller_button` - stores :class:`ControllerButtonEvent` instance if this event is a controller button related event, otherwise it will be :code:`None`
* :code:`controller_axis` - stores :class:`ControllerAxisEvent` instance if this event is a controller axis related event, otherwise it will be :code:`None`
* :code:`audio` - stores :class:`AudioEvent` instance if this event is an audio related event, otherwise it will be :code:`None`

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
            elif event.keyboard_key:
                # do something if it's a keyboard key event
            elif event.keyboard_text:
                # do something if it's a keyboard text event
            elif event.mouse_button:
                # do something if it's a mouse button event
            elif event.controller_button:
                # do something if it's a controller button event
            elif event.audio:
                # do something if it's audio event
            # ... and so on ...


Event **class** also has descriptors ("static properties") that return appropariate event types:

* Event.system - returns :class:`SystemEvent` type
* Event.window - returns :class:`WindowEvent` type
* Event.keyboard_key - returns :class:`KeyboardKeyEvent` type
* Event.keyboard_text - returns :class:`KeyboardTextEvent` type
* Event.mouse_button - returns :class:`MouseButtonEvent` type
* Event.mouse_motion - returns :class:`MouseMotionEvent` type
* Event.mouse_wheel - returns :class:`MouseWheelEvent` type
* Event.controller_device - returns :class:`ControllerDeviceEvent` type
* Event.controller_button - returns :class:`ControllerButtonEvent` type
* Event.controller_axis - returns :class:`ControllerAxisEvent` type
* Event.audio - returns :class:`AudioEvent` type

which allows checking the :code:`type` property on the event instance:

.. code-block:: python

    # ... inside a Scene...
    def update(self, dt):

        for event in self.input.events():
            if event.type == Event.system:
                # do something
            elif event.type == Event.keyboard_key:
                # do something ...
            elif event.type == Event.controller_axis:
                # do something ...
            # ... and so on

:class:`KeyboardKeyEvent` reference
-----------------------------------

.. class:: KeyboardKeyEvent

Represents an event of pressing or releasing a keyboard key.

See also: :class:`KeyboardTextEvent`

Instance properties:

.. attribute:: KeyboardEvent.key

    Returns the key this event is referring to, as :class:`Keycode` enum value.

.. attribute:: KeyboardEvent.is_key_down

    Returns :code:`True` if the key was pressed.

.. attribute:: KeyboardEvent.is_key_up

    Returns :code:`True` if the key was released.


:class:`KeyboardTextEvent` reference
------------------------------------

.. class:: KeyboardTextEvent

Represents an event of text being produced by the keyboard buffer. It lets you conveniently work with the text
being typed in by the player.

Instance properties:

.. attribute:: KeyboardTextEvent.text

    Returns string with the text typed in.

    For example, imagine a user with a polish keyboard pressing shift key, right alt and 's' keys, holding it for some
    time and then releasing all pressed keys.

    In a text editor it would result in typing something like this:

    :code:`ŚŚŚŚŚŚ`

    The way ths will be represented in the kaaengine event flow:

    1) You will first receive three :class:`KeyboardKeyEvent` events: one for pressing the shift key, another for pressing the alt key and one for pressing the s key
    2) You will then receive a number of :class:`KeyboardTextEvent` events, in this case we have six 'Ś' characters typed, so you will get six events. Reading the :code:`text` property on :class:`KeyboardTextEvent` will return "Ś" string.
    3) Finally, you will first receive three :class:`KeyboardKeyEvent` events: one for releasing the shift key, another for releasing the alt key and another one for releasing the s key


:class:`MouseButtonEvent` reference
-----------------------------------

.. class:: MouseButtonEvent

Represents a mouse button related event, such as pressing or releasing a mouse button.

    .. code-block:: python

        # ... inside a Scene instance...
        for event in self.input.events():
            if event.mouse_button:
                if event.mouse_button.is_button_down:
                    print("Mouse button {} is DOWN. Mouse position: {}.".format(event.mouse_button.button,
                          event.mouse_button.position))
                elif event.mouse_button.is_button_up:
                    print("Mouse button {} is UP. Mouse position: {}.".format(event.mouse_button.button,
                          event.mouse_button.position))


Instance properties:

.. attribute:: MouseButtonEvent.button

    Returns the button this event is referring to, as :class:`MouseButton` enum value.

.. attribute:: MouseButtonEvent.is_button_down

    Returns :code:`True` if the button was pressed.

.. attribute:: MouseButtonEvent.is_button_up

    Returns :code:`True` if the button was released.

.. attribute:: MouseButtonEvent.position

    Returns mouse pointer position, at the moment of the click, as :class:`geometry.Vector`.


:class:`MouseMotionEvent` reference
-----------------------------------

.. class:: MouseMotionEvent

Represents a mouse motion event (changing mouse pointer position). By default those events are published when
mouse pointer is within the window. You can enable the :code:`relative_mode` on the :class:`MouseManager` - it hides the
mouse pointer and makes mouse motion events be published whenever the pointer is moved (inside or outside of the
window).

    .. code-block:: python

        # ... inside a Scene instance...
        for event in self.input.events():
            if event.mouse_motion:
                 print("Mouse motion detected! New position is: {}.".format(event.mouse_motion.position))

Instance properties:

.. attribute:: MouseButtonEvent.position

    Returns mouse pointer position as :class:`geometry.Vector`.

.. attribute:: MouseButtonEvent.motion

    Returns mouse pointer motion (difference between the current and previous position) as :class:`geometry.Vector`.


:class:`MouseWheelEvent` reference
-----------------------------------

.. class:: MouseWheelEvent

Represents a mouse wheel related event.

Instance properties:

.. attribute:: MouseWheelEvent.scroll

    Returns a :class:`geometry.Vector` indicating whether the mouse wheel was scrolled up or down. The :code:`y`
    property in the returned vector holds the value, the :code:`x` will always be zero.

    .. code-block:: python

        # ... inside a Scene instance...
        for event in self.input.events():
            if event.mouse_wheel:
                print("Mouse wheel event detected. Scroll is: {}.".format(event.mouse_wheel.scroll))


:class:`ControllerDeviceEvent` reference
----------------------------------------

Represents a controller device related event, such as controller connected or disconnected.

.. class:: ControllerDeviceEvent

    .. code-block:: python

        # ... inside a Scene instance...
        for event in self.input.events():
            if event.controller_device:
                if event.controller_device.is_added:
                    print("Controller with id={} connected.".format(event.controller_device.id)
                elif event.controller_device.is_removed:
                    print("Controller with id={} disconnected.".format(event.controller_device.id)

Instance properties:

.. attribute:: ControllerDeviceEvent.id

    Returns an id of controller this event is referring to.

.. attribute:: ControllerDeviceEvent.is_added

    Returns :code:`True` if controller was connected.

.. attribute:: ControllerDeviceEvent.is_removed

    Returns :code:`True` if controller was disconnected.


:class:`ControllerButtonEvent` reference
----------------------------------------

Represents a controller button related event, such as controller button pressed or released.

.. class:: ControllerButtonEvent

    **Note:** Controller triggers are considered sticks (axis) not buttons! Use :class:`ControllerAxisEvent` to check out
    events representing triggers changing state.

    .. code-block:: python

        # ... inside a Scene instance...
        for event in self.input.events():
            if event.controller_button:
                if event.controller_button.is_button_down:
                    print("Controller button {} on controller id={} was pressed.".format(
                          event.controller_button.button, event.controller_button.id)
                elif event.controller_button.is_button_up:
                    print("Controller button {} on controller id={} was released.".format(
                          event.controller_button.button, event.controller_button.id)

Instance properties:

.. attribute:: ControllerButtonEvent.id

    Returns an id of controller this event is referring to.

.. attribute:: ControllerButtonEvent.button

    Returns controller button this event is referring to, as :class:`ControllerButton` enum value.

.. attribute:: ControllerButtonEvent.is_button_down

    Returns :code:`True` if the button was pressed.

.. attribute:: ControllerButtonEvent.is_button_up

    Returns :code:`True` if the button was released.


:class:`ControllerAxisEvent` reference
--------------------------------------

Represents a controller axis related event, such as controller stick or trigger state change.

    .. code-block:: python

        # ... inside a Scene instance...
        for event in self.input.events():
            if event.controller_axis:
                print("Controller axis {} on controller id={} changed its state. New state is {}.".format(
                      event.controller_axis.axis, event.controller_axis.id, event.controller_axis.motion)

.. class:: ControllerAxisEvent

Instance properties

.. attribute:: ControllerAxisEvent.id

    Returns an id of controller this event is referring to.

.. attribute:: ControllerAxisEvent.axis

    Returns axis (controller stick or trigger) this event is referring to, as :class:`ControllerAxis` enum value.

.. attribute:: ControllerAxisEvent.motion

    Returns the axis (controller stick or trigger) state, as a :class:`geometry.Vector`. The length of the vector
    will be between 0 (stick or trigger is in neutral position) and 1 (stick or trigger is in its maximum position)


:class:`AudioEvent` reference
-----------------------------

.. class:: AudioEvent

Represents an audio related event.

Instance properties:

.. attribute:: AudioEvent.music_finished

    Returns :code:`True` if current music track finished playing.


:class:`WindowEvent` reference
------------------------------

.. class:: WindowEvent

Represents a window related event.

Instance properties:

.. attribute:: WindowEvent.is_shown

    Returns :code:`True` if the window was shown.

.. attribute:: WindowEvent.is_exposed

    Returns :code:`True` if the window was exposed.

.. attribute:: WindowEvent.is_moved

    Returns :code:`True` if the window was moved.

.. attribute:: WindowEvent.is_resized

    Returns :code:`True` if the window was resized.

.. attribute:: WindowEvent.is_minimized

    Returns :code:`True` if the window was minimized.

.. attribute:: WindowEvent.is_maximized

    Returns :code:`True` if the window was maximized.

.. attribute:: WindowEvent.is_restored

    Returns :code:`True` if the window was restored.

.. attribute:: WindowEvent.is_enter

    Returns :code:`True` if the mouse pointer entered the window area.

.. attribute:: WindowEvent.is_leave

    Returns :code:`True` if the mouse pointer left the window area.

.. attribute:: WindowEvent.is_focus_gained

    Returns :code:`True` if the window gained a focus.

.. attribute:: WindowEvent.is_focus_lost

    Returns :code:`True` if the window lost a focus.

.. attribute:: WindowEvent.is_close

    Returns :code:`True` if the window was closed.


:class:`SystemEvent` reference
------------------------------

.. class:: SystemEvent

Represents a system related event.

Instance properties:

.. attribute:: SystemEvent.quit

    Returns :code:`True` if the game proces is terminating.

.. attribute:: SystemEvent.clipboard_updated

    Returns :code:`True` if the system clipboard was updated. You may call :meth:`SystemManager.get_clipboard_text()`
    method to check out the text in the system clipboard.


:class:`Keycode` reference
--------------------------

.. class:: Keycode

Enum type for referencing keyboard keys when working with :class:`KeyboardManager` and :class:`KeyboardKeyEvent`.

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

Enum type for referencing mouse buttons when working with :class:`MouseManager` and :class:`MouseButtonEvent`.

Available values are:

* :code:`MouseButton.left`
* :code:`MouseButton.middle`
* :code:`MouseButton.right`
* :code:`MouseButton.x1`
* :code:`MouseButton.x2`


:class:`ControllerButton` reference
-----------------------------------

.. class:: ControllerButton

Enum type for referencing controller buttons when working with :class:`ControllerManager` and :class:`ControllerButtonEvent`.
Note that left and right triggers are not buttons, they're considered axis (see :class:`ControllerAxisEvent`)

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

Enum type for referencing controller axes when working with :class:`ControllerManager` and :class:`ControllerAxisEvent`.

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

