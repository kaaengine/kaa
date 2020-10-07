:mod:`timers` --- a simple timer
================================
.. module:: timers
    :synopsis: a simple timer


:class:`Timer` reference
------------------------

.. class:: Timer(callback_func, interval, single_shot=True)

    Timer will call the :code:`callback_func` after time specified by the :code:`interval` parameter has passed. The
    interval value is in miliseconds.

    If :code:`single_shot` is set to :code:`False` the timer will call the callback func in regular intervals.

    Timer starts the countdown when you call the :meth:`start()` method. Calling :meth:`start()` on a running timer
    resets it.

    Calling :meth:`stop()` stops the timer.

    .. code-block:: python

        def my_func():
            print('triggered by the timer')

        timer = Timer(1000, my_func)
        timer.start()

Instance properties:

.. attribute:: Timer.is_running

    Returns :code:`True` if the timer is running.

.. attribute:: Timer.interval

    Gets or sets the timer interval, as int (miliseconds)

.. attribute:: Timer.single_shot

    Gets or sets the single shot flag, as bool


Instance methods:

.. method:: Timer.start()

    Starts the timer. Calling :meth:`start()` resets the timer - calling it on a running timer will make the timer
    count down from the start.

.. method:: Timer.stop()

    Stops the timer.

