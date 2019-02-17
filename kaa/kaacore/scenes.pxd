from libc.stdint cimport uint32_t

from .nodes cimport CNode


cdef extern from "kaacore/scene.h" nogil:
    cdef cppclass CScene "Scene":
        CNode root_node
        uint32_t time

        void process_frame(uint32_t dt)
        void update(uint32_t dt)
        void process_nodes(uint32_t dt)
