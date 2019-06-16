from libcpp.string cimport string
from libcpp.memory cimport unique_ptr
from libcpp.vector cimport vector
from libc.stdint cimport int32_t, uint64_t

from .display cimport CDisplay
from .scenes cimport CScene
from .window cimport CWindow
from .input cimport CInputManager


cdef extern from "kaacore/engine.h" nogil:
    cdef cppclass CEngine "kaacore::Engine":
        unique_ptr[CWindow] window
        unique_ptr[CInputManager] input_manager
        CScene* scene
        uint64_t time

        vector[CDisplay] get_displays()
        void run(CScene* c_scene)
        void set_scene(CScene* c_scene)
        void quit()

    CEngine* c_engine "kaacore::engine"

cdef inline CEngine* get_c_engine():
    return c_engine

cdef inline unique_ptr[CEngine] create_c_engine():
    assert get_c_engine() == NULL
    cdef CEngine* c_engine = new CEngine()
    return unique_ptr[CEngine](c_engine)
