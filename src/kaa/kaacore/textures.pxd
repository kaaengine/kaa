from libcpp.string cimport string
from libc.stdint cimport uint64_t

from .vectors cimport CDVec2
from .exceptions cimport raise_py_error
from .resources cimport CResourceReference


cdef extern from "kaacore/textures.h" namespace "kaacore" nogil:

    cdef cppclass CTexture "kaacore::Texture":
        CTexture()
        @staticmethod
        CResourceReference[CTexture] load(const string& path, uint64_t flags) \
            except +raise_py_error


        CDVec2 get_dimensions() except +raise_py_error
