from .vectors cimport CColor


cdef extern from "kaacore/renderer.h" nogil:
    cdef cppclass CRenderer "kaacore::Renderer":
        void clear_color(CColor color)
        CColor clear_color()
