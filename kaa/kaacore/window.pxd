from libcpp cimport bool
from libcpp.pair cimport pair
from libc.stdint cimport int32_t

from .vectors cimport CVector


cdef extern from "kaacore/window.h" nogil:
    cdef cppclass CWindow "kaacore::Window":
        bool fullscreen()
        void fullscreen(const bool fullscreen)
        pair[int32_t, int32_t] size()
        void size(pair[int32_t, int32_t] window_size)
        CVector position()
        void position(CVector vec)
