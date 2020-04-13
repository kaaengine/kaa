from libcpp.string cimport string

from .vectors cimport CUVector
from .exceptions cimport raise_py_error


cdef extern from "kaacore/window.h" nogil:
    cdef cppclass CWindow "kaacore::Window":
        void show() except +raise_py_error
        void hide() except +raise_py_error
        string title() except +raise_py_error
        void title(const string& title) except +raise_py_error
        bint fullscreen() except +raise_py_error
        void fullscreen(bint fullscreen) except +raise_py_error
        CUVector size() except +raise_py_error
        void size(const CUVector& size) except +raise_py_error
        void maximize() except +raise_py_error
        void minimize() except +raise_py_error
        void restore() except +raise_py_error
        CUVector position() except +raise_py_error
        void position(const CUVector& position) except +raise_py_error
        void center() except +raise_py_error
