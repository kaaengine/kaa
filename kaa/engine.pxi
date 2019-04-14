from libcpp.vector cimport vector

from .kaacore.scenes cimport CScene
from .kaacore.display cimport CDisplay
from .kaacore.engine cimport CEngine, get_c_engine

cdef Engine engine = None


def get_engine():
    global engine

    if engine is not None:
        return engine

    # CEngine instance could be created from c++,
    # create missing python wrapper
    cdef CEngine* c_engine = get_c_engine()
    if c_engine == NULL:
        raise RuntimeError(
            'Attempting to get engine instance, before creating it. Aborting.'
        )
    engine = Engine()
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
        self.window = self._create_window()

    cdef Window _create_window(self):
        cdef Window window = Window.__new__(Window)
        window.c_window = self.c_engine.window.get()
        return window

    def get_display_info(self):
        cdef:
            list result = []
            CDisplay display
            vector[CDisplay] display_info

        display_info = self.c_engine.get_display_info()
        for display in display_info:
            result.append({
                'index': display.index,
                'name': display.name.decode(),
                'position': Vector(display.position.x, display.position.y),
                'size': Vector(display.size.x, display.size.y)
            })

        return result

    def run(self, Scene scene not None):
        self.scene = scene
        self.c_engine.run(<CScene*>scene.c_scene)

    def quit(self):
        self.c_engine.quit()
