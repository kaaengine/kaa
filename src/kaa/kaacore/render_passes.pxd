from libcpp cimport bool
from libc.stdint cimport uint16_t
from libcpp.vector cimport vector

from ..extra.optional cimport optional

from .shaders cimport CShader
from .materials cimport CMaterial
from .exceptions cimport raise_py_error
from .resources cimport CResourceReference
from .render_targets cimport CRenderTarget
from .vectors cimport CColor, CIVec2, CUVec2
from .uniforms cimport CUniformSpecificationMap


ctypedef vector[CResourceReference[CRenderTarget]] CRenderTargets

cdef extern from "kaacore/render_passes.h" namespace "kaacore" nogil:
    uint16_t default_pass_index

    cdef cppclass CEffect "kaacore::Effect":
        CEffect() except +raise_py_error
        CEffect(
            const CResourceReference[CShader]& fragment_shader,
            const CUniformSpecificationMap& uniforms
        ) except +raise_py_error
        bool operator==(const CEffect other) except +raise_py_error
        CEffect clone() except +raise_py_error
        CResourceReference[CMaterial]& material() except +raise_py_error

    cdef cppclass CRenderPass "kaacore::RenderPass":
        optional[CEffect] effect() except +raise_py_error
        void effect(const optional[CEffect]& effect) except +raise_py_error
        optional[CRenderTargets] render_targets() except +raise_py_error
        void render_targets(const optional[CRenderTargets]& targets) \
            except +raise_py_error

        uint16_t index() except +raise_py_error
        CColor clear_color() except +raise_py_error
        void clear_color(const CColor& color) except +raise_py_error

    cdef cppclass CRenderPassesManager "kaacore::RenderPassesManager":
        CRenderPass& operator[](const uint16_t index) except +raise_py_error
        CRenderPass* get(const uint16_t index) except +raise_py_error

        size_t size()
