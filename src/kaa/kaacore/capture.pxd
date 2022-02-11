from libcpp.memory cimport shared_ptr
from libcpp.vector cimport vector
from libc.stdint cimport uint8_t, uint32_t

from .exceptions cimport raise_py_error


cdef extern from "kaacore/capture.h" namespace "kaacore" nogil:
    cdef cppclass CCapturedFrames "kaacore::CapturedFrames":
        uint32_t width
        uint32_t height

        vector[uint8_t*] raw_ptr_frames_uint8() except +raise_py_error
