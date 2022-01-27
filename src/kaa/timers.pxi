cimport cython

from libcpp.cast cimport dynamic_cast

from .kaacore.clock cimport CDuration
from .kaacore.timers cimport (
    bind_cython_timer_callback, CTimerCallback, CTimerContext, CTimer
)
from .kaacore.glue cimport CPythonicCallbackWrapper, CPythonicCallbackResult

DEF TIMER_FREELIST_SIZE = 10
DEF TIMER_CONTEXT_FREELIST_SIZE = 2
ctypedef CPyScene* _CPyScenePtr


@cython.final
@cython.freelist(TIMER_CONTEXT_FREELIST_SIZE)
cdef class TimerContext:
    cdef CTimerContext c_context

    @staticmethod
    cdef TimerContext create(CTimerContext c_context):
        cdef TimerContext result = TimerContext.__new__(TimerContext)
        result.c_context = c_context
        return result

    @property
    def scene(self):
        if self.c_context.scene == NULL:
            return

        return dynamic_cast[_CPyScenePtr](
            self.c_context.scene
        ).py_scene_weakref()

    @property
    def interval(self):
        return self.c_context.interval.count()


cdef CPythonicCallbackResult[CDuration] cython_timer_callback(
    const CPythonicCallbackWrapper& c_wrapper, CTimerContext c_context
) with gil:
    cdef:
        object result
        double new_interval = 0
        object callback = <object>c_wrapper.py_callback
        TimerContext context = TimerContext.create(c_context)
    try:
        result = callback(context)
        if result is not None:
            new_interval = result
    except Exception as py_exc:
        return CPythonicCallbackResult[CDuration](<PyObject*>py_exc)
    return CPythonicCallbackResult[CDuration](CDuration(new_interval))


@cython.freelist(TIMER_FREELIST_SIZE)
cdef class Timer:
    cdef CTimer c_timer

    def __cinit__(
        self, object callback not None):
        cdef CTimerCallback bound_callback = bind_cython_timer_callback(
            cython_timer_callback, CPythonicCallbackWrapper(<PyObject*>callback),
        )
        self.c_timer = CTimer(bound_callback)

    @property
    def is_running(self):
        return self.c_timer.is_running()

    def start(self, double interval, Scene scene not None):
        self.c_timer.start(CDuration(interval), scene._c_scene.get())

    def start_global(self, double interval):
        self.c_timer.start_global(CDuration(interval))

    def stop(self):
        self.c_timer.stop()
