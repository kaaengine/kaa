from libc.stdint cimport int16_t, uint16_t

from .nodes cimport CNode
from .camera cimport CCamera
from .vectors cimport CColor, CIVector, CUVector
from .exceptions cimport raise_py_error


cdef extern from "kaacore/views.h" nogil:
    cdef cppclass CView "kaacore::View":
        CCamera camera

        uint16_t index()
        int16_t z_index()
        CIVector origin()
        void origin(const CIVector& origin)
        CUVector dimensions()
        void dimensions(const CUVector& dimensions)
        CColor clear_color()
        void clear_color(const CColor& color)
        void reset_clear_color()

    cdef cppclass CViewsManager "kaacore::ViewsManager":
        CView& operator[](const int16_t z_index) except +raise_py_error
        CView* get(const int16_t z_index) except +raise_py_error

        size_t size()
