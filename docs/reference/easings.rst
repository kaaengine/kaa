:mod:`easings` --- Easing effects for transitions
=================================================
.. module:: easings
    :synopsis: Easing effects for transitions


:class:`Easing` reference
-------------------------

.. class:: Easing

    Enum type used for referencing easing types to work with transitions. :doc:`Read more about Transitions here </reference/transitions>`.
    It has the following values:

    * :code:`Easing.none` - default easing, representing a linear progress
    * :code:`Easing.back_in`
    * :code:`Easing.back_in_out`
    * :code:`Easing.back_out`
    * :code:`Easing.bounce_in`
    * :code:`Easing.bounce_in_out`
    * :code:`Easing.bounce_out`
    * :code:`Easing.circular_in`
    * :code:`Easing.circular_in_out`
    * :code:`Easing.circular_out`
    * :code:`Easing.cubic_in`
    * :code:`Easing.cubic_in_out`
    * :code:`Easing.cubic_out`
    * :code:`Easing.elastic_in`
    * :code:`Easing.elastic_in_out`
    * :code:`Easing.elastic_out`
    * :code:`Easing.exponential_in`
    * :code:`Easing.exponential_in_out`
    * :code:`Easing.exponential_out`
    * :code:`Easing.quadratic_in`
    * :code:`Easing.quadratic_in_out`
    * :code:`Easing.quadratic_out`
    * :code:`Easing.quartic_in`
    * :code:`Easing.quartic_in_out`
    * :code:`Easing.quartic_out`
    * :code:`Easing.quintic_in`
    * :code:`Easing.quintic_in_out`
    * :code:`Easing.quintic_out`
    * :code:`Easing.sine_in`
    * :code:`Easing.sine_in_out`
    * :code:`Easing.sine_out`

    .. image:: /files/easings.png

:meth:`ease` reference
----------------------

.. function:: ease(easing, t)

    Calculates the rate of change at time t for specific easing. The :code:`t` parameter should be a float with a
    value between 0 (start of transition) and 1 (end of transition). The :code:`easing` must be an
    :class:`easings.Easing` value.

    Returned value is a float.

    .. code-block:: python

        print("Half into transition time, the rate value with the default easing is {}".format(ease(Easing.none, 0.5)))
        print("Half into transition time, the rate value with exponential easing is {}".format(ease(Easing.exponential_in, 0.5)))


:meth:`ease_between` reference
------------------------------

.. function:: ease_between(easing, t, a, b)

    Calculates the actual value transitioning from :code:`a` to :code:`b` at time :code:`t` using given :code:`easing`.

    The a and b parameters must be either floats of vectors (:class:`geometry.Vector`).

    The t must be a float between 0 (start of transition) and 1 (end of transition)

    The :code:`easing` must be an :class:`easings.Easing` value.

    .. code-block:: python

        a = 50
        b = 100
        t = 0.5
        easing = Easing.none
        result = ease_between(a, b, t, easing)
        print('At time t={}, the value transitioning from a={} to b={} with easing {} will be {}'.format(t, a, b, str(easing), result))
        #  At time t=0.5, the value transitioning from a=50.0 to b=100.0 with easing Easing.none will be 75.0