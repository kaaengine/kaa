:mod:`physics` --- A 2D physics system, with rigid bodies, collisions and more!
===============================================================================
.. module:: physics
    :synopsis: A 2D physics system, with rigid bodies, collisions and more!

Kaa inlcudes a 2D physics engine which allows you to easily add physical features to objects in your game, handle
collisions etc. The idea is based on three types of specialized :doc:`nodes </reference/nodes>`:

* :class:`SpaceNode` - it represents physical simulation environment, introducing environmental properties such as gravity or damping.
* :class:`BodyNode` - represents a physical body. Must be a direct child of a :class:`physics.SpaceNode`. There are three different types of body nodes: static, kinematic and dynamic.
* :class:`HitboxNode` - represents an area of a BodyNode which can collide with other HitboxNodes. Must be a direct child of a :class:`physics.BodyNode`.

Read more about :doc:`the nodes concept in general </reference/nodes>`.

.. note::

    Physics system present in the kaa engine is a wrapper of an excellent 2D physics library - `Chipmunk <https://chipmunk-physics.net/documentation.php>`_.

:class:`SpaceNode` reference
----------------------------

.. class:: SpaceNode(a)

    TODO

:class:`BodyNode` reference
---------------------------

.. class:: BodyNode(a)

    TODO

:class:`HitboxNode` reference
-----------------------------

.. class:: HitboxNode(a)

    TODO


:class:`Arbiter` reference
--------------------------

.. class:: Arbiter

    TODO

:class:`CollisionPair` reference
--------------------------------

.. class:: CollisionPair

    TODO


:class:`BodyNodeType` reference
-------------------------------

.. class:: BodyNodeType

    TODO

:class:`CollisionPhase` reference
---------------------------------

.. class:: CollisionPhase

    TODO