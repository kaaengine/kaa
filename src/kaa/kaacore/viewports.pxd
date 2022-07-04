from libc.stdint cimport int16_t, uint16_t

from .camera cimport CCamera
from .vectors cimport CIVec2, CUVec2
from .exceptions cimport raise_py_error


cdef extern from "kaacore/viewports.h" namespace "kaacore" nogil:
    int16_t default_viewport_z_index
    int16_t min_viewport_z_index
    int16_t max_viewport_z_index

    cdef cppclass CViewport "kaacore::Viewport":
        CCamera camera

        int16_t z_index() except +raise_py_error
        CIVec2 origin() except +raise_py_error
        void origin(const CIVec2& origin) except +raise_py_error
        CUVec2 dimensions() except +raise_py_error
        void dimensions(const CUVec2& dimensions) except +raise_py_error

    cdef cppclass CViewportsManager "kaacore::ViewportsManager":
        CViewport& operator[](const int16_t z_index) except +raise_py_error
        CViewport* get(const int16_t z_index) except +raise_py_error
        size_t size() except +raise_py_error
