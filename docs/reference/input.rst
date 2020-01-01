:mod:`input` --- Handling input from keyboard, mouse and controllers
====================================================================
.. module:: input
    :synopsis: Handling input from keyboard, mouse and controllers

:class:`InputManager` reference
-------------------------------

.. class:: InputManager

Input manager object can be accessed via :ref:`Scene.input <Scene.input>` property. It has two main features:

* Gives you access to specialized managers: :class`MouseManager`, :class:`KeyboardManager`, :class:`ControllerManager` and :class:`SystemManager` - they offer methods to actively check for input from your code. For instance, you can ask the :class:`KeyboardManager` if given key is pressed or released.
* Gives you access to a stream of events via the :meth:`events()` method. For example, an event gets published when user pressed a key on a keyboard or clicks a mouse button. Check out the :class:`Event` documentation for a list of all available events.

Instance Properties:

.. _InputManager.keyboard:
.. attribute:: InputManager.keyboard

    A get accessor returning :class:`KeyboardManager` object which exposes methods to actively check for keyboard input.
    See the :class:`KeyboardManager` documentation for a full list of available methods.

.. _InputManager.mouse:
.. attribute:: InputManager.mouse

    A get accessor returning :class:`MouseManager` object which exposes methods to actively check for mouse input.
    See the :class:`MouseManager` documentation for a full list of available methods.

.. _InputManager.controller:
.. attribute:: InputManager.controller

    A get accessor returning :class:`ControllerManager` object which exposes methods to actively check for controller input.
    See the :class:`ControllerManager` documentation for a full list of available methods.

.. _InputManager.system:
.. attribute:: InputManager.system

    A get accessor returning :class:`SystemManager` object which exposes methods to actively check for system input.
    See the :class:`SystemManager` documentation for a full list of available methods.

Instance Methods:

.. method:: InputManager.events()

    Returns a list of :class:`Event` objects that ocurred during the last frame. Check out the :class:`Event`
    documentation for list of properties and methods available.

:class:`KeyboardManager` reference
----------------------------------

.. class:: KeyboardManager

Keyboard manager can be accessed via the :ref:`InputManager.keyboard <InputManager.keyboard>` property.

It allows to actively check for keyboard input from your code.

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

Allows to actively check for mouse input (buttons being pressed or released) from your code. It also allows to get
the mouse pointer position.

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

TODO

:class:`SystemManager` reference
--------------------------------

.. class:: SystemManager

TODO


:class:`Event` reference
------------------------

.. class:: Event

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

TODO

:class:`ControllerAxis` reference
---------------------------------

.. class:: ControllerAxis

TODO