Part 10: Transitions
====================

When writing a game you often want to apply a set of known transformations to an object. For example, you want your object
to move 100 pixels to the right, then wait 3 seconds and return 100 pixels to the left. Or you want to implement
pulsation effect where an object would smoothly change its scale between some min and max values. There's an unlimited
number of such visual transformations that you may want in your games as they greatly enhance game experience.

You can of course implement all this by having a set of boolean flags, time trackers, and other stuff on
an object instance and use all those helper variables to change the desired properties of your nodes manually.
But there is an easier way: the mechanism is called Transitions.

A single Transition object is a recipe of how a given property of a Node (position, scale, rotation, etc.) should
change over time. Transition can be applied to object once, given number of times or in a loop. You can chains transitions
to run serially or in parallel.

It's best to illustrate on an example, so let's do it!

Adding a Transition to a Node
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Let's practice transitions on a text node we have in the title screen.

Let's start by refactoring the code in :code:`__init__`:

.. code-block:: python
    :caption: scenes/title_screen.py

    class TitleScreenScene(Scene):

        def __init__(self):
            # ... cut the rest of the function ....
            self.exit_label = TextNode(font=registry.global_controllers.assets_controller.font_2, font_size=30,
                                         position=Vector(settings.VIEWPORT_WIDTH/2, 550), text="Press ESC to exit",
                                         z_index=1, origin_alignment=Alignment.center)
            self.root.add_child(self.exit_label)
            self.transitions_fun_stuff()

Then add the :code:`transitions_fun_stuff` method:

.. code-block:: python
    :caption: scenes/title_screen.py

    from kaa.transitions import *

    def transitions_fun_stuff(self):
        my_transition = NodePositionTransition(Vector(300, 850), duration=3000)
        self.exit_label.transition = my_transition

Run the game and see the label moving from its original position to (300, 850), the movement takes 3 seconds! Isn't it
cool?

Changing a value incrementally
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The transition we wrote takes node position and changes it (over 3 seconds) to the final value. But what if we don't
want to move a node to a know position, but just 50 pixels to the left and 200 pixels down?

.. code-block:: python
    :caption: scenes/title_screen.py

    def transitions_fun_stuff(self):
        my_transition = NodePositionTransition(Vector(-50, 200), duration=3000,
                                               advance_method=AttributeTransitionMethod.add)
        self.exit_label.transition = my_transition

Available :code:`advance_method` values are:

* kaa.transitions.AttributeTransitionMethod.set - the default mode. The target value is set directly.
* kaa.transitions.AttributeTransitionMethod.add - The target value will be calculated by adding operation
* kaa.transitions.AttributeTransitionMethod.multiply - The target value will be calculated by multiplying operation

Running transition back and forth
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To run transition back and forth simply set :code:`back_and_forth=True` on a transition object:

.. code-block:: python
    :caption: scenes/title_screen.py

    def transitions_fun_stuff(self):
        my_transition = NodePositionTransition(Vector(-50, 200), duration=3000,
                                               advance_method=AttributeTransitionMethod.add,
                                               back_and_forth=True)
        self.exit_label.transition = my_transition


Running transition specific number of times
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To run transition specific number of times, set :code:`loops` on a transition object to a desired value:

.. code-block:: python
    :caption: scenes/title_screen.py

    def transitions_fun_stuff(self):
        my_transition = NodePositionTransition(Vector(-50, 200), duration=3000,
                                               advance_method=AttributeTransitionMethod.add,
                                               back_and_forth=True, loops=3)
        self.exit_label.transition = my_transition

Run it and see that it moves back and forth 3 times.

.. note::
    See what happens if you set loops to some value without :code:`back_and_forth` set to :code:`False`

Running transition infinite number of times
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To run transition in an infinite loop set :code:`loops` on a transition object to 0.

All types of transitions
~~~~~~~~~~~~~~~~~~~~~~~~

We've learned about :code:`NodePositionTransition` but what other transitions are available?

* :code:`kaa.transitions.NodePositionTransition` - changes position of a node
* :code:`kaa.transitions.NodeRotationTransition` - changes rotation of a node
* :code:`kaa.transitions.NodeScaleTransition` - changes scale of a node
* :code:`kaa.transitions.NodeColorTransition` - changes color of a node
* :code:`kaa.transitions.BodyNodeVelocityTransition` - changes velocity of a node (applicable to BodyNodes only)
* :code:`kaa.transitions.BodyNodeAngularVelocityTransition` - changes angular velocity of a node (applicable to BodyNodes only)
* :code:`kaa.transitions.NodeTransitionDelay` - waits for given number of miliseconds - useful when you chain few transitions together

It is also possible to write custom transitions, it's covered further below.

Chaining transitions
~~~~~~~~~~~~~~~~~~~~

Let's build a chain of transitions: first we want the node to change its position, then rotate, then
wait 0.5 second, then scale, and finally change color. To build such a sequence we'll use :code:`NodeTransitionsSequence`

.. code-block:: python
    :caption: scenes/title_screen.py

    from kaa.colors import Color

    def transitions_fun_stuff(self):
        move_transition = NodePositionTransition(Vector(-50, 200), duration=1000, advance_method=AttributeTransitionMethod.add)
        rotate_transition = NodeRotationTransition(2*math.pi, duration=1000) # rotate 180 degrees (2*pi radians)
        wait_transition = NodeTransitionDelay(duration=500)
        scale_transition = NodeScaleTransition(Vector(2, 2), duration=1000) # enlarge twice
        color_transition = NodeColorTransition(Color(1, 0, 0, 1), duration=1000) # change color to red
        transition_sequence = NodeTransitionsSequence([move_transition, rotate_transition, wait_transition,
                                                       scale_transition, color_transition])
        self.exit_label.transition = transition_sequence

Run the game and enjoy the nice transition sequence!

:code:`NodeTransitionsSequence` has two already known properties: :code:`back_and_forth` and :code:`loops`. You can
use them to run the whole sequence back and forth, specific number of times or in an infinite loop.

Knowing that a transition has ended
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sometimes we may want to be able to run some code when transition has ended, or when we reached some point in a
chain of transition. We can use :code:`NodeTransitionCallback`. It's only parameter is a callable. Let's show this
on an example:

.. code-block:: python
    :caption: scenes/title_screen.py

    def transition_callback_function(self, node):
        # play explosion sound
        registry.global_controllers.assets_controller.explosion_sound.play()

    def transitions_fun_stuff(self):
        move_transition = NodePositionTransition(Vector(-50, 200), duration=1000, advance_method=AttributeTransitionMethod.add)
        callback_transition = NodeTransitionCallback(self.transition_callback_function) # call that function
        rotate_transition = NodeRotationTransition(2*math.pi, duration=1000) # rotate 180 degrees (2*pi radians)
        wait_transition = NodeTransitionDelay(duration=500)
        scale_transition = NodeScaleTransition(Vector(2, 2), duration=1000) # enlarge twice
        color_transition = NodeColorTransition(Color(1, 0, 0, 1), duration=1000) # change color to red
        transition_sequence = NodeTransitionsSequence([move_transition, callback_transition,
                                                       rotate_transition, wait_transition,
                                                       scale_transition, color_transition])
        self.exit_label.transition = transition_sequence

It's pretty self-explanatory isn't it? callback_transition is executed between move_transition and rotate_transition
therefore we hear explosion sound at that very moment.

Running transitions in paralel
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Let's say we want to run some transitions (or sequences of those) in paralel. It's quite easy: we need to use
:code:`NodeTransitionsParallel`. Let's have our node rotate, scale, change color and move at the same time.

.. code-block:: python
    :caption: scenes/title_screen.py

    def transitions_fun_stuff(self):
        rotate_transition = NodeRotationTransition(2*math.pi, duration=1000) # rotate 180 degrees (2*pi radians)
        scale_transition = NodeScaleTransition(Vector(2, 2), duration=1000) # enlarge twice
        color_transition = NodeColorTransition(Color(1, 0, 0, 1), duration=1000) # change color to red

        self.exit_label.transition = NodeTransitionsParallel([rotate_transition, scale_transition, color_transition],
                                                             back_and_forth=True, loops=0)

Note that :code:`NodeTransitionsParallel` has two already known properties: :code:`back_and_forth` and :code:`loops`.

You can nest transition sequences in other sequences, run such nested sequences in paralel and so on. Just be careful
on which level you set :code:`back_and_forth` and :code:`loops`. Feel free to experiment with transitions on your own.

Contradictory transitions?
~~~~~~~~~~~~~~~~~~~~~~~~~~

What happens if you try to run two position transitions in paralel: one moving a node 100 pixels to the right and
the other moving it 100 pixels to the left. Contrary to intuition, they won't cancel out (regardless of
:code:`advance_method` being add or set). If there are two or more transitions of the same type running in paralel,
then the one which is later in the list will be used and the preceding ones will be ignored.

Implementing custom transitions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO

Different easing patterns
~~~~~~~~~~~~~~~~~~~~~~~~~

As you probably noticed, transitions change the property of a node over time in a linear fashion. In other words,
if transition orders the node to change rotation by 100 degrees in 10 seconds then the node will progress at a
steady rate of 10 degrees per second.

Future kaa versions will have more types of "easing functions", other than linear, `expect something similar to this <https://easings.net/>`_

Let's move on to :doc:`the last part of the tutorial </tutorial/part11>` where we'll build the game as executable
file (.exe on Windows or binary executable on Linux)