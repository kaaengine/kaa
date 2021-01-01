from .nodes cimport CNode
from .clock cimport CDuration
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
        # for some reason in this case Cython
        # doesn't recognize overloaded functions,
        # maybe this has something to do CScene being
        # subclassed from Cython?
        double get_time_scale "time_scale"() except +raise_py_error
        void set_time_scale "time_scale"(const double scale) except +raise_py_error

        void on_attach()
        void on_enter()
        void update(CDuration dt)
        void on_exit()
        void on_detach()
