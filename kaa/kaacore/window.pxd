from libcpp cimport bool
from libcpp.string cimport string
from libcpp.pair cimport pair
from libc.stdint cimport int32_t

from .vectors cimport CUVec2


cdef extern from "kaacore/window.h" nogil:
    cdef cppclass CWindow "kaacore::Window":
        void show()
        void hide()
        string title()
        void title(const string& title)
        bool fullscreen()
        void fullscreen(bool fullscreen)
        CUVec2 size()
        void size(const CUVec2& size)
        void maximize()
        void minimize()
        void restore()
        CUVec2 position()
        void position(const CUVec2& position)
        void center()
