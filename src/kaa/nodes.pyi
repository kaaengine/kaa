from typing import Iterable, Optional, Set, Union

from .colors import Color
from .engine import Scene
from .fonts import TextNode
from .geometry import Alignment, BoundingBox, ShapeBase, Transformation, Vector
from .physics import SpaceNode
from .transitions import NodeTransitionBase, NodeTransitionsManager
from .sprites import Sprite


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
    def children(self) -> Iterable[NodeBase]:
        ...

    @property
    def color(self) -> Color:
        ...

    @color.setter
    def color(self, value: Color) -> None:
        ...

    @property
    def effective_views(self) -> Set[int]:
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
    def parent(self) -> Optional[NodeBase]:
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
    def scene(self) -> Optional[Scene]:
        ...

    @property
    def shape(self) -> Optional[ShapeBase]:
        ...

    @shape.setter
    def shape(self, value: Optional[ShapeBase]) -> None:
        ...

    @property
    def sprite(self) -> Optional[Sprite]:
        ...

    @sprite.setter
    def sprite(self, value: Optional[Sprite]) -> None:
        ...

    @property
    def transformation(self) -> Transformation:
        ...

    @transformation.setter
    def transformation(self, value: Transformation) -> None:
        ...

    @property
    def transition(self) -> Optional[NodeTransitionBase]:
        ...

    @transition.setter
    def transition(self, value: Optional[NodeTransitionBase]) -> None:
        ...

    @property
    def transitions_manager(self) -> NodeTransitionsManager:
        ...

    @property
    def type(self) -> int:
        ...

    @property
    def views(self) -> Optional[Set[int]]:
        ...

    @views.setter
    def views(self, value: Optional[Set[int]]) -> None:
        ...

    @property
    def visible(self) -> bool:
        ...

    @visible.setter
    def visible(self, value: bool) -> None:
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
        shape: Optional[ShapeBase] = None,
        origin_alignment: Alignment = Alignment.center,
        lifetime: float = 0.,
        transition: Optional[NodeTransitionBase] = None,
        transformation: Transformation = Transformation(),
        visible: bool = True,
        views: Optional[Set[int]] = None,
        indexable: bool = True,
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
        shape: Optional[ShapeBase] = ...,
        origin_alignment: Alignment = ...,
        lifetime: float = ...,
        transition: Optional[NodeTransitionBase] = ...,
        transformation: Transformation = ...,
        visible: bool = ...,
        views: Optional[Set[int]] = ...,
        indexable: bool = ...,
    ) -> None:
        ...

    def add_child(self, node: Union[Node, SpaceNode, TextNode]) -> NodeBase:
        ...
