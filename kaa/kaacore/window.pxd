from libcpp cimport bool
from libcpp.string cimport string

from .vectors cimport CIVector


cdef extern from "kaacore/window.h" nogil:
    cdef cppclass CWindow "kaacore::Window":
        void show()
        void hide()
        string title()
        void title(const string& title)
        bool fullscreen()
        void fullscreen(bool fullscreen)
        CIVector size()
        void size(const CIVector& size)
        void maximize()
        void minimize()
        void restore()
        CIVector position()
        void position(const CIVector& position)
        void center()
