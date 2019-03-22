from libc.stdint cimport uint64_t
from libcpp.memory cimport unique_ptr

from .scenes cimport CScene
from .input cimport CInputManager


cdef extern from "kaacore/engine.h" nogil:
    cdef cppclass CEngine "kaacore::Engine":
        unique_ptr[CInputManager] input_manager
        CScene running_scene
        uint64_t time

        void run(CScene* c_scene)
        void quit()

    CEngine* get_c_engine "kaacore::get_engine"()
