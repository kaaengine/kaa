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
        return _Window.__new__(_Window)


cdef _Engine _engine_wrapper = _Engine()


def get_engine():
    cdef _Engine engine
    if get_c_engine() != NULL:
        return _engine_wrapper


@contextmanager
def start_engine():
    cdef unique_ptr[CEngine] c_engine

    c_engine = create_c_engine()
    yield _engine_wrapper
