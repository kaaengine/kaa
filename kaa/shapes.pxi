from libcpp.vector cimport vector

from .kaacore.vectors cimport CVector
from .kaacore.shapes cimport CShape, CShapeType
from .kaacore.hashing cimport c_calculate_hash


cdef class ShapeBase:
    cdef CShape _c_shape_stack
    cdef CShape* c_shape_ptr

    def __cinit__(self):
        self.c_shape_ptr = NULL

    cdef void _set_stack_c_shape(self):
        assert self.c_shape_ptr == NULL
        self.c_shape_ptr = &self._c_shape_stack

    cdef void _set_ext_c_shape(self, CShape* c_new_shape):
        assert self.c_shape_ptr == NULL
        self.c_shape_ptr = c_new_shape

    def transform(self, Transformation transformation not None):
        return get_shape_wrapper(
            self.c_shape_ptr[0].transform(transformation.c_transformation)
        )

    def __hash__(self):
        return c_calculate_hash[CShape](self.c_shape_ptr[0])

    def __richcmp__(self, ShapeBase other, op):
        if op == 2:
            return self.c_shape_ptr[0] == other.c_shape_ptr[0]
        elif op == 3:
            return not self.c_shape_ptr[0] == other.c_shape_ptr[0]
        else:
            return NotImplemented


cdef class Segment(ShapeBase):
    def __init__(self, Vector a, Vector b):
        self._set_stack_c_shape()
        self.c_shape_ptr[0] = CShape.Segment(a.c_vector, b.c_vector)

    @property
    def point_a(self):
        assert self.c_shape_ptr != NULL
        return Vector.from_c_vector(self.c_shape_ptr[0].points[0])

    @property
    def point_b(self):
        assert self.c_shape_ptr != NULL
        return Vector.from_c_vector(self.c_shape_ptr[0].points[1])


cdef class Circle(ShapeBase):
    def __init__(self, double radius, Vector center=Vector(0., 0.)):
        self._set_stack_c_shape()
        self.c_shape_ptr[0] = CShape.Circle(radius, center.c_vector)

    @property
    def radius(self):
        assert self.c_shape_ptr != NULL
        return self.c_shape_ptr[0].radius

    @property
    def center(self):
        assert self.c_shape_ptr != NULL
        return Vector.from_c_vector(self.c_shape_ptr[0].points[0])


cdef class Polygon(ShapeBase):
    def __init__(self, list points):
        assert all(isinstance(v, Vector) for v in points)
        cdef vector[CVector] c_points
        c_points.reserve(len(points))
        for v in points:
            c_points.push_back((<Vector>v).c_vector)
        self._set_stack_c_shape()
        self.c_shape_ptr[0] = CShape.Polygon(c_points)

    @staticmethod
    def from_box(Vector a):
        cdef Polygon polygon_box = Polygon.__new__(Polygon)
        polygon_box._set_stack_c_shape()
        polygon_box.c_shape_ptr[0] = CShape.Box(a.c_vector)
        return polygon_box

    @property
    def points(self):
        assert self.c_shape_ptr != NULL
        cdef CVector pt
        return [
            Vector.from_c_vector(pt)
            for pt in self.c_shape_ptr[0].points
        ]


cdef ShapeBase get_shape_wrapper(const CShape& c_shape):
    cdef ShapeBase shape
    if c_shape.type == CShapeType.segment:
        shape = Segment.__new__(Segment)
    elif c_shape.type == CShapeType.circle:
        shape = Circle.__new__(Circle)
    elif c_shape.type == CShapeType.polygon:
        shape = Polygon.__new__(Polygon)
    else:
        raise NotImplementedError("Unhandled shape type")
    shape._set_stack_c_shape()
    shape.c_shape_ptr[0] = c_shape
    return shape
