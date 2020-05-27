from libc.stdint cimport uint32_t

from .nodes cimport CNode
from .camera cimport CCamera
from .views cimport CViewsManager
from .exceptions cimport raise_py_error


cdef extern from "kaacore/scenes.h" nogil:
    cdef cppclass CScene "kaacore::Scene":
        CNode root_node
        CViewsManager views

        CCamera& camera()
        void process_frame(double dt)
        void on_attach()
        void on_enter()
        void update(double dt)
        void on_exit()
        void on_detach()
        void process_nodes(double dt)
