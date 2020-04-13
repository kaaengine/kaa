from libc.stdint cimport uint32_t
from libcpp.string cimport string

from .vectors cimport CUVector


cdef extern from "kaacore/display.h" nogil:
    cdef cppclass CDisplay "kaacore::Display":
        uint32_t index
        string name
        CUVector position
        CUVector size
