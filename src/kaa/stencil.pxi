from enum import IntEnum

from .kaacore.stencil cimport CStencilTest, CStencilOp, CStencilMode

class StencilTest(IntEnum):
    disabled = <uint8_t>CStencilTest.disabled
    less = <uint8_t>CStencilTest.less
    less_equal = <uint8_t>CStencilTest.less_equal
    equal = <uint8_t>CStencilTest.equal
    greater_equal = <uint8_t>CStencilTest.greater_equal
    greater = <uint8_t>CStencilTest.greater
    not_equal = <uint8_t>CStencilTest.not_equal
    never = <uint8_t>CStencilTest.never
    always = <uint8_t>CStencilTest.always


class StencilOp(IntEnum):
    zero = <uint8_t>CStencilOp.zero
    keep = <uint8_t>CStencilOp.keep
    replace = <uint8_t>CStencilOp.replace
    increase_wrap = <uint8_t>CStencilOp.increase_wrap
    increase_clamp = <uint8_t>CStencilOp.increase_clamp
    decrease_wrap = <uint8_t>CStencilOp.decrease_wrap
    decrease_clamp = <uint8_t>CStencilOp.decrease_clamp
    invert = <uint8_t>CStencilOp.invert


cdef class StencilMode:
    cdef CStencilMode c_stencil_mode

    def __init__(
        self, *, int value=0, int mask=0xFF, object test=StencilTest.always,
        object stencil_fail_op=StencilOp.keep,
        object depth_fail_op=StencilOp.keep,
        object pass_op=StencilOp.keep,
    ):
        self.c_stencil_mode = CStencilMode(
            value, mask, <CStencilTest>(<uint8_t>test.value),
            <CStencilOp>(<uint8_t>stencil_fail_op.value),
            <CStencilOp>(<uint8_t>depth_fail_op.value),
            <CStencilOp>(<uint8_t>pass_op.value),
        )

    @staticmethod
    cdef StencilMode create(CStencilMode c_stencil_mode):
        cdef StencilMode stencil_mode = StencilMode.__new__(StencilMode)
        stencil_mode.c_stencil_mode = c_stencil_mode
        return stencil_mode

    @property
    def value(self):
        return self.c_stencil_mode.value()

    @value.setter
    def value(self, int new_value):
        self.c_stencil_mode.value(new_value)

    @property
    def mask(self):
        return self.c_stencil_mode.mask()

    @mask.setter
    def mask(self, int new_mask):
        self.c_stencil_mode.mask(new_mask)

    @property
    def test(self):
        return StencilTest(<uint8_t>self.c_stencil_mode.test())

    @test.setter
    def test(self, object new_test):
        self.c_stencil_mode.test(<CStencilTest>(<uint8_t>new_test.value))

    @property
    def stencil_fail_op(self):
        return StencilOp(<uint8_t>self.c_stencil_mode.stencil_fail_op())

    @stencil_fail_op.setter
    def stencil_fail_op(self, object new_stencil_fail_op):
        self.c_stencil_mode.stencil_fail_op(<CStencilOp>(<uint8_t>new_stencil_fail_op.value))

    @property
    def depth_fail_op(self):
        return StencilOp(<uint8_t>self.c_stencil_mode.depth_fail_op())

    @depth_fail_op.setter
    def depth_fail_op(self, object new_depth_fail_op):
        self.c_stencil_mode.depth_fail_op(<CStencilOp>(<uint8_t>new_depth_fail_op.value))

    @property
    def pass_op(self):
        return StencilOp(<uint8_t>self.c_stencil_mode.pass_op())

    @pass_op.setter
    def pass_op(self, object new_pass_op):
        self.c_stencil_mode.pass_op(<CStencilOp>(<uint8_t>new_pass_op.value))
