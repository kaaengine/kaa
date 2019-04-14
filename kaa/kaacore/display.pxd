from libc.stdint cimport int32_t, uint32_t
from libcpp.string cimport string

from .vectors cimport CIVector


cdef extern from "kaacore/display.h" nogil:
    ctypedef struct CDisplay "kaacore::Display":
        uint32_t index
        string name
        CIVector position
        CIVector size
