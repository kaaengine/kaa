import cython
from numbers import Number

from .kaacore.vectors cimport (
    CVector, CVector_dot, CVector_distance, CVector_length, CVector_normalize,
    CVector_rotate_angle, CVector_oriented_angle
)
from .kaacore.math cimport radians, degrees


DEF VECTOR_FREELIST_SIZE = 32


@cython.final
@cython.freelist(VECTOR_FREELIST_SIZE)
cdef class Vector:
    cdef CVector c_vector

    def __cinit__(self, x not None, y not None):
        assert isinstance(x, Number) and isinstance(y, Number), \
            'Unsupported type.'

        self.c_vector = CVector(x, y)

    @staticmethod
    cdef Vector from_c_vector(CVector c_vector):
        return Vector.__new__(Vector, c_vector.x, c_vector.y)

    @staticmethod
    def xy(n not None):
        assert isinstance(n, Number), 'Unsupported type.'
        return Vector.__new__(Vector, n, n)

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

    def __truediv__(self, double operand):
        return self.mul(1. / operand)

    def add(self, Vector vec):
        return Vector.from_c_vector(self.c_vector + vec.c_vector)

    def __add__(self, Vector vec):
        return self.add(vec)

    def sub(self, Vector vec):
        return Vector.from_c_vector(self.c_vector - vec.c_vector)

    def __sub__(self, Vector vec):
        return self.sub(vec)

    def __neg__(self):
        return Vector(-self.x, -self.y)

    def rotate_angle(self, double angle_rad):
        return Vector.from_c_vector(CVector_rotate_angle(self.c_vector, angle_rad))

    def rotate_angle_degrees(self, double angle_deg):
        return self.rotate_angle(radians(angle_deg))

    @classmethod
    def from_angle(cls, double angle_rad):
        return Vector.from_c_vector(CVector_rotate_angle(CVector(1., 0.), angle_rad))

    @classmethod
    def from_angle_degrees(cls, double angle_deg):
        return cls.from_angle(radians(angle_deg))

    def to_angle(self):
        return CVector_oriented_angle(
            CVector(1., 0.), CVector_normalize(self.c_vector)
        )

    def to_angle_degrees(self):
        return degrees(self.to_angle())

    def dot(self, Vector other_vec):
        return CVector_dot(self.c_vector, other_vec.c_vector)

    def distance(self, Vector other_vec):
        return CVector_distance(self.c_vector, other_vec.c_vector)

    def normalize(self):
        return Vector.from_c_vector(
            CVector_normalize(self.c_vector)
        )

    def length(self):
        return CVector_length(self.c_vector)
