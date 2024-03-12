from __future__ import annotations

from typing import List

from .geometry import Vector
from .colors import Color


@final
class Sprite:
    @property
    def dimensions(self) -> Vector:
        ...

    @property
    def origin(self) -> Vector:
        ...

    @property
    def size(self) -> Vector:
        ...

    def __init__(self, path: str) -> None:
        ...

    def crop(self, origin: Vector, dimensions: Vector) -> Sprite:
        ...

    @property
    def can_query(self) -> bool:
        ...

    def query_pixel(self, position: Vector) -> Color:
        ...

    def __eq__(self, other) -> bool:
        ...

    def __hash__(self) -> int:
        ...


def split_spritesheet(
    spritesheet: Sprite,
    frame_dimensions: Vector,
    frames_offset: int = 0,
    frames_count: int = 0,
    frame_padding: Vector = Vector(0, 0),
) -> List[Sprite]:
    ...
