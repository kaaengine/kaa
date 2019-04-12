from libcpp cimport bool
from libcpp.string cimport string

from .vectors cimport CIVector


cdef extern from "kaacore/window.h" nogil:
    cdef cppclass CWindow "kaacore::Window":
        void show()
        void hide()
        void center()
        string title()
        void title(const string& title)
        bool fullscreen()
        void fullscreen(bool fullscreen)
        CIVector size()
        void size(const CIVector& size)
        CIVector position()
        void position(const CIVector& position)
