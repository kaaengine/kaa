from __future__ import annotations

from typing import final, Union


@final
class Color:
    def __init__(
        self, r: float = 0., g: float = 0.,
        b: float = 0., a: float = 1.,
    ) -> None:
        ...

    @classmethod
    def from_int(
        self, r: int = 0, g: int = 0,
        b: int = 0, a: int = 255,
    ) -> Color:
        ...

    @classmethod
    def from_hex(self, hex_color: Union[int, str]) -> Color:
        ...

    @property
    def r(self) -> float:
        ...

    @property
    def g(self) -> float:
        ...

    @property
    def b(self) -> float:
        ...

    @property
    def a(self) -> float:
        ...
