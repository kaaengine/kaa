from .nodes cimport CNode
from .clock cimport CSeconds
from .camera cimport CCamera
from .views cimport CViewsManager
from .spatial_index cimport CSpatialIndex
from .exceptions cimport raise_py_error


cdef extern from "kaacore/scenes.h" nogil:
    cdef cppclass CScene "kaacore::Scene":
        CNode root_node
        CViewsManager views
        CSpatialIndex spatial_index

        CCamera& camera()
        void on_attach()
        void on_enter()
        void update(CSeconds dt)
        void on_exit()
        void on_detach()
