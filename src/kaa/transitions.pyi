import enum

from typing import final, type_check_only, Callable, List, TypeVar

from .colors import Color
from .easings import Easing
from .geometry import Vector
from .nodes import Node
from .sprites import Sprite


class AttributeTransitionMethod(enum.IntEnum):
    add: AttributeTransitionMethod
    multiply: AttributeTransitionMethod
    set: AttributeTransitionMethod


@type_check_only
class NodeTransitionBase:
    ...


@type_check_only
@final
class UnknownTransition(NodeTransitionBase):
    ...


@final
class NodePositionTransition(NodeTransitionBase):
    def __init__(
        self, value_advance: Vector, duration: float,
        *,
        advance_method: AttributeTransitionMethod = AttributeTransitionMethod.set,
        loops: int = 1, back_and_forth: bool = False,
        easing: Easing = Easing.none,
    ) -> None:
        ...


@final
class NodeRotationTransition(NodeTransitionBase):
    def __init__(
        self, value_advance: float, duration: float,
        *,
        advance_method: AttributeTransitionMethod = AttributeTransitionMethod.set,
        loops: int = 1, back_and_forth: bool = False,
        easing: Easing = Easing.none,
    ) -> None:
        ...


@final
class NodeScaleTransition(NodeTransitionBase):
    def __init__(
        self, value_advance: Vector, duration: float,
        *,
        advance_method: AttributeTransitionMethod = AttributeTransitionMethod.set,
        loops: int = 1, back_and_forth: bool = False,
        easing: Easing = Easing.none,
    ) -> None:
        ...


@final
class NodeColorTransition(NodeTransitionBase):
    def __init__(
        self, value_advance: Color, duration: float,
        *,
        advance_method: AttributeTransitionMethod = AttributeTransitionMethod.set,
        loops: int = 1, back_and_forth: bool = False,
        easing: Easing = Easing.none,
    ) -> None:
        ...


@final
class BodyNodeVelocityTransition(NodeTransitionBase):
    def __init__(
        self, value_advance: Vector, duration: float,
        *,
        advance_method: AttributeTransitionMethod = AttributeTransitionMethod.set,
        loops: int = 1, back_and_forth: bool = False,
        easing: Easing = Easing.none,
    ) -> None:
        ...


@final
class BodyNodeAngularVelocityTransition(NodeTransitionBase):
    def __init__(
        self, value_advance: float, duration: float,
        *,
        advance_method: AttributeTransitionMethod = AttributeTransitionMethod.set,
        loops: int = 1, back_and_forth: bool = False,
        easing: Easing = Easing.none,
    ) -> None:
        ...


@final
class NodeSpriteTransition(NodeTransitionBase):
    def __init__(
        self, sprites: List[Sprite], duration: float,
        *,
        loops: int = 1, back_and_forth: bool = False,
        easing: Easing = Easing.none,
    ) -> None:
        ...


@final
class NodeZIndexSteppingTransition(NodeTransitionBase):
    def __init__(
        self, z_indices: List[int], duration: float,
        *,
        loops: int = 1, back_and_forth: bool = False,
        easing: Easing = Easing.none,
    ) -> None:
        ...


@final
class NodeTransitionDelay(NodeTransitionBase):
    def __init__(self, duration: float):
        ...


@final
class NodeTransitionsSequence(NodeTransitionBase):
    def __init__(
        self, sub_transitions: List[NodeTransitionBase],
        *,
        loops: int = 1, back_and_forth: bool = False,
    ) -> None:
        ...


@final
class NodeTransitionsParallel(NodeTransitionBase):
    def __init__(
        self, sub_transitions: List[NodeTransitionBase],
        *,
        loops: int = 1, back_and_forth: bool = False,
    ) -> None:
        ...


@final
class NodeTransitionCallback(NodeTransitionBase):
    def __init__(self, callback_func: Callable[[Node], None]):
        ...


CustomTransitionStateType = TypeVar('CustomTransitionStateType')


@final
class NodeCustomTransition(NodeTransitionBase):
    def __init__(
        self, prepare_func: Callable[[Node], CustomTransitionStateType],
        evaluate_func: Callable[[CustomTransitionStateType, Node, float], None],
        duration: float,
        *,
        loops: int = 1, back_and_forth: bool = False,
        easing: Easing = Easing.none,
    ) -> None:
        ...


def NodeTransition(attribute, *args, **kwargs):
    ...  # TODO


@type_check_only
class NodeTransitionsManager:
    def get(self, transition_name: str) -> NodeTransitionBase:
        ...

    def set(self, transition_name: str, transition: NodeTransitionBase) -> None:
        ...
