cimport cython

from libcpp cimport bool
from libcpp.string cimport string
from libc.stdint cimport int32_t

from .kaacore.engine cimport get_c_engine
from .kaacore.window cimport CWindow
from .kaacore.vectors cimport CDVec2, CUVec2


@cython.final
cdef class _Window:
    cdef CWindow* get_c_window(self) except NULL:
        return get_c_engine().window.get()

    def show(self):
        self.get_c_window().show()

    def hide(self):
        self.get_c_window().hide()

    @property
    def title(self):
        return (<bytes>self.get_c_window().title()).decode()

    @title.setter
    def title(self, str new_title):
        self.get_c_window().title(<string>new_title.encode())

    @property
    def fullscreen(self):
        return self.get_c_window().fullscreen()

    @fullscreen.setter
    def fullscreen(self, bool fullscreen_state):
        self.get_c_window().fullscreen(fullscreen_state)

    @property
    def size(self):
        cdef CUVec2 vec = self.get_c_window().size()
        return Vector(vec.x, vec.y)

    @size.setter
    def size(self, Vector new_size):
        cdef CUVec2 vec = CUVec2(new_size.x, new_size.y)
        self.get_c_window().size(vec)

    def maximize(self):
        self.get_c_window().maximize()

    def minimize(self):
        self.get_c_window().minimize()

    def restore(self):
        self.get_c_window().restore()

    @property
    def position(self):
        cdef CUVec2 vec = self.get_c_window().position()
        return Vector(vec.x, vec.y)

    @position.setter
    def position(self, Vector new_position):
        cdef CUVec2 vec = CUVec2(new_position.x, new_position.y)
        self.get_c_window().position(vec)

    def center(self):
        self.get_c_window().center()
