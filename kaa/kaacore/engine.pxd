from libc.stdint cimport uint64_t
from libcpp.memory cimport unique_ptr

from .scenes cimport CScene
from .input cimport CInputManager


cdef extern from "kaacore/engine.h" nogil:
    cdef cppclass CEngine "Engine":
        unique_ptr[CInputManager] input_manager
        CScene running_scene
        uint64_t time

        void attach_scene(CScene* c_scene)
        void scene_run()

    CEngine* get_c_engine "get_engine"()
