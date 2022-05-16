from libc.stdint cimport uint8_t, uint32_t
from libcpp cimport bool

from .vectors cimport CDVec2
from .geometry cimport CTransformation, CBoundingBox
from .exceptions cimport raise_py_error


cdef extern from "kaacore/stencil.h" namespace "kaacore" nogil:
    cdef enum CStencilTest "kaacore::StencilTest":
        disabled "kaacore::StencilTest::disabled",
        less "kaacore::StencilTest::less",
        less_equal "kaacore::StencilTest::less_equal",
        equal "kaacore::StencilTest::equal",
        greater_equal "kaacore::StencilTest::greater_equal",
        greater "kaacore::StencilTest::greater",
        not_equal "kaacore::StencilTest::not_equal",
        never "kaacore::StencilTest::never",
        always "kaacore::StencilTest::always",

    cdef enum CStencilOp "kaacore::StencilOp":
        zero "kaacore::StencilOp::zero",
        keep "kaacore::StencilOp::keep",
        replace "kaacore::StencilOp::replace",
        increase_wrap "kaacore::StencilOp::increase_wrap",
        increase_clamp "kaacore::StencilOp::increase_clamp",
        decrease_wrap "kaacore::StencilOp::decrease_wrap",
        decrease_clamp "kaacore::StencilOp::decrease_clamp",
        invert "kaacore::StencilOp::invert",

    cdef cppclass CStencilMode "kaacore::StencilMode":
        CStencilMode()
        CStencilMode(uint8_t value, uint8_t mask, CStencilTest test,
                     CStencilOp stencil_fail_op, CStencilOp depth_fail_op,
                     CStencilOp pass_op)

        bool operator==(const CStencilMode&)

        uint8_t value() except +raise_py_error
        void value(const uint8_t new_value) except +raise_py_error

        uint8_t mask() except +raise_py_error
        void mask(const uint8_t new_value) except +raise_py_error

        CStencilTest test() except +raise_py_error
        void test(const CStencilTest new_value) except +raise_py_error

        CStencilOp stencil_fail_op() except +raise_py_error
        void stencil_fail_op(const CStencilOp new_value) except +raise_py_error

        CStencilOp depth_fail_op() except +raise_py_error
        void depth_fail_op(const CStencilOp new_value) except +raise_py_error

        CStencilOp pass_op() except +raise_py_error
        void pass_op(const CStencilOp new_value) except +raise_py_error
