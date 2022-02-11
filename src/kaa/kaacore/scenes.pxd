from .nodes cimport CNode
from .clock cimport CDuration
from .camera cimport CCamera
from .spatial_index cimport CSpatialIndex
from .viewports cimport CViewportsManager
from .render_passes cimport CRenderPassesManager
from .exceptions cimport raise_py_error


cdef extern from "kaacore/scenes.h" namespace "kaacore" nogil:
    cdef cppclass CScene "kaacore::Scene":
        CNode root_node
        CSpatialIndex spatial_index
        CViewportsManager viewports
        CRenderPassesManager render_passes

        CCamera& camera()
        CDuration total_time() except +raise_py_error
        # for some reason in this case Cython
        # doesn't recognize overloaded functions,
        # maybe this has something to do with CScene being
        # subclassed from Cython?
        double get_time_scale "time_scale"() except +raise_py_error
        void set_time_scale "time_scale"(const double scale) \
            except +raise_py_error

        void on_attach()
        void on_enter()
        void update(CDuration dt)
        void on_exit()
        void on_detach()
