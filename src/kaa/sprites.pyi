from typing import List

from .geometry import Vector


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
