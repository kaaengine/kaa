from contextlib import contextmanager

from libcpp.memory cimport unique_ptr

from .kaacore.scenes cimport CScene
from .kaacore.engine cimport CEngine, get_c_engine, create_c_engine


cdef unique_ptr[CEngine] _c_engine_instance
_c_engine_instance.reset(NULL)


@cython.final
cdef class _Engine:
    cdef _Window _window

    def __init__(self):
        self._window = _Window()

    cdef inline CEngine* _get_c_engine(self):
        cdef CEngine* c_engine = get_c_engine()
        if c_engine == NULL:
            raise ValueError("Engine is not running")
        return c_engine

    @property
    def current_scene(self):
        cdef CPyScene* c_scene = <CPyScene*>self._get_c_engine().scene
        return <object>c_scene.py_scene

    def change_scene(self, Scene scene not None):
        self._get_c_engine().change_scene(scene.c_scene)

    def run(self, Scene scene not None):
        self._get_c_engine().run(<CScene*>scene.c_scene)

    def quit(self):
        self._get_c_engine().quit()

    @property
    def window(self):
        return self._window

    def stop(self):
        if get_c_engine() == NULL:
            raise ValueError("Engine is stopped")
        assert _c_engine_instance != NULL

        _c_engine_instance.reset(NULL)

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.stop()


cdef _Engine _engine_wrapper = _Engine()


def Engine(show_window=True):
    global _c_engine_instance
    if get_c_engine() != NULL:
        raise ValueError("Engine was already started")
    assert _c_engine_instance == NULL

    _c_engine_instance = create_c_engine()
    if show_window is True:
        _engine_wrapper.window.show()

    return _engine_wrapper


def get_engine():
    if get_c_engine() != NULL:
        return _engine_wrapper
