from enum import IntEnum

cimport cython

from libc.stdint cimport uint32_t
from libcpp.vector cimport vector

from .kaacore.math cimport radians, degrees
from .kaacore.vectors cimport CDVec2
from .kaacore.geometry cimport (
    CPolygonType, CAlignment, CTransformation, CDecomposedTransformation,
    c_classify_polygon
)


DEF TRANSFORMATION_FREELIST_SIZE = 32
DEF DECOMPOSED_TRANSFORMATION_FREELIST_SIZE = 32


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

    def decompose(self):
        return DecomposedTransformation.create(self.c_transformation.decompose())

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
    def rotation(self):
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
