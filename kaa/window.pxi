cimport cython

from libcpp cimport bool
from libc.stdint cimport int32_t

from .kaacore.window cimport CWindow
from .kaacore.vectors cimport CVector, CIVector


@cython.final
cdef class Window:
    cdef CWindow* c_window

    @property
    def title(self):
        return self.c_window.title().decode()

    @title.setter
    def title(self, str title not None):
        self.c_window.title(title.encode())

    @property
    def fullscreen(self):
        return self.c_window.fullscreen()

    @fullscreen.setter
    def fullscreen(self, bool value):
        self.c_window.fullscreen(value)

    @property
    def size(self):
        cdef CIVector size = self.c_window.size()
        return Vector(size.x, size.y)

    @size.setter
    def size(self, Vector size not None):
        cdef CIVector c_size = CIVector(size.x, size.y)
        self.c_window.size(c_size)

    @property
    def position(self):
        cdef CIVector c_vector = self.c_window.position()
        return Vector(c_vector.x, c_vector.y)

    @position.setter
    def position(self, Vector vector not None):
        cdef CIVector c_vector = CIVector(vector.x, vector.y)
        self.c_window.position(c_vector)

    def show(self):
        self.c_window.show()

    def hide(self):
        self.c_window.hide()

    def maximize(self):
        self.c_window.maximize()

    def minimize(self):
        self.c_window.minimize()

    def restore(self):
        self.c_window.restore()

    def center(self):
        self.c_window.center()
