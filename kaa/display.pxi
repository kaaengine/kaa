from .kaacore.display cimport CDisplay


cdef class Display:
    cdef CDisplay c_display
