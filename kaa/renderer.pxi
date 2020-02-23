cimport cython

from .kaacore.vectors cimport CColor
from .kaacore.renderer cimport CRenderer
from .kaacore.engine cimport CEngine, get_c_engine


@cython.final
cdef class _Renderer:
    cdef CRenderer* _get_c_renderer(self) except NULL:
        return get_c_engine().renderer.get()
    
    @property
    def clear_color(self):
        cdef CColor c_color = self._get_c_renderer().clear_color()
        return Color.from_c_color(c_color)
    
    @clear_color.setter
    def clear_color(self, Color value):
        self._get_c_renderer().clear_color(value.c_color)
