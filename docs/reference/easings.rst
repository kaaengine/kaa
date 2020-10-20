:mod:`easings` --- Easing effects for transitions
=================================================
.. module:: easings
    :synopsis: Easing effects for transitions


:class:`Easing` reference
-------------------------

.. class:: Easing

    Enum type used for referencing easing types to work with transitions. :doc:`Read more about Transitions here </reference/transitions>`.
    It has the following values:

    * :code:`Easing.none`
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

.. function:: ease(easing, progress)

    TODO


:meth:`ease_between` reference
------------------------------

.. function:: ease_between(easing, progress, a, b)

    TODO
