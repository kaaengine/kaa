from .kaacore.engine cimport CEngine, get_c_engine
from .kaacore.scenes cimport CScene

cdef Engine engine = None


def get_engine():
    global engine
    assert engine is not None
    return engine


cdef class Engine:
    cdef:
        Scene scene
        CEngine c_engine

    def __cinit__(self, *args, **kwargs):
        global engine
        engine = self

    @property
    def scene(self):
        return self.scene

    def run(self, Scene scene not None):
        self.scene = scene
        self.c_engine.run(<CScene*>scene.c_scene)

    def quit(self):
        self.c_engine.quit()
