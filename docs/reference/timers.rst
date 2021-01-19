:mod:`timers` --- a simple timer
================================
.. module:: timers
    :synopsis: a simple timer


:class:`Timer` reference
------------------------

.. class:: Timer(callback_func)

    Timer will call the :code:`callback_func` callable after time specified when calling the :meth:`start()` or
    :meth:`start_global()` method.

    The :code:`callback_func` callable implementation receives one parameter - :code:`timer_context` which is a
    :class:`TimerContext` instance.

    .. code-block:: python

        def my_func(self, timer_context):
            print('Triggered by the timer!')

        global_timer = Timer(my_func)
        global_timer.start_global(1.5)  # in seconds


    .. code-block:: python

        # ... somewhere inside a Scene:

        def my_func(self, timer_context):
            print('Triggered by the timer!')

        def add_timer(self):
            timer = Timer(my_func)
            timer.start(1.5, scene=self)  # in seconds


    The :code:`callback_func` may return a numeric value. It will reset the timer, allowing to run it in a loop:

    .. code-block:: python

        def my_func(self, timer_context):
            new_interval = random.uniform(1.0, 2.0)
            print('Resetting the timer with interval of {} seconds'.format(new_interval))
            return new_interval  # this resets the timer

        global_timer = Timer(my_func)
        global_timer.start_global(1.5)  # in seconds


Instance properties:

.. attribute:: Timer.is_running

    Returns :code:`True` if the timer is running.

Instance methods:

.. method:: Timer.start(interval, scene)

    Starts the timer in a context of a specific :class:`engine.Scene` instance. After :code:`interval` seconds, the
    timer's callback function (defined in the constructor) will be invoked.

    There are few reasons why you may want a scene instance associated with a timer:

    * If you change scene to a new one, the timers associated with the previous scene will stop running automatically
    * When a scene gets destroyed, timers associated with that scene will be destroyed as well and you won't receive any surprise callbacks.
    * Timers utilize :attr:`engine.Scene.time_scale` property.

    Calling :meth:`start()` on a running timer resets the timer.

.. method:: Timer.start_global(interval)

    Same as :meth:`start()` but does not require passing a scene. Use it if you need a "global" timer.

.. method:: Timer.stop()

    Stops the timer.

:class:`TimerContext` reference
-------------------------------

An object passed to timer's callback function

Instance properties:

.. attribute:: TimerContext.scene

    Read only. Gets the scene (as :class:`engine.Scene` instance). Will be None if timer was called with
    :meth:`Timer.start_global()` method.

.. attribute:: TimerContext.interval

    Read only. Interval with which the timer was called.
