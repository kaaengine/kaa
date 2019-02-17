from libc.stdint cimport uint64_t

from ..kaacore.scenes cimport CScene


cdef extern from "kaacore/engine.h" nogil:
    cdef cppclass CEngine "Engine":
        CScene running_scene
        uint64_t time

        void attach_scene(CScene* c_scene)
        void scene_run()

    CEngine* get_c_engine "get_engine"()
