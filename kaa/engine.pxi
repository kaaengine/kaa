from .kaacore.scenes cimport CScene
from .kaacore.types cimport CRectangle
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

    def get_display_rect(self):
        cdef CRectangle rect = self.c_engine.get_display_rect()
        return rect.x, rect.y, rect.w, rect.h

    def create_window(self, title, width=None, height=None,
        x=WINDOWPOS_CENTERED, y=WINDOWPOS_CENTERED
    ):
        if not width:
            *_, width, _ = self.get_display_rect()

        if not height:
            *_, height = self.get_display_rect()

        cdef CWindow* c_window = self.c_engine.create_window(
            title.encode(), width, height, x, y
        )
        self.window = Window.create(c_window)

    def run(self, Scene scene not None):
        self.scene = scene
        self.c_engine.run(<CScene*>scene.c_scene)

    def quit(self):
        self.c_engine.quit()
