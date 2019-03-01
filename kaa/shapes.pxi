from libcpp.vector cimport vector

from .kaacore.vectors cimport CVec2
from .kaacore.shapes cimport CShape, CShapeType


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


cdef class Segment(ShapeBase):
    def __init__(self, Vector a, Vector b):
        self._set_stack_c_shape()
        self.c_shape_ptr[0] = CShape.Segment(a.c_vector, b.c_vector)


cdef class Circle(ShapeBase):
    def __init__(self, Vector center, double radius):
        self._set_stack_c_shape()
        self.c_shape_ptr[0] = CShape.Circle(center.c_vector, radius)


cdef class Polygon(ShapeBase):
    def __init__(self, list points):
        assert all(isinstance(v, Vector) for v in points)
        cdef vector[CVec2] c_points
        c_points.resize(len(points))
        for v in points:
            c_points.push_back((<Vector>v).c_vector)
        raise NotImplementedError
        # self.c_shape_ptr[0] = CShape.Polygon(c_points)


cdef ShapeBase get_shape_wrapper(CShape* c_shape):
    cdef ShapeBase shape
    if c_shape.type == CShapeType.segment:
        shape = Segment.__new__(Segment)
        shape._set_ext_c_shape(c_shape)
    elif c_shape.type == CShapeType.circle:
        shape = Circle.__new__(Circle)
        shape._set_ext_c_shape(c_shape)
    elif c_shape.type == CShapeType.polygon:
        shape = Polygon.__new__(Polygon)
        shape._set_ext_c_shape(c_shape)
    else:
        raise NotImplementedError("Unhandled shape type")
    return shape
