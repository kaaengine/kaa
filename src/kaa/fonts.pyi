from __future__ import annotations

from typing import final, Optional, Set

from .colors import Color
from .geometry import AnyShape, Alignment, Transformation, Vector
from .nodes import AnyNode, NodeBase
from .transitions import AnyTransitionArgument
from .sprites import Sprite


@final
class Font:
    def __init__(self, font_path: str) -> None:
        ...

    def __eq__(self, other) -> bool:
        ...

    def __hash__(self) -> int:
        ...


class TextNode(NodeBase):
    def __init__(
        self, *,
        position: Vector = Vector(0, 0),
        rotation: float = 0,
        rotation_degrees: float = 0,
        scale: Vector = Vector(1, 1),
        z_index: Optional[int] = None,
        color: Color = Color(0, 0, 0, 0),
        sprite: Optional[Sprite] = None,
        shape: Optional[AnyShape] = None,
        origin_alignment: Alignment = Alignment.center,
        lifetime: float = 0.,
        transition: AnyTransitionArgument = None,
        transformation: Transformation = Transformation(),
        visible: bool = True,
        views: Optional[Set[int]] = None,
        indexable: bool = True,
        font: Font = ...,
        text: str = "",
        font_size: float = 28.,
        line_width: float = float('inf'),
        interline_spacing: float = 1.,
        first_line_indent: float = 0.,
    ) -> None:
        ...

    def setup(
        self, *,
        position: Vector = ...,
        rotation: float = ...,
        rotation_degrees: float = ...,
        scale: Vector = ...,
        z_index: Optional[int] = ...,
        color: Color = ...,
        sprite: Optional[Sprite] = ...,
        shape: Optional[AnyShape] = ...,
        origin_alignment: Alignment = ...,
        lifetime: float = ...,
        transition: AnyTransitionArgument = ...,
        transformation: Transformation = ...,
        visible: bool = ...,
        views: Optional[Set[int]] = ...,
        indexable: bool = ...,
        font: Font = ...,
        text: str = ...,
        font_size: float = ...,
        line_width: float = ...,
        interline_spacing: float = ...,
        first_line_indent: float = ...,
    ) -> None:
        ...

    def add_child(self, node: AnyNode) -> AnyNode:
        ...

    @property
    def first_line_indent(self) -> float:
        ...

    @first_line_indent.setter
    def first_line_indent(self, value: float) -> None:
        ...

    @property
    def font(self) -> Font:
        ...

    @font.setter
    def font(self, value: Font) -> None:
        ...

    @property
    def font_size(self) -> float:
        ...

    @font_size.setter
    def font_size(self, value: float) -> None:
        ...

    @property
    def interline_spacing(self) -> float:
        ...

    @interline_spacing.setter
    def interline_spacing(self, value: float) -> None:
        ...

    @property
    def line_width(self) -> float:
        ...

    @line_width.setter
    def line_width(self, value: float) -> None:
        ...

    @property
    def text(self) -> str:
        ...

    @text.setter
    def text(self, value: str) -> None:
        ...
