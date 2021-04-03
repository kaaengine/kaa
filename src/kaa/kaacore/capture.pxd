from libcpp.memory cimport unique_ptr
from libcpp.vector cimport vector
from libc.stdint cimport uint8_t, uint32_t

from .exceptions cimport raise_py_error


cdef extern from "kaacore/capture.h" namespace "kaacore" nogil:
    cdef cppclass CCapturingAdapterBase "kaacore::CapturingAdapterBase":
        uint32_t width() except +raise_py_error
        uint32_t height() except +raise_py_error

    cdef cppclass CMemoryVectorCapturingAdapter "kaacore::MemoryVectorCapturingAdapter"(CCapturingAdapterBase):
        size_t frames_count() except +raise_py_error
        vector[uint8_t*] frames_uint8() except +raise_py_error
