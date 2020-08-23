import cython
from libcpp cimport bool
from libc.stdint cimport uint32_t

from .kaacore.glue cimport CPythonicCallbackWrapper, CPythonicCallbackResult
from .kaacore.timers cimport bind_cython_timer_callback, CTimerCallback, CTimer

DEF TIMER_FREELIST_SIZE = 10


cdef CPythonicCallbackResult[void] cython_timer_callback(
    const CPythonicCallbackWrapper& c_wrapper
) with gil:
    cdef object callback = <object>c_wrapper.py_callback
    try:
        callback()
    except Exception as py_exc:
        return CPythonicCallbackResult[void](<PyObject*>py_exc)
    return CPythonicCallbackResult[void]()


@cython.final
@cython.freelist(TIMER_FREELIST_SIZE)
cdef class Timer:
    cdef CTimer _c_timer

    def __cinit__(
        self, object callback not None, uint32_t interval=0,
        bint single_shot=True
    ):
        cdef CTimerCallback bound_callback = bind_cython_timer_callback(
            cython_timer_callback, CPythonicCallbackWrapper(<PyObject*>callback),
        )
        self._c_timer = CTimer(bound_callback, interval, single_shot)

    @property
    def is_running(self):
        return self._c_timer.is_running()

    @property
    def interval(self):
        return self._c_timer.interval()

    @interval.setter
    def interval(self, uint32_t value):
        self._c_timer.interval(value)

    @property
    def single_shot(self):
        return self._c_timer.single_shot()

    @single_shot.setter
    def single_shot(self, bint value):
        self._c_timer.single_shot(value)

    def start(self):
        self._c_timer.start()

    def stop(self):
        self._c_timer.stop()
