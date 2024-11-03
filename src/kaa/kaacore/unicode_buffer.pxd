from libc.stdint cimport uint8_t
from libcpp.string cimport string
from libcpp cimport bool

from .exceptions cimport raise_py_error


cdef extern from "kaacore/unicode_buffer.h" namespace "kaacore" nogil:
    cdef enum CUnicodeRepresentationSize "kaacore::UnicodeRepresentationSize":
        ucs1 "kaacore::UnicodeRepresentationSize::ucs1",
        ucs2 "kaacore::UnicodeRepresentationSize::ucs2",
        ucs4 "kaacore::UnicodeRepresentationSize::ucs4",

    cdef cppclass CUnicodeView "kaacore::UnicodeView":
        CUnicodeView()
        CUnicodeView(uint8_t* data, size_t length, CUnicodeRepresentationSize representation_size)
        CUnicodeRepresentationSize representation_size() const
        size_t length() const
        uint8_t* data() const
