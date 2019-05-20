from libcpp.memory cimport unique_ptr

from .kaacore.scenes cimport CScene
from .kaacore.engine cimport CEngine, get_c_engine, create_c_engine


@cython.final
cdef class Engine:
    cdef unique_ptr[CEngine] owned_engine

    def __init__(self, *args, **kwargs):
        if get_c_engine() != NULL:
            raise RuntimeError(
                f"{self.__class__} must not have multiple instances."
            )
        self.owned_engine = create_c_engine()

    cdef CEngine* _get_c_engine(self):
        return get_c_engine()

    def run(self, Scene scene not None):
        self._get_c_engine().run(<CScene*>scene.c_scene)

    def quit(self):
        self._get_c_engine().quit()

    @property
    def window(self):
        return _Window.__new__(_Window)


def get_engine():
    cdef Engine engine
    if get_c_engine() != NULL:
        engine = Engine.__new__(Engine)
        return engine
