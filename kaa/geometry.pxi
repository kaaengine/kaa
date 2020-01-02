from enum import IntEnum

from libc.stdint cimport uint32_t
from libcpp.vector cimport vector

from .kaacore.math cimport radians
from .kaacore.vectors cimport CVector, CMat3x2
from .kaacore.geometry cimport (
    CPolygonType, CAlignment, CTransformation, c_classify_polygon
)


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
        cdef CMat3x2 mat_summary = self.c_transformation.matrix_abcd_txy()
        return "<{}[{} {}, {} {}, {} {}]>".format(
            self.__class__.__name__,
            mat_summary[0][0], mat_summary[0][1],
            mat_summary[1][0], mat_summary[1][1],
            mat_summary[2][0], mat_summary[2][1],
        )

    @staticmethod
    def rotate_degrees(double r_deg):
        return Transformation.create(CTransformation.rotate(radians(r_deg)))

    def inverse(self):
        return Transformation.create(self.c_transformation.inverse())

    cpdef Transformation _mul_transformation(self, Transformation operand):
        return Transformation.create(
            self.c_transformation * operand.c_transformation
        )

    cpdef Vector _mul_vector(self, Vector operand):
        return Vector.from_c_vector(
            self.c_transformation * operand.c_vector
        )

    def __or__(left, right):
        """
        Helper operator for "reversed" matrix multiplication,
        useful for a more user-friendly order of transformations.
        `tmn1 | tmn2 | tmn3` is equivalent to `tmn3 @ tmn2 @ tmn1`
        and `vec | tmn` is equivalent to `tmn @ vec`.
        """

        if isinstance(right, Transformation):
            if isinstance(left, Transformation):
                return right._mul_transformation(left)
            elif isinstance(left, Vector):
                return right._mul_vector(left)
        return NotImplemented

    def __matmul__(left, right):
        if isinstance(left, Transformation):
            if isinstance(right, Transformation):
                return left._mul_transformation(right)
            elif isinstance(right, Vector):
                return left._mul_vector(right)
        return NotImplemented


def classify_polygon(points):
    cdef vector[CVector] c_points
    c_points.reserve(len(points))
    for pt in points:
        c_points.push_back((<Vector>pt).c_vector)
    return PolygonType(<uint32_t>c_classify_polygon(c_points))
