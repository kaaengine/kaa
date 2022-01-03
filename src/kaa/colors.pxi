import cython

from .kaacore.vectors cimport CColor


@cython.final
cdef class Color:
    cdef CColor c_color

    def __cinit__(self, double r=0., double g=0., double b=0., double a=1.):
        assert 0. <= r <= 1.
        assert 0. <= g <= 1.
        assert 0. <= b <= 1.
        assert 0. <= a <= 1.
        self.c_color = CColor(r, g, b, a)

    @staticmethod
    cdef Color from_c_color(CColor c_color):
        cdef Color color = Color.__new__(Color)
        color.c_color = c_color
        return color

    @classmethod
    def from_int(cls, int r=0, int g=0, int b=0, int a=1):
        assert 0 <= r <= 255
        assert 0 <= g <= 255
        assert 0 <= b <= 255
        assert 0 <= a <= 255

        return cls(r / 255., g / 255., b / 255., a / 255.)

    @classmethod
    def from_hex(cls, object hex_color):
        if isinstance(hex_color, str):
            assert len(hex_color) == 8
            return cls.from_int(
                int(hex_color[0:2], base=16),
                int(hex_color[2:4], base=16),
                int(hex_color[4:6], base=16),
                int(hex_color[6:8], base=16),
            )
        if isinstance(hex_color, int):
            assert hex_color <= 0xffffffff
            return cls.from_int(
                (hex_color & 0xff << 24) >> 24,
                (hex_color & 0xff << 16) >> 16,
                (hex_color & 0xff << 8) >> 8,
                hex_color & 0xff
            )
        else:
            raise TypeError('Invalid type for hex_color.')

    def __str__(self):
        cls = self.__class__.__name__
        return f'{cls}[{self.r:.2f}, {self.g:.2f}, {self.b:.2f}, {self.a:.2f}]'

    def __repr__(self):
        return str(self)

    @property
    def r(self):
        return self.c_color.r

    @property
    def g(self):
        return self.c_color.g

    @property
    def b(self):
        return self.c_color.b

    @property
    def a(self):
        return self.c_color.a
