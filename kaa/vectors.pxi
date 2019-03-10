import cython
from numbers import Number

from .kaacore.vectors cimport CVec2


DEF VECTOR_FREELIST_SIZE = 32


@cython.final
@cython.freelist(VECTOR_FREELIST_SIZE)
cdef class Vector:
    cdef CVec2 c_vector

    def __cinit__(self, x=None, y=None):
        if x is None and y is None:
            x = y = 0
        elif x is None and y is not None:
            x = y
        elif x is not None and y is None:
            y = x

        assert isinstance(x, Number) and isinstance(y, Number), \
            'Unsupported type.'

        self.c_vector = CVec2(x, y)

    @staticmethod
    cdef from_c_vector(CVec2 c_vector):
        cdef Vector vector = Vector.__new__(Vector)
        vector.c_vector = c_vector
        return vector

    @property
    def x(self):
        return self.c_vector.x

    @property
    def y(self):
        return self.c_vector.y

    def __bool__(self):
        return not self.is_zero()

    def is_zero(self):
        return self.c_vector == CVec2(0., 0.)

    def __repr__(self):
        return "V[{x}, {y}]".format(x=self.x, y=self.y)

    def __richcmp__(self, Vector other, op):
        if op == 2:
            return self.c_vector == other.c_vector
        elif op == 3:
            return not self.c_vector == other.c_vector
        else:
            raise NotImplementedError("Unsupported comparison")
