from libcpp.vector cimport vector

from .vectors cimport CColor
from .textures cimport CTexture
from .exceptions cimport raise_py_error
from .resources cimport CResourceReference


cdef extern from "kaacore/render_targets.h" namespace "kaacore" nogil:
    cdef cppclass CRenderTarget "kaacore::RenderTarget"(CTexture):
        @staticmethod
        CResourceReference[CRenderTarget] create() \
            except +raise_py_error
