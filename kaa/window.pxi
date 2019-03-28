cimport cython

from libcpp cimport bool
from libcpp.pair cimport pair
from libc.stdint cimport int32_t

from .kaacore.window cimport CWindow
from .kaacore.vectors cimport CVector


@cython.final
cdef class Window:
    cdef CWindow* c_window

    @staticmethod
    cdef create(CWindow* c_window):
        cdef Window instance = Window.__new__(Window)
        instance.c_window = c_window
        return instance

    @property
    def fullscreen(self):
        return self.c_window.fullscreen()

    @fullscreen.setter
    def fullscreen(self, bool value):
        self.c_window.fullscreen(value)

    @property
    def size(self):
        cdef pair[int32_t, int32_t] size = self.c_window.size()
        return size.first, size.second

    @size.setter
    def size(self, tuple size not None):
        cdef pair[int32_t, int32_t] c_size = size
        self.c_window.size(c_size)

    @property
    def position(self):
        cdef CVector c_vector = self.c_window.position()
        return Vector(c_vector.x, c_vector.y)

    @position.setter
    def position(self, Vector vector):
        cdef CVector c_vector

        if vector is None:
            c_vector = CVector(WINDOWPOS_CENTERED, WINDOWPOS_CENTERED)
        else:
            c_vector = CVector(vector.x, vector.y)

        self.c_window.position(c_vector)
