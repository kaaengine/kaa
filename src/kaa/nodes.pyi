from __future__ import annotations

from typing import Iterable, Optional, Set, TypeVar

from .colors import Color
from .sprites import Sprite
from .engine import AnyScene
from .materials import Material
from .geometry import AnyShape, Alignment, BoundingBox, Transformation, Vector
from .transitions import AnyTransition, AnyTransitionArgument, NodeTransitionsManager
from .stencil import StencilMode


class NodeBase:
    @property
    def absolute_position(self) -> Vector:
        ...

    @property
    def absolute_rotation(self) -> float:
        ...

    @property
    def absolute_rotation_degrees(self) -> float:
        ...

    @property
    def absolute_scale(self) -> Vector:
        ...

    @property
    def absolute_transformation(self) -> Transformation:
        ...

    @property
    def bounding_box(self) -> BoundingBox:
        ...

    @property
    def children(self) -> Iterable[AnyNode]:
        ...

    @property
    def color(self) -> Color:
        ...

    @color.setter
    def color(self, value: Color) -> None:
        ...

    @property
    def effective_viewports(self) -> Set[int]:
        ...

    @property
    def effective_render_passes(self) -> Set[int]:
        ...

    @property
    def effective_z_index(self) -> int:
        ...

    @property
    def indexable(self) -> bool:
        ...

    @indexable.setter
    def indexable(self, value: bool) -> None:
        ...

    @property
    def lifetime(self) -> float:
        ...

    @lifetime.setter
    def lifetime(self, value: float) -> None:
        ...

    @property
    def origin_alignment(self) -> Alignment:
        ...

    @origin_alignment.setter
    def origin_alignment(self, value: Alignment) -> None:
        ...

    @property
    def parent(self) -> Optional[AnyNode]:
        ...

    @property
    def position(self) -> Vector:
        ...

    @position.setter
    def position(self, value: Vector) -> None:
        ...

    @property
    def root_distance(self) -> int:
        ...

    @property
    def rotation(self) -> float:
        ...

    @rotation.setter
    def rotation(self, value: float) -> None:
        ...

    @property
    def rotation_degrees(self) -> float:
        ...

    @rotation_degrees.setter
    def rotation_degrees(self, value: float) -> None:
        ...

    @property
    def scale(self) -> Vector:
        ...

    @scale.setter
    def scale(self, value: Vector) -> None:
        ...

    @property
    def scene(self) -> Optional[AnyScene]:
        ...

    @property
    def shape(self) -> Optional[AnyShape]:
        ...

    @shape.setter
    def shape(self, value: Optional[AnyShape]) -> None:
        ...

    @property
    def sprite(self) -> Optional[Sprite]:
        ...

    @sprite.setter
    def sprite(self, value: Optional[Sprite]) -> None:
        ...

    @property
    def material(self) -> Optional[Material]:
        ...

    @material.setter
    def material(self, value: Optional[Material]):
        ...

    @property
    def transformation(self) -> Transformation:
        ...

    @transformation.setter
    def transformation(self, value: Transformation) -> None:
        ...

    @property
    def transition(self) -> Optional[AnyTransition]:
        ...

    @transition.setter
    def transition(self, value: AnyTransitionArgument) -> None:
        ...

    @property
    def transitions_manager(self) -> NodeTransitionsManager:
        ...

    @property
    def type(self) -> int:
        ...

    @property
    def viewports(self) -> Optional[Set[int]]:
        ...

    @viewports.setter
    def viewports(self, value: Optional[Set[int]]) -> None:
        ...

    @property
    def render_passes(self) -> Optional[Set[int]]:
        ...

    @render_passes.setter
    def render_passes(self, value: Optional[Set[int]]) -> None:
        ...

    @property
    def visible(self) -> bool:
        ...

    @visible.setter
    def visible(self, value: bool) -> None:
        ...

    @property
    def stencil_mode(self) -> Optional[StencilMode]:
        ...

    @stencil_mode.setter
    def stencil_mode(self, value: Optional[StencilMode]) -> None:
        ...

    @property
    def z_index(self) -> Optional[int]:
        ...

    @z_index.setter
    def z_index(self, value: Optional[int]) -> None:
        ...

    def delete(self) -> None:
        ...

    def get_relative_position(self, ancestor: NodeBase) -> Vector:
        ...

    def get_relative_transformation(self, ancestor: NodeBase) -> Transformation:
        ...

    def __bool__(self) -> bool:
        ...


class Node(NodeBase):
    def __init__(
        self, *,
        position: Vector = Vector(0, 0),
        rotation: float = 0,
        rotation_degrees: float = 0,
        scale: Vector = Vector(1, 1),
        z_index: Optional[int] = None,
        color: Color = Color(0, 0, 0, 0),
        sprite: Optional[Sprite] = None,
        material: Optional[Material] = None,
        shape: Optional[AnyShape] = None,
        origin_alignment: Alignment = Alignment.center,
        lifetime: float = 0.,
        transition: AnyTransitionArgument = None,
        transformation: Transformation = Transformation(),
        visible: bool = True,
        viewports: Optional[Set[int]] = None,
        render_passes: Optional[Set[int]] = None,
        indexable: bool = True,
        stencil_mode: Optional[StencilMode] = None,
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
        material: Optional[Material] = ...,
        shape: Optional[AnyShape] = ...,
        origin_alignment: Alignment = ...,
        lifetime: float = ...,
        transition: AnyTransitionArgument = ...,
        transformation: Transformation = ...,
        visible: bool = ...,
        viewports: Optional[Set[int]] = ...,
        render_passes: Optional[Set[int]] = ...,
        indexable: bool = ...,
        stencil_mode: Optional[StencilMode] = ...,
    ) -> None:
        ...

    def add_child(self, node: AnyNode) -> AnyNode:
        ...


AnyNode = TypeVar('AnyNode', bound=NodeBase)
