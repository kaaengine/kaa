from libcpp.string cimport string
from libc.stdint cimport uint64_t

from .vectors cimport CDVec2
from .exceptions cimport raise_py_error
from .resources cimport CResourceReference


cdef extern from "kaacore/images.h" namespace "kaacore" nogil:

    cdef cppclass CImage "kaacore::Image":
        CImage()
        @staticmethod
        CResourceReference[CImage] load(const string& path, uint64_t flags) \
            except +raise_py_error


        CDVec2 get_dimensions() except +raise_py_error
