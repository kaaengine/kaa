from libcpp.string cimport string
from libc.stdint cimport uint64_t

from .vectors cimport CDVec2
from .exceptions cimport raise_py_error
from .resources cimport CResourceReference


cdef extern from "kaacore/textures.h" namespace "kaacore" nogil:

    cdef cppclass CTexture "kaacore::Texture":
        CDVec2 get_dimensions() except +raise_py_error

    cdef cppclass CMemoryTexture "kaacore::MemoryTexture"(CTexture):
        pass

    cdef cppclass CImageTexture "kaacore::ImageTexture"(CMemoryTexture):
        CImageTexture()

        @staticmethod
        CResourceReference[CImageTexture] load(const string& path) \
            except +raise_py_error
