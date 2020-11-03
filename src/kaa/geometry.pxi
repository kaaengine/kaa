from enum import IntEnum

cimport cython

from libc.stdint cimport uint32_t
from libcpp.vector cimport vector

from .kaacore.math cimport radians, degrees
from .kaacore.vectors cimport CDVec2
from .kaacore.geometry cimport (
    CPolygonType, CAlignment, CTransformation, CDecomposedTransformation,
    CBoundingBox, c_classify_polygon
)
from .kaacore.hashing cimport c_calculate_hash


DEF TRANSFORMATION_FREELIST_SIZE = 32
DEF DECOMPOSED_TRANSFORMATION_FREELIST_SIZE = 32
DEF BOUNDING_BOX_FREELIST_SIZE = 32


class PolygonType(IntEnum):
    convex_cw = <uint32_t>CPolygonType.convex_cw
    convex_ccw = <uint32_t>CPolygonType.convex_ccw
    not_convex = <uint32_t>CPolygonType.not_convex


class Alignment(IntEnum):
    none = <uint32_t>CAlignment.none
    top = <uint32_t>CAlignment.top
    bottom = <uint32_t>CAlignment.bottom
    left = <uint32_t>CAlignment.left
    right = <uint32_t>CAlignment.right
    top_left = <uint32_t>CAlignment.top_left
    bottom_left = <uint32_t>CAlignment.bottom_left
    top_right = <uint32_t>CAlignment.top_right
    bottom_right = <uint32_t>CAlignment.bottom_right
    center = <uint32_t>CAlignment.center


@cython.freelist(TRANSFORMATION_FREELIST_SIZE)
cdef class Transformation:
    cdef CTransformation c_transformation

    def __init__(self, translate=None, rotate=None, rotate_degrees=None, scale=None):
        assert sum([translate is not None, rotate is not None,
                    rotate_degrees is not None, scale is not None]) <= 1, \
            "Only one of constructor arguments might be used."
        if translate is not None:
            assert isinstance(translate, Vector)
            self.c_transformation = CTransformation.translate(
                (<Vector>translate).c_vector
            )
        elif rotate is not None:
            self.c_transformation = CTransformation.rotate(
                <double>rotate
            )
        elif rotate_degrees is not None:
            self.c_transformation = CTransformation.rotate(
                radians(<double>rotate_degrees)
            )
        elif scale is not None:
            assert isinstance(scale, Vector)
            self.c_transformation = CTransformation.scale(
                (<Vector>scale).c_vector
            )

    def __repr__(self):
        return "<{}[{} {}, {} {}, {} {}]>".format(
            self.__class__.__name__,
            self.c_transformation.at(0, 0), self.c_transformation.at(0, 1),
            self.c_transformation.at(1, 0), self.c_transformation.at(1, 1),
            self.c_transformation.at(3, 0), self.c_transformation.at(3, 1),
        )

    def __eq__(self, Transformation other):
        return self.c_transformation == other.c_transformation

    def __or__(left, right):
        """
        Operator for joining transformations, which in fact is
        a "reversed" matrix multiplication,
        useful for a more user-friendly order of transformations.
        `tmn1 | tmn2 | tmn3` is equivalent to `tmn3 @ tmn2 @ tmn1`
        and `vec | tmn` is equivalent to `tmn @ vec`.

        Operator can also be used to transform a shape:
        `shape | tmn`, or `tmn @ shape`.
        """

        if not isinstance(right, Transformation):
            return NotImplemented
        return Transformation._combine(transformation=right,
                                       other=left)

    def __matmul__(left, right):
        if not isinstance(left, Transformation):
            return NotImplemented
        return Transformation._combine(transformation=left,
                                       other=right)

    @staticmethod
    cdef Transformation create(const CTransformation& c_transformation):
        cdef Transformation transformation = Transformation.__new__(Transformation)
        transformation.c_transformation = c_transformation
        return transformation

    @staticmethod
    def translate(Vector tr not None):
        return Transformation.create(CTransformation.translate(tr.c_vector))

    @staticmethod
    def scale(Vector sc not None):
        return Transformation.create(CTransformation.scale(sc.c_vector))

    @staticmethod
    def rotate(double r):
        return Transformation.create(CTransformation.rotate(r))

    @staticmethod
    def rotate_degrees(double r_deg):
        return Transformation.create(CTransformation.rotate(radians(r_deg)))

    def inverse(self):
        return Transformation.create(self.c_transformation.inverse())

    def decompose(self):
        return DecomposedTransformation.create(self.c_transformation.decompose())

    @staticmethod
    cdef object _combine(Transformation transformation, object other):
        if isinstance(other, Transformation):
            return Transformation.create(
                 transformation.c_transformation
                | (<Transformation>other).c_transformation
            )
        elif isinstance(other, Vector):
            return Vector.from_c_vector(
                (<Vector>other).c_vector
                | transformation.c_transformation
            )
        elif isinstance(other, ShapeBase):
            return (<ShapeBase>other).transform(transformation)
        return NotImplemented


@cython.freelist(DECOMPOSED_TRANSFORMATION_FREELIST_SIZE)
cdef class DecomposedTransformation:
    cdef CDecomposedTransformation c_decomposed_transformation

    def __init__(self):
        raise RuntimeError(f'{self.__class__} must not be instantiated manually!')

    @staticmethod
    cdef create(const CDecomposedTransformation& c_decomposed_transformation):
        cdef DecomposedTransformation py_inst = \
                DecomposedTransformation.__new__(DecomposedTransformation)
        py_inst.c_decomposed_transformation = c_decomposed_transformation
        return py_inst

    def __repr__(self):
        return "<{} translation={!r}, rotation={!r}, scale={!r}]>".format(
            self.__class__.__name__,
            self.translation, self.rotation, self.scale,
        )

    @property
    def translation(self):
        return Vector.from_c_vector(
            self.c_decomposed_transformation.translation
        )

    @property
    def rotation(self):
        return self.c_decomposed_transformation.rotation

    @property
    def rotation_degrees(self):
        return degrees(self.c_decomposed_transformation.rotation)

    @property
    def scale(self):
        return Vector.from_c_vector(
            self.c_decomposed_transformation.scale
        )


def classify_polygon(points):
    cdef vector[CDVec2] c_points
    c_points.reserve(len(points))
    for pt in points:
        c_points.push_back((<Vector>pt).c_vector)
    return PolygonType(<uint32_t>c_classify_polygon(c_points))


@cython.freelist(BOUNDING_BOX_FREELIST_SIZE)
cdef class BoundingBox:
    cdef CBoundingBox c_bounding_box

    def __init__(self, double min_x, double min_y, double max_x, double max_y):
        self.c_bounding_box = CBoundingBox(min_x, min_y, max_x, max_y)

    @staticmethod
    cdef BoundingBox create(const CBoundingBox& c_bounding_box):
        cdef BoundingBox bounding_box = BoundingBox.__new__(BoundingBox)
        bounding_box.c_bounding_box = c_bounding_box
        return bounding_box

    def __repr__(self):
        return (
            "BoundingBox(min_x={min_x}, min_y={min_y}, "
            "max_x={max_x}, max_y={max_y})"
        ).format(
            min_x=self.min_x, min_y=self.min_y,
            max_x=self.max_x, max_y=self.max_y,
        )

    def __eq__(self, BoundingBox other):
        return self.c_bounding_box == other.c_bounding_box

    def __hash__(self):
        return c_calculate_hash[CBoundingBox](self.c_bounding_box)

    @staticmethod
    def single_point(Vector point not None):
        return BoundingBox.create(
            CBoundingBox.single_point(point.c_vector)
        )

    @staticmethod
    def from_points(list points):
        cdef vector[CDVec2] c_points
        c_points.reserve(len(points))
        for v in points:
            c_points.push_back((<Vector>v).c_vector)
        return BoundingBox.create(
            CBoundingBox.from_points(c_points)
        )

    @property
    def min_x(self):
        return self.c_bounding_box.min_x

    @property
    def max_x(self):
        return self.c_bounding_box.max_x

    @property
    def min_y(self):
        return self.c_bounding_box.min_y

    @property
    def max_y(self):
        return self.c_bounding_box.max_y

    @property
    def is_nan(self):
        return <bool>(self.c_bounding_box.is_nan())

    def merge(self, BoundingBox bounding_box not None):
        return BoundingBox.create(
            self.c_bounding_box.merge(bounding_box.c_bounding_box)
        )

    def contains(self, Vector point not None):
        return self.c_bounding_box.contains(point.c_vector)

    def contains(self, BoundingBox bounding_box not None):
        return self.c_bounding_box.contains(bounding_box.c_bounding_box)

    def intersects(self, BoundingBox bounding_box not None):
        return self.c_bounding_box.intersects(bounding_box.c_bounding_box)

    def grow(self, Vector vector not None):
        return BoundingBox.create(
            self.c_bounding_box.grow(vector.c_vector)
        )

    @property
    def center(self):
        return Vector.from_c_vector(
            self.c_bounding_box.center()
        )

    @property
    def dimensions(self):
        return Vector.from_c_vector(
            self.c_bounding_box.dimensions()
        )
