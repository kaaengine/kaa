cimport cython

from .kaacore.vectors cimport CColor
from .kaacore.renderer cimport CRenderer
from .kaacore.engine cimport CEngine, get_c_engine


@cython.final
cdef class _Renderer:
    cdef CRenderer* _get_c_renderer(self):
        cdef CEngine* c_engine = get_c_engine()
        assert c_engine != NULL
        cdef CRenderer* c_renderer = c_engine.renderer.get()
        assert c_renderer != NULL
        return c_renderer
    
    @property
    def clear_color(self):
        cdef CColor c_color = self._get_c_renderer().clear_color()
        return Color.from_c_color(c_color)
    
    @clear_color.setter
    def clear_color(self, Color value):
        self._get_c_renderer().clear_color(value.c_color)
