from libcpp cimport bool
from libc.stdint cimport uint32_t

from .kaacore.glue cimport CPythonicCallbackWrapper
from .kaacore.exceptions cimport c_wrap_python_exception
from .kaacore.timers cimport bind_cython_timer_callback, CTimerCallback, CTimer


cdef void cython_timer_callback(CPythonicCallbackWrapper c_wrapper):
    cdef object callback = <object>c_wrapper.py_callback
    try:
        callback()
    except Exception as py_exc:
        c_wrap_python_exception(<PyObject*>py_exc)


cdef class Timer:
    cdef CTimer c_timer

    def __cinit__(
        self, uint32_t interval, object callback not None,
        bool single_shot=True
    ):
        cdef CTimerCallback bound_callback = bind_cython_timer_callback(
            cython_timer_callback, CPythonicCallbackWrapper(<PyObject*>callback),
        )
        self.c_timer = CTimer(interval, bound_callback, single_shot)

    @property
    def is_running(self):
        return self.c_timer.is_running()

    def start(self):
        self.c_timer.start()

    def stop(self):
        self.c_timer.stop()
