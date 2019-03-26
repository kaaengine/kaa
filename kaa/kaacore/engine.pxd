from libcpp cimport bool
from libcpp.string cimport string
from libc.stdint cimport int32_t, uint64_t
from libcpp.memory cimport unique_ptr

from .scenes cimport CScene
from .types cimport CRectangle
from .input cimport CInputManager

cdef extern from "kaacore/engine.h" nogil:
    cdef cppclass CEngine "kaacore::Engine":
        unique_ptr[CInputManager] input_manager
        CScene running_scene
        uint64_t time

        CRectangle get_display_rect()
        void create_window()
        void create_window(string title, int32_t width, int32_t height,
            int32_t x, int32_t y, bool fullscreen)
        void run(CScene* c_scene)
        void quit()

    CEngine* get_c_engine "kaacore::get_engine"()
