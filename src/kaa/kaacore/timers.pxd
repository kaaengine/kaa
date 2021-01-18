from libcpp cimport bool
from libcpp.functional cimport function

from .scenes cimport CScene
from .clock cimport CDuration
from .exceptions cimport raise_py_error
from .glue cimport CPythonicCallbackWrapper, CPythonicCallbackResult


cdef extern from "kaacore/timers.h" namespace "kaacore" nogil:
    cdef cppclass CTimerContext "kaacore::TimerContext":
        CDuration interval
        CScene* scene

    cdef cppclass CTimerCallback "kaacore::TimerCallback":
        pass

    cdef cppclass CTimer "kaacore::Timer":
        CTimer()
        CTimer(const CTimerCallback callback)

        void start_global(const CDuration seconds) except +raise_py_error
        void start(const CDuration seconds, CScene* const scene) except +raise_py_error
        bool is_running()
        void stop()

cdef extern from "extra/include/pythonic_callback.h":
    ctypedef CPythonicCallbackResult[CDuration] (*CythonTimerCallback)(const CPythonicCallbackWrapper&, CTimerContext)
    CTimerCallback bind_cython_timer_callback(
        const CythonTimerCallback cy_handler,
        const CPythonicCallbackWrapper callback
    )
