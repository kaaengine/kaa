from __future__ import annotations

import enum
from typing import final


class StencilTest(enum.IntEnum):
    disabled: StencilTest
    less: StencilTest
    less_equal: StencilTest
    equal: StencilTest
    greater_equal: StencilTest
    greater: StencilTest
    not_equal: StencilTest
    never: StencilTest
    always: StencilTest


class StencilOp(enum.IntEnum):
    zero: StencilOp
    keep: StencilOp
    replace: StencilOp
    increase_wrap: StencilOp
    increase_clamp: StencilOp
    decrease_wrap: StencilOp
    decrease_clamp: StencilOp
    invert: StencilOp


@final
class StencilMode:
    def __init__(
        self, *, value: int = 0, mask: int = 0xFF,
        test: StencilTest = StencilTest.always,
        stencil_fail_op: StencilOp = StencilOp.keep,
        pass_op: StencilOp = StencilOp.keep,
    ) -> None:
        ...

    @property
    def value(self) -> int:
        pass

    @value.setter
    def value(self, new_value: int) -> None:
        ...

    @property
    def mask(self) -> int:
        pass

    @mask.setter
    def mask(self, new_mask: int) -> None:
        ...

    @property
    def test(self) -> StencilTest:
        ...

    @test.setter
    def test(self, new_test: StencilTest) -> None:
        ...

    @property
    def stencil_fail_op(self) -> StencilOp:
        ...

    @stencil_fail_op.setter
    def stencil_fail_op(self, new_stencil_fail_op: StencilOp) -> None:
        ...

    @property
    def pass_op(self) -> StencilOp:
        ...

    @pass_op.setter
    def pass_op(self, new_pass_op: StencilOp) -> None:
        ...
