from libc.stdint cimport uint32_t

from .vectors cimport CVector
from .nodes cimport CNode
from .exceptions cimport raise_py_error


cdef extern from "kaacore/scenes.h" nogil:
    cdef cppclass CCamera "kaacore::Camera":
        CVector position
        double rotation
        CVector scale

        CVector unproject_position(const CVector& pos) except +raise_py_error

    cdef cppclass CScene "kaacore::Scene":
        CNode root_node
        uint32_t time
        CCamera camera

        void process_frame(uint32_t dt)
        void on_enter()
        void update(uint32_t dt)
        void on_exit()
        void process_nodes(uint32_t dt)
