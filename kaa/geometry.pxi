from enum import IntEnum

cimport cython

from libc.stdint cimport uint32_t
from libcpp.vector cimport vector

from .kaacore.math cimport radians
from .kaacore.vectors cimport CDVec2
from .kaacore.geometry cimport (
    CPolygonType, CAlignment, CTransformation, c_classify_polygon
)


DEF TRANSFORMATION_FREELIST_SIZE = 32


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

    def __repr__(self):
        return "<{}[{} {}, {} {}, {} {}]>".format(
            self.__class__.__name__,
            self.c_transformation.at(0, 0), self.c_transformation.at(0, 1),
            self.c_transformation.at(1, 0), self.c_transformation.at(1, 1),
            self.c_transformation.at(3, 0), self.c_transformation.at(3, 1),
        )

    @staticmethod
    def rotate_degrees(double r_deg):
        return Transformation.create(CTransformation.rotate(radians(r_deg)))

    def inverse(self):
        return Transformation.create(self.c_transformation.inverse())

    cpdef Transformation _combine_with_transformation(self, Transformation operand):
        return Transformation.create(
             operand.c_transformation | self.c_transformation
        )

    cpdef Vector _combine_with_vector(self, Vector operand):
        return Vector.from_c_vector(
            operand.c_vector | self.c_transformation
        )

    def __or__(left, right):
        """
        Operator for joining transformations, which in fact is
        a "reversed" matrix multiplication,
        useful for a more user-friendly order of transformations.
        `tmn1 | tmn2 | tmn3` is equivalent to `tmn3 @ tmn2 @ tmn1`
        and `vec | tmn` is equivalent to `tmn @ vec`.
        """

        if isinstance(right, Transformation):
            if isinstance(left, Transformation):
                return right._combine_with_transformation(left)
            elif isinstance(left, Vector):
                return right._combine_with_vector(left)
        return NotImplemented


def classify_polygon(points):
    cdef vector[CDVec2] c_points
    c_points.reserve(len(points))
    for pt in points:
        c_points.push_back((<Vector>pt).c_vector)
    return PolygonType(<uint32_t>c_classify_polygon(c_points))
