:mod:`geometry` --- wrapper classes for vectors, segments, polygons etc.
========================================================================
.. module:: geometry
    :synopsis: Wrapper classes for vectors, segments, polygons etc.

:class:`Vector` reference
-------------------------

Constructor:

.. class:: Vector(x, y)

	Vector instance represents an Euclidean vector. It stores a pair od 2D corrdinates (x, y). Vectors
	are immutable. Vectors are used for the following purposes:

    * storing an actual vector pointing from (0, 0) to (x, y), for example :class:`nodes.BodyNode.velocity`
    * storing a 2D point, for example :class:`nodes.Node.position`
    * storing a width/height of a rectangular shape, such as a screen resolution. For example :class:`engine.Engine.virtual_resolution`

    Vector constructor accepts two float numbers: x and y.


Available operators:

* Adding two vectors: :code:`Vector(1,1) + Vector(2,2)`
* Substracting two vectors: :code:`Vector(1,1) - Vector(2,2)`
* Multiplying vector by a scalar: :code:`Vector(1,1) * 123`
* Dividing vector by a scalar: :code:`Vector(1,1) / 123`

Class methods:

.. classmethod:: Vector.from_angle(angle)

    Creates a new unit Vector (i.e. length 1 vector) from angle, in radians.

    .. code-block:: python

        import math
        from kaa.geometry import Vector

        v = Vector.from_angle(math.pi / 4)
        print(v)  # V[0.7071067811865476, 0.7071067811865475]
        print(v.length())  # 1.0

.. classmethod:: Vector.from_angle_degrees(degrees)

    Creates a new unit Vector (i.e. length 1 vector) from angle, in degrees.

    .. code-block:: python

        import math
        from kaa.geometry import Vector

        v = Vector.from_angle_degrees(90) # 90 degrees is pointing up, 180, pointing left, 270 pointing down etc.
        print(v)  # V[0.0, 1.0]
        print(v.length())  # 1.0


Instance Properties (read only):

.. attribute:: Vector.x

    Gets the x value of a vector

.. attribute:: Vector.y

    Gets the y value of a vector

Instance Methods:

.. method:: Vector.is_zero()

    Returns :code:`True` if vector is a zero vector

    .. code-block:: python

        from kaa.geometry import Vector

        Vector(0, 0).is_zero()  # True
        Vector(0.1, 0).is_zero()  # False

.. method:: Vector.rotate_angle(angle)

    Returns a new vector, rotated by given angle, in radians.

    .. code-block:: python

        from kaa.geometry import Vector
        import math

        print(Vector(10, 0))  # V[10, 0]
        print(Vector(10, 0).rotate_angle(math.pi))  # V[-10, 0]


.. method:: Vector.rotate_angle_degrees(degrees)

    Returns a new vector, rotated by given angle, in degrees.

    .. code-block:: python

        from kaa.geometry import Vector
        import math

        print(Vector(10, 0))  # V[10, 0]
        print(Vector(10, 0).rotate_angle_degrees(180))  # V[-10, 0]


.. method:: Vector.to_angle()

    Returns vector's angle, in radians.

.. method:: Vector.to_angle_degrees()

    Returns vector's angle, in degrees.

.. method:: Vector.dot(other_vector)

    Returns dot product of two vectors. other_vector parameter must be :class:`geometry.Vector`

.. method:: Vector.distance(other_vector)

    Returns a distance from (x,y) to (other_vector.x, other_vector.y), in other words: distance between two points.
    other_vector parameter must be :class:`geometry.Vector`

.. method:: Vector.normalize()

    Returns a new vector, normalized (i.e. unit vector)

.. method:: Vector.length()

    Returns vector's length.

:class:`Segment` reference
--------------------------

Constructor:

.. class:: Segment(vector_a, vector_b)

    Segment instance represents a segment between two points, a and b.

    vector_a and vector_b params are :class:`geometry.Vector` instances indicating both ends of a Segment


TODO: no properties?

:class:`Circle` reference
-------------------------

Constructor:

.. class:: Circle(radius, center=Vector(0, 0))

    Circle instance represents a circualar shape, with a center and a radius. Circles are used e.g. for creating hitboxes.

    center parameter must be :class:`geometry.Vector`, radius is a number.

TODO: no properties?

:class:`Polygon` reference
--------------------------

Constructor:

.. class:: Polygon(points)

    Polygon instance represents a custom shape. Polygons are used e.g. for creating hitboxes.

    points parameter must be a list of :class:`geometry.Vector` instances.

    If you don't close the polygon (the last point in the list is not identical with the first one) kaa will do
    that for you.

    The polygon `must be convex <https://en.wikipedia.org/wiki/Convex_polygon>`_. Kaa engine will throw an exception
    if you try to create a non-convex polygon. You may use :meth:`classify_polygon` function to check if a list of
    points will form a convex polygon or not.

    .. code-block:: python

        from kaa.geometry import Polygon

        polygon = Polygon([Vector(-10, -10), Vector(10, 30), Vector(0, 40)])  # a triangular-shaped polygon

Class methods:

.. classmethod:: Polygon.from_box(vector)

    Creates a rectangular-shaped Polygon whose central point is at (0, 0) and width and height are passed as vector.x
    and vector.y respectively. A useful shorthand function for creating a rectangular shape for a
    :class:`physics.HitboxNode`.

    .. code-block:: python

        from kaa.geometry import Polygon, Vector

        poly = Polygon.from_box(Vector(10, 8)) # creates a rectangular polygon [ V(-5, -4), V(5, -4), V(5, 4), V(-5, 4) ]

TODO: no properties?


:class:`Alignment` reference
----------------------------

.. class:: Alignment

Enum type used to set Node's origin alignment to one of the 9 positions. See :class:`nodes.Node.origin_alignment`

Available values are:

* :code:`Alignment.none`
* :code:`Alignment.top`
* :code:`Alignment.bottom`
* :code:`Alignment.left`
* :code:`Alignment.right`
* :code:`Alignment.top_left`
* :code:`Alignment.bottom_left`
* :code:`Alignment.top_right`
* :code:`Alignment.bottom_right`
* :code:`Alignment.center`

:class:`PolygonType` reference
------------------------------

.. class:: PolygonType

Enum type returned by the :meth:`classify_polygon()` function. Available values:

* :code:`PolygonType.convex_cw` - the list of points forms a convex polygon, the points are ordered clockwise
* :code:`PolygonType.convex_ccw` - the list of points forms a convex polygon, the points are ordered counter clockwise
* :code:`PolygonType.not_convex` - the list of points forms a non-convex polygon

:meth:`classify_polygon` reference
----------------------------------

.. method:: classify_polygon(polygon)

Accepts a list of points (list of :class:`geometry.Vector`) and returns if polygon formed by those points is convex or
not. The function returns a :class:`PolygonType` enum value.

.. code-block:: python

    from kaa.geometry import Vector, classify_polygon

    print(classify_polygon([Vector(0, 0), Vector(10, 0), Vector(10, 10), Vector(0, 10)]))  # PolygonType.conwex_ccw
    print(classify_polygon([Vector(0, 0), Vector(0, 10), Vector(10, 10), Vector(10, 0)]))  # PolygonType.conwex_cw
    print(classify_polygon([Vector(0, 0), Vector(10, 0), Vector(2, 2), Vector(0, 10)]))  # PolygonType.not_convex
