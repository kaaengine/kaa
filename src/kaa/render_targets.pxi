import cython
from libcpp.memory cimport static_pointer_cast

from .kaacore.hashing cimport c_calculate_hash
from .kaacore.resources cimport CResourceReference
from .kaacore.render_targets cimport CRenderTarget

ctypedef CRenderTarget* CRenderTarget_ptr


@cython.final
cdef class RenderTarget:
    cdef CResourceReference[CRenderTarget] c_render_target

    def __init__(self, Color clear_color=None):
        self.c_render_target = CRenderTarget.create()
        if clear_color is not None:
            self.clear_color = clear_color

    @staticmethod
    cdef RenderTarget create(
        const CResourceReference[CRenderTarget]& c_render_target
    ):
        cdef RenderTarget instance = RenderTarget.__new__(RenderTarget)
        instance.c_render_target = c_render_target
        return instance

    def __eq__(self, RenderTarget other):
        if other is None:
            return False

        return self.c_render_target == other.c_render_target

    def __hash__(self):
        return c_calculate_hash[CRenderTarget_ptr](
            self.c_render_target.get()
        )

    @property
    def clear_color(self):
        return Color.from_c_color(self.c_render_target.get().clear_color())

    @clear_color.setter
    def clear_color(self, Color color not None):
        self.c_render_target.get().clear_color(color.c_color)

    @property
    def texture(self):
        return Texture.create(
            CResourceReference[CTexture](
                static_pointer_cast[CTexture, CRenderTarget](
                    self.c_render_target.res_ptr
                )
            )
        )
