from .kaacore.scenes cimport CScene
from .kaacore.types cimport CRectangle
from .kaacore.engine cimport CEngine, get_c_engine

DEF WINDOWPOS_UNDEFINED = 0x1FFF0000

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
        if engine is not None:
            raise RuntimeError(
                f"{self.__class__} must not have multiple instances."
            )
        engine = self

    @property
    def scene(self):
        return self.scene

    def get_display_rect(self):
        cdef CRectangle rect = self.c_engine.get_display_rect()
        return rect.x, rect.y, rect.w, rect.h

    def create_window(self, title, width, height,
        x=WINDOWPOS_UNDEFINED, y=WINDOWPOS_UNDEFINED, fullscreen=False
    ):
        self.c_engine.create_window(
            title.encode(), width, height, x, y, fullscreen
        )

    def run(self, Scene scene not None):
        self.scene = scene
        self.c_engine.run(<CScene*>scene.c_scene)

    def quit(self):
        self.c_engine.quit()
