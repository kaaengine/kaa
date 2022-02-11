import cython
from libc.stdint cimport uint16_t
from cpython.weakref cimport PyWeakref_NewRef

from .extra.optional cimport optional, nullopt

from .kaacore.render_passes cimport (
    CEffect, CRenderTargets, CRenderPass, CRenderPassesManager
)


@cython.final
cdef class _RenderPassesManager(_SceneResource):
    cdef:
        object _scene_weakref
        CRenderPassesManager* c_passes

    @staticmethod
    cdef _RenderPassesManager create(Scene scene):
        cdef _RenderPassesManager passes_manager = _RenderPassesManager.__new__(
            _RenderPassesManager, scene
        )
        passes_manager._scene_weakref = PyWeakref_NewRef(scene, None)
        passes_manager.c_passes = &scene.c_scene.get().render_passes
        return passes_manager

    cdef CRenderPassesManager* get_c_passes(self) except NULL:
        self.check_valid()
        return self.c_passes

    def __getitem__(self, uint16_t index):
        cdef CRenderPass* c_pass = self.get_c_passes().get(index)
        return _RenderPass.create(c_pass, self._scene_weakref())

    def __setitem__(self, index, value):
        raise NotImplementedError

    @cython.wraparound(False)
    @cython.boundscheck(False)
    def __iter__(self):
        cdef:
            uint16_t index
            size_t size = self.get_c_passes().size()

        for index in range(0, size):
            yield self[index]

    def __len__(self):
        return self.get_c_passes().size()


@cython.final
cdef class Effect(_Material):
    cdef CEffect c_effect

    def __init__(self, FragmentShader shader not None, dict uniforms=None):
        object.__init__(self)

        cdef:
            str name
            Uniform uniform
            CUniformSpecificationMap c_uniforms

        uniforms = uniforms or {}
        c_uniforms.reserve(len(uniforms))
        for name, uniform in uniforms.items():
            c_uniforms[name.encode()] = uniform.c_specification

        self.c_effect = CEffect(shader.c_shader, c_uniforms)
        self.c_material = self.c_effect.material()

    @staticmethod
    cdef Effect create(CEffect& c_effect):
        cdef Effect instance = Effect.__new__(Effect)
        instance.c_effect = c_effect
        instance.c_material = c_effect.material()
        return instance

    def clone(self):
        return Effect.create(self.c_effect.clone())


@cython.final
cdef class _RenderPass(_SceneResource):
    cdef CRenderPass* c_pass

    @staticmethod
    cdef _RenderPass create(CRenderPass* c_pass, Scene scene):
        cdef _RenderPass render_pass = _RenderPass.__new__(_RenderPass, scene)
        render_pass.c_pass = c_pass
        return render_pass

    cdef CRenderPass* get_c_pass(self) except NULL:
        self.check_valid()
        return self.c_pass

    def __str__(self):
        return f'RenderPass[{self.index}]'

    @property
    def index(self):
        return self.get_c_pass().index()

    @property
    def clear_color(self):
        return Color.from_c_color(self.get_c_pass().clear_color())

    @clear_color.setter
    def clear_color(self, Color color not None):
        self.get_c_pass().clear_color(color.c_color)

    @property
    def effect(self):
        cdef optional[CEffect] c_effect = self.get_c_pass().effect()
        if c_effect.has_value():
            return Effect.create(c_effect.value())

    @effect.setter
    def effect(self, Effect value):
        if value:
            self.get_c_pass().effect(optional[CEffect](value.c_effect))
        else:
             self.get_c_pass().effect(optional[CEffect](nullopt))

    @property
    def render_targets(self):
        cdef optional[CRenderTargets] c_targets
        c_targets = self.get_c_pass().render_targets()

        if not c_targets.has_value():
            return

        cdef:
            uint16_t c_index
            list result = []

        for c_index in range(0, c_targets.value().size()):
            result.append(RenderTarget.create(c_targets.value()[c_index]))

        return tuple(result)

    @render_targets.setter
    def render_targets(self, object render_targets):
        if render_targets is None:
            self.get_c_pass().render_targets(optional[CRenderTargets](nullopt))
            return

        cdef:
            RenderTarget target
            vector[CResourceReference[CRenderTarget]] c_targets

        for target in render_targets:
            c_targets.push_back(target.c_render_target)

        self.get_c_pass().render_targets(optional[CRenderTargets](c_targets))
