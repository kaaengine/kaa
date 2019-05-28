from contextlib import contextmanager

from libcpp.memory cimport unique_ptr

from .kaacore.scenes cimport CScene
from .kaacore.engine cimport CEngine, get_c_engine, create_c_engine


@cython.final
cdef class _Engine:
    cdef _Window _window

    def __init__(self):
        self._window = _Window()

    cdef CEngine* _get_c_engine(self):
        cdef CEngine* c_engine = get_c_engine()
        if c_engine == NULL:
            raise ValueError("Engine is not running")
        return c_engine

    def run(self, Scene scene not None):
        self._get_c_engine().run(<CScene*>scene.c_scene)

    def quit(self):
        self._get_c_engine().quit()

    @property
    def window(self):
        return self._window


cdef _Engine _engine_wrapper = _Engine()


def get_engine():
    cdef _Engine engine
    if get_c_engine() != NULL:
        return _engine_wrapper


@cython.final
cdef class _EngineRunnerSingleton:
    cdef unique_ptr[CEngine] c_engine_instance

    def __cinit__(self):
        self.c_engine_instance.reset(NULL)

    def start(self):
        if self.c_engine_instance != NULL:
            raise ValueError("Engine was alredy started")

        self.c_engine_instance = create_c_engine()
        return _engine_wrapper

    def stop(self):
        if self.c_engine_instance == NULL:
            raise ValueError("Engine is stopped")

        self.c_engine_instance.reset(NULL)

    def __call__(self, *args, **kwargs):
        # @contextmanager fails to work in cdef class
        # returned generator has no __enter__ and __exit__
        return _EngineRunner_contextmanager(self)


@contextmanager
def _EngineRunner_contextmanager(runner, *args, **kwargs):
    print("Starting")
    engine = runner.start(*args, **kwargs)
    print("Started")
    try:
        yield engine
    finally:
        runner.stop()


EngineRunner = _EngineRunnerSingleton()
