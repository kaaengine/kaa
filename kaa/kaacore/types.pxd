from libc.stdint cimport int32_t

cdef extern from "kaacore/types.h" nogil:
    ctypedef struct CRectangle "kaacore::CRectangle":
        int32_t x
        int32_t y
        int32_t w
        int32_t h
