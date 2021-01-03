from libc.stdint cimport int16_t, uint16_t

from .nodes cimport CNode
from .camera cimport CCamera
from .vectors cimport CColor, CIVec2, CUVec2
from .exceptions cimport raise_py_error


cdef extern from "kaacore/views.h" namespace "kaacore" nogil:
    int16_t views_default_z_index

    cdef cppclass CView "kaacore::View":
        CCamera camera

        int16_t z_index()
        CIVec2 origin()
        void origin(const CIVec2& origin)
        CUVec2 dimensions()
        void dimensions(const CUVec2& dimensions)
        CColor clear_color()
        void clear_color(const CColor& color)
        void reset_clear_color()

    cdef cppclass CViewsManager "kaacore::ViewsManager":
        CView& operator[](const int16_t z_index) except +raise_py_error
        CView* get(const int16_t z_index) except +raise_py_error

        size_t size()
