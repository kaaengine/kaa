from libcpp.string cimport string
from libcpp.memory cimport unique_ptr
from libcpp.vector cimport vector
from libc.stdint cimport int32_t, uint64_t

from .clock cimport CDuration
from .capture cimport CCapturingAdapterBase
from .display cimport CDisplay
from .scenes cimport CScene
from .window cimport CWindow
from .audio cimport CAudioManager
from .input cimport CInputManager
from .exceptions cimport raise_py_error
from .vectors cimport CUVec2


cdef extern from "kaacore/engine.h" namespace "kaacore" nogil:
    cdef enum CVirtualResolutionMode "kaacore::VirtualResolutionMode":
        adaptive_stretch "kaacore::VirtualResolutionMode::adaptive_stretch"
        aggresive_stretch "kaacore::VirtualResolutionMode::aggresive_stretch"
        no_stretch "kaacore::VirtualResolutionMode::no_stretch"

    cdef string get_c_persistent_path "kaacore::get_persistent_path" (
        const string& prefix,
        const string& organization_prefix
    ) except +raise_py_error

    cdef cppclass CEngine "kaacore::Engine":
        unique_ptr[CWindow] window
        unique_ptr[CInputManager] input_manager
        unique_ptr[CAudioManager] audio_manager

        CScene* current_scene() except +raise_py_error
        CUVec2 virtual_resolution() except +raise_py_error
        void virtual_resolution(CUVec2 resolution) except +raise_py_error

        CVirtualResolutionMode virtual_resolution_mode() except +raise_py_error
        void virtual_resolution_mode(
            CVirtualResolutionMode vr_mode
        ) except +raise_py_error

        CEngine(CUVec2 virtual_resolution)
        CEngine(CUVec2 virtual_resolution,
                CVirtualResolutionMode virtual_resolution_mode)

        vector[CDisplay] get_displays() except +raise_py_error
        CDuration total_time() except +raise_py_error
        double get_fps() except +raise_py_error
        CDuration total_time() except +raise_py_error
        vector[CDisplay] get_displays() except +raise_py_error
        void run(CScene* c_scene, uint32_t frames_limit, CDuration frame_fixed_duration,
                 CCapturingAdapterBase* capturing_adapter) except +raise_py_error
        void change_scene(CScene* c_scene) except +raise_py_error
        void quit() except +raise_py_error

    bint is_c_engine_initialized "kaacore::is_engine_initialized"()
    CEngine* get_c_engine "kaacore::get_engine"() except +raise_py_error
