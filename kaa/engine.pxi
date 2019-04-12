# from libcpp.vector cimport vector

from .kaacore.scenes cimport CScene
from .kaacore.engine cimport CEngine, get_c_engine

cdef Engine engine = None


def get_engine():
    global engine
    assert engine is not None
    return engine


cdef class Engine:
    cdef:
        readonly Scene scene
        readonly Window window

        CEngine c_engine

    def __cinit__(self, *args, **kwargs):
        global engine
        if engine is not None:
            raise RuntimeError(
                f"{self.__class__} must not have multiple instances."
            )
        engine = self

    def get_display_info(self):
        pass
        # cdef:
        #     int32_t i
        #     list result = []
        #     vector[CDisplay] display_info = self.c_engine.get_display_info()
        #     int32_t display_num = display_info.size()


    def run(self, Scene scene not None):
        self.scene = scene
        self.c_engine.run(<CScene*>scene.c_scene)

    def quit(self):
        self.c_engine.quit()
