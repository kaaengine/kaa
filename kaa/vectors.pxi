import cython
from numbers import Number

from .kaacore.vectors cimport CVector


DEF VECTOR_FREELIST_SIZE = 32


@cython.final
@cython.freelist(VECTOR_FREELIST_SIZE)
cdef class Vector:
    cdef CVector c_vector

    def __cinit__(self, x=None, y=None):
        if x is None and y is None:
            x = y = 0
        elif x is None and y is not None:
            x = y
        elif x is not None and y is None:
            y = x

        assert isinstance(x, Number) and isinstance(y, Number), \
            'Unsupported type.'

        self.c_vector = CVector(x, y)

    @staticmethod
    cdef from_c_vector(CVector c_vector):
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
        return self.c_vector == CVector(0., 0.)

    def __repr__(self):
        return "V[{x}, {y}]".format(x=self.x, y=self.y)

    def __richcmp__(self, Vector other, op):
        if op == 2:
            return self.c_vector == other.c_vector
        elif op == 3:
            return not self.c_vector == other.c_vector
        else:
            raise NotImplementedError("Unsupported comparison")

    def mul(self, double operand):
        return Vector.from_c_vector(self.c_vector * operand)

    def __mul__(self, double operand):
        return self.mul(operand)

    def add(self, Vector vec):
        return Vector.from_c_vector(self.c_vector + vec.c_vector)

    def __add__(self, Vector vec):
        return self.add(vec)

    def sub(self, Vector vec):
        return Vector.from_c_vector(self.c_vector - vec.c_vector)

    def __sub__(self, Vector vec):
        return self.sub(vec)
