from libcpp.string cimport string
from libcpp.memory cimport unique_ptr
from libcpp.vector cimport vector
from libc.stdint cimport int32_t, uint64_t

from .display cimport CDisplay
from .scenes cimport CScene
from .window cimport CWindow
from .input cimport CInputManager
from .exceptions cimport raise_py_error
from .vectors cimport CUVec2


cdef extern from "kaacore/engine.h" nogil:
    cdef enum CVirtualResolutionMode "kaacore::VirtualResolutionMode":
        adaptive_stretch "kaacore::VirtualResolutionMode::adaptive_stretch"
        aggresive_stretch "kaacore::VirtualResolutionMode::aggresive_stretch"
        no_stretch "kaacore::VirtualResolutionMode::no_stretch"

    cdef cppclass CEngine "kaacore::Engine":
        unique_ptr[CWindow] window
        unique_ptr[CInputManager] input_manager
        CScene* scene
        uint64_t time

        CEngine(CUVec2 virtual_resolution)
        CEngine(CUVec2 virtual_resolution,
                CVirtualResolutionMode virtual_resolution_mode)

        vector[CDisplay] get_displays()
        void run(CScene* c_scene) \
            except +raise_py_error
        void change_scene(CScene* c_scene) \
            except +raise_py_error
        void quit() \
            except +raise_py_error

        CUVec2 virtual_resolution()
        void virtual_resolution(CUVec2 resolution)

        CVirtualResolutionMode virtual_resolution_mode()
        void virtual_resolution_mode(CVirtualResolutionMode vr_mode)

    CEngine* c_engine "kaacore::engine"

cdef inline CEngine* get_c_engine():
    return c_engine
