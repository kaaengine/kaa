from libcpp cimport bool
from libc.stdint cimport uint32_t
from libcpp.functional cimport function

from .exceptions cimport raise_py_error
from .glue cimport CPythonicCallbackWrapper, CPythonicCallbackResult


cdef extern from "kaacore/timers.h" nogil:
    ctypedef function[void()] CTimerCallback "kaacore::TimerCallback"

    cdef cppclass CTimer "kaacore::Timer":
        CTimer()
        CTimer(const CTimerCallback callback, const uint32_t interval,
            const bool single_shot
        )

        void start() except +raise_py_error
        bool is_running()
        void stop()
        uint32_t interval()
        void interval(uint32_t) except +raise_py_error
        bool single_shot()
        void single_shot(bool) except +raise_py_error

cdef extern from "extra/include/pythonic_callback.h":
    ctypedef CPythonicCallbackResult[void] (*CythonTimerCallback)(const CPythonicCallbackWrapper&)
    CythonTimerCallback bind_cython_timer_callback(
        const CythonTimerCallback cy_handler,
        const CPythonicCallbackWrapper callback
    )
