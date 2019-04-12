from libc.stdint cimport int32_t, uint32_t
from libcpp.string cimport string

cdef extern from "kaacore/display.h" nogil:
    ctypedef struct CDisplay "kaacore::Display":
        uint32_t index
        string name
        int32_t x
        int32_t y
        int32_t width
        int32_t height
