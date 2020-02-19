:mod:`transitions` --- A quick and easy way to automate transforming your nodes
===============================================================================
.. module:: transitions
    :synopsis: A quick and easy way to automate transforming your nodes

When writing a game you'll often want to apply a set of known transformations to a :class:`nodes.Node`. For example, you want your
Node to move 100 pixels to the right, then wait 3 seconds and return 100 pixels to the left. Or you'll want the node
to pulsate (smoothly change its scale between some min and max values), or rotate back and forth. YOu may want to have
any combination of those effects applied (either one after another or parallel). There’s an unlimited number of such
visual transformations and their combinations, that you may want to have in your game.

You can of course implement all this, by having a set of boolean flags, time trackers, etc. and use all those helper
variables to manually change the desired properties of your nodes from within the update() method. But there is an
easier way: the mechanism is called Transitions. A single Transition object is a recipe of how a given property
of a Node (position, scale, rotation, color, etc.) should change over time. Transition can be played once,
given number of times or in a loop. You can also chains transitions to run one after another or in parallel.

Common transition parameters
----------------------------

To create a Transition you'll typically need to pass the following parameters:

* :code:`advance_value` - advance value for given transition type (e.g. target position for :class:`NodePositionTransition`).
* :code:`duration` - transition duration time, in miliseconds
* :code:`advance_method` - an enum value of :class:`AttributeTransitionMethod` type which determines how the :code:`advance_value` will be applied to modify the appropriate node property.
    * :code:`AttributeTransitionMethod.set` - node's property will be changed towards the target advance_value over time
    * :code:`AttributeTransitionMethod.add` - node's property will be changed by adding the advance_value over time
    * :code:`AttributeTransitionMethod.multiply` - node's property will be changed by multiplying the advance_value over time
* :code:`loops` - how many times the transition should "play". Set to 0 to play infinite number of times.
* :code:`back_and_forth` - if set to :code:`True`, the transition will be played back and forth.

All transitions use linear easing. More built-in easing types to be added soon.

Examples
--------

Change position of a node, from (100,100) to (30, 70) over 2 seconds.

.. code-block:: python

    node = Node(position=Vector(100, 100), sprite=Sprite('image.png'))
    node.transition = NodePositionTransition(Vector(30, 70), 2000)


Change position of a node, from (100,100) by (30, 70), i.e. to (130, 170) over 2 seconds.

.. code-block:: python

    node = Node(position=Vector(100, 100), sprite=Sprite('image.png'))
    node.transition = NodePositionTransition(Vector(30, 70), 2000, advance_method=AttributeTransitionMethod.add)

Change position of a node, from (100, 100) by (x30, x70), i.e. to (3000, 7000) over 2 seconds.

.. code-block:: python

    node = Node(position=Vector(100, 100), sprite=Sprite('image.png'))
    node.transition = NodePositionTransition(Vector(30, 70), 2000, advance_method=AttributeTransitionMethod.multiply)

Change position of a node, from (100,100) to (30, 70) then back to the initial position (100,100) over 2 seconds.

.. code-block:: python

    node = Node(position=Vector(100, 100), sprite=Sprite('image.png'))
    node.transition = NodePositionTransition(Vector(30, 70), 2000, back_and_forth=True)

Change position of a node, from (100,100) to (30, 70) then get back to the initial position over 2 seconds. Repeat
it 3 times.

.. code-block:: python

    node = Node(position=Vector(100, 100), sprite=Sprite('image.png'))
    node.transition = NodePositionTransition(Vector(30, 70), 2000, loops=3, back_and_forth=True)

Change the scale of a node (twice on the X axis and three times on the Y axis) over 1 second.

.. code-block:: python

    node = Node(position=Vector(100, 100), sprite=Sprite('image.png'))
    node.transition = NodeScaleTransition(Vector(2, 3), 1000)

Change the scale of a node (twice on the X axis and three times on the Y axis) over 1 second. Repeat indefinitely
(creating pulsation effect).

.. code-block:: python

    node = Node(position=Vector(100, 100), sprite=Sprite('image.png'))
    node.transition = NodeScaleTransition(Vector(2, 3), 1000, loops=0)

Rotate the node 90 degrees clockwise over 3 seconds

.. code-block:: python

    node = Node(position=Vector(100, 100), sprite=Sprite('image.png'))
    node.transition = NodeRotationTransition(math.pi/2, 3000)

Change position of a node by (150, 100) over 2 seconds, then enlarge it twice over 1 second, then do nothing for
2 seconds, finally rotate it 180 degrees over 3 seconds. Play the whole sequence two times, back and forth.

.. code-block:: python

    node = Node(position=Vector(100, 100), sprite=Sprite('image.png'))
    transitions = [
        NodePositionTransition(Vector(150, 100), 2000, advance_method=AttributeTransitionMethod.add),
        NodeScaleTransition(Vector(2, 2), 1000)
        NodeTransitionDelay(2000)
        NodeRotationTransition(math.pi, 3000)
    ]
    node.transition = NodeTransitionsSequence(transitions, loops=2, back_and_forth=True)

Do everything the same like in previous example but have the node *simultaneously* change its color to red,
back and forth in 1500 milisecond intervals.

.. code-block:: python

    node = Node(position=Vector(100, 100), sprite=Sprite('image.png'))
    transitions = [
        NodePositionTransition(Vector(150, 100), 2000, advance_method=AttributeTransitionMethod.add),
        NodeScaleTransition(Vector(2, 2), 1000)
        NodeTransitionDelay(2000)
        NodeRotationTransition(math.pi, 3000)
    ]
    color_transition = NodeColorTransition(Color(1,0,0,1), 1500, loops=0, back_and_forth=True)

    node.transition = NodeTransitionsParalel([
        color_transition,
        NodeTransitionsSequence(transitions, loops=2, back_and_forth=True)
    ])


Change position of a node, from (100,100) to (30, 70) over 2 seconds and call function my_func when the transition ends.

.. code-block:: python

    def my_func(transitioning_node):
        print('Function called!')

    node = Node(position=Vector(100, 100), sprite=Sprite('image.png'))
    node.transition = NodeTransitionSequence([
        NodePositionTransition(Vector(30, 70), 2000),
        NodeTransitionCallback(my_func)])



:class:`NodePositionTransition` reference
-----------------------------------------

.. class:: NodePositionTransition(advance_value, duration, advance_method=AttributeTransitionMethod.set, loops=1, back_and_forth=False)

    Use this transition to change Node's position gradually over time, towards given advance_value or by given advance_value.

    The :code:`advance_value` param must be a :class:`geometry.Vector` and is the target position value (or position change value)

    Refer to the `Common transition parameters`_ and `Examples`_ sections for information on other parameters used by the transition.


:class:`NodeRotationTransition` reference
-----------------------------------------


.. class:: NodeRotationTransition(advance_value, duration, advance_method=AttributeTransitionMethod.set, loops=1, back_and_forth=False)

    Use this transition to change Node's rotation gradually over time, towards given advance_value or by given advance_value.

    The :code:`advance_value` param must be a float and is the target rotation value (or rotation change value), *in radians*.

    Refer to the `Common transition parameters`_ and `Examples`_ sections for information on other parameters used by the transition.


:class:`NodeScaleTransition` reference
--------------------------------------

.. class:: NodeScaleTransition(value, duration, advance_method=AttributeTransitionMethod.set, loops=1, back_and_forth=False)

    Use this transition to change Node's scale gradually over time, towards given advance_value or by given advance_value.

    The :code:`advance_value` param must be a :class:`geometry.Vector` and is the target scale value (or scale change value) for X and Y axis respectively.

    Refer to the `Common transition parameters`_ and `Examples`_ sections for information on other parameters used by the transition.


:class:`NodeColorTransition` reference
--------------------------------------


.. class:: NodeColorTransition(value, duration, advance_method=AttributeTransitionMethod.set, loops=1, back_and_forth=False)

    Use this transition to change Node's scale gradually over time, towards given advance_value or by given advance_value.

    The :code:`advance_value` param must be a :class:`colors.Color` and is the target color value (or color change value).

    Note that each component of the color (R, G, B, and A) is trimmed to a 0-1 range, so when using
    :code:`advance_method=AttributeTransitionMethod.set` or :code:`advance_method=AttributeTransitionMethod.multiply`
    which would result in R G B or A going above 1 or below 0 - the value will be capped at 1 and 0 respectively.

    Refer to the `Common transition parameters`_ and `Examples`_ sections for information on other parameters used by the transition.


:class:`BodyNodeVelocityTransition` reference
---------------------------------------------

.. class:: BodyNodeVelocityTransition(value, duration, advance_method=AttributeTransitionMethod.set, loops=1, back_and_forth=False)

    Use this transition to change BodyNode's velocity gradually over time, towards given advance_value or by given advance_value.

    The :code:`advance_value` param must be a :class:`geometry.Vector` and is the target velocity value (or velocity change value).

    Refer to the `Common transition parameters`_ and `Examples`_ sections for information on other parameters used by the transition.


:class:`BodyNodeAngularVelocityTransition` reference
----------------------------------------------------

.. class:: BodyNodeAngularVelocityTransition(value, duration, advance_method=AttributeTransitionMethod.set, loops=1, back_and_forth=False)

    Use this transition to change BodyNode's angular velocity gradually over time, towards given advance_value or by given advance_value.

    The :code:`advance_value` param must be a number and is the target angular velocity value (or angular velocity change value), *in radians*

    Refer to the `Common transition parameters`_ and `Examples`_ sections for information on other parameters used by the transition.


:class:`NodeTransitionsSequence` reference
------------------------------------------

.. class:: NodeTransitionSequence(transitions, loops=1, back_and_forth=False)

    A wrapping container used to chain transitions into a sequence. The sequence will run one transition at a time,
    next one being executed when the previous one finishes.

    The :code:`transitions` parameter is an iterable of transitions.

    The iterable can include a list of 'atomic' transitions such as :class:`NodePositionTransition`,
    :class:`NodeScaleTransition`,  :class:`NodeColorTransition` etc. as well as other
    :class:`NodeTransitionSequence`, or :class:`NodeTransitionsParallel` thus building
    a more complex structure.

    The loops and back_and_forth parameters work normally, but are applied to the whole sequence.

    See the `Examples`_ sections for a sample code using NodeTransitionSequence.


:class:`NodeTransitionsParallel` reference
------------------------------------------

.. class:: NodeTransitionsParallel(transitions)

    A wrapping container used to make transitions run in parallel.

    The :code:`transitions` parameter is an iterable of transitions which will be executed simultaneously.

    The iterable can include a list of 'atomic' transitions such as :class:`NodePositionTransition`,
    :class:`NodeScaleTransition`,  :class:`NodeColorTransition` etc. as well as other
    :class:`NodeTransitionSequence`, or :class:`NodeTransitionsParallel` thus building
    a more complex structure.

    You may have two contradictory transitions running in paralel, for example two :class:`NodePositionTransition`
    trying to change node position in opposite directions. Contrary to intuition, they won’t cancel out (regardless
    of advance_method being :code:`add` or :code:`set`). If there are two or more transitions of the same type running in paralel,
    then the one which is later in the list will be used and all the preceding ones will be ignored.

    The loops and back_and_forth parameters are not being used.

    See the `Examples`_ sections for a sample code using NodeTransitionsParallel.


:class:`NodeTransitionDelay` reference
--------------------------------------

.. class:: NodeTransitionDelay(duration)

    Use this transition to create a delay between transitions in a sequence.

    The :code:`duration` paramter is a number of miliseconds.

    See the `Examples`_ sections for more information.


:class:`NodeTransitionCallback` reference
-----------------------------------------

.. class:: NodeTransitionCallback(callback_func)

    Use this transition to get your own function called at a specific moment in a transitions sequence. A typical use
    case is to find out that a transition has ended.

    The :code:`callback_func` must be a callable.

    See the `Examples`_ sections for a sample code using NodeTransitionCallback


:class:`NodeCustomTransition` reference
---------------------------------------

.. class:: NodeCustomTransition(prepare_func, evaluate_func, duration, loops=1, back_and_forth=False)

    Use this class to write your own transition.

    :code:`prepare_func` must be a callable. It will be called once, before the transition is played. It receives one
    parameter - a node. It can return any value, which will later be used as input to :code:`evaluate_func`

    :code:`evaluate_func` must be a callable. It will be called on each frame and it's the place where you should
    implement the transition logic. It will receive three parameters: code:`state`, :code:`node` and :code:`t`.
    The :code:`state` is a value you have returned in the :code:`prepare_func` callable. The :code:`node` is a
    node which is transitioning. The :code:`t` parameter is a value between 0 and 1 which indicates
    transition time duration progress.

    The :code:`loops` and :code:`back_and_forth` paramters behave normally - see the `Common transition parameters`_
    section.

    .. code-block:: python

        custom_transition = NodeCustomTransition(
                lambda node: {'positions': [
                    Vector(random.uniform(-100, 100), random.uniform(-100, 100))
                    for _ in range(10)
                ]},
                lambda state, node, t: setattr(
                    node, 'position',
                    state['positions'][min(int(t * 10), 9)],
                ),
                10000.,
                loops=5,
            )


:class:`AttributeTransitionMethod` reference
--------------------------------------------

.. class:: AttributeTransitionMethod

Enum type used to identify value advance method when using transitions

Available values are:

* :code:`AttributeTransitionMethod.set`
* :code:`AttributeTransitionMethod.add`
* :code:`AttributeTransitionMethod.multiply`