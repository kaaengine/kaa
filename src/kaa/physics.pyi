from __future__ import annotations

import enum
from typing import final, type_check_only, Callable, List, Optional, Set

from .colors import Color
from .geometry import AnyShape, Alignment, Transformation, Vector
from .nodes import NodeBase, AnyNode
from .sprites import Sprite
from .transitions import AnyTransitionArgument


COLLISION_BITMASK_ALL: int = ...
COLLISION_BITMASK_NONE: int = ...
COLLISION_GROUP_NONE: int = ...


class CollisionPhase(enum.IntFlag):
    begin: CollisionPhase
    post_solve: CollisionPhase
    pre_solve: CollisionPhase
    separate: CollisionPhase


class BodyNodeType(enum.IntEnum):
    dynamic: BodyNodeType
    kinematic: BodyNodeType
    static: BodyNodeType


@final
class CollisionPair:
    @property
    def body(self) -> Optional[BodyNode]:
        ...

    @property
    def hitbox(self) -> Optional[HitboxNode]:
        ...


@final
class CollisionContactPoint:
    @property
    def distance(self) -> float:
        ...

    @property
    def point_a(self) -> Vector:
        ...

    @point_a.setter
    def point_a(self, value: Vector) -> None:
        ...

    @property
    def point_b(self) -> Vector:
        ...

    @point_b.setter
    def point_b(self, value: Vector) -> None:
        ...


@type_check_only
class SpatialQueryResultBase:
    @property
    def body(self) -> Optional[BodyNode]:
        ...

    @property
    def hitbox(self) -> Optional[HitboxNode]:
        ...


@final
class ShapeQueryResult(SpatialQueryResultBase):
    @property
    def contact_points(self) -> List[CollisionContactPoint]:
        ...


@final
class RayQueryResult(SpatialQueryResultBase):
    @property
    def alpha(self) -> float:
        ...

    @property
    def normal(self) -> Vector:
        ...

    @property
    def point(self) -> Vector:
        ...


@final
class PointQueryResult(SpatialQueryResultBase):
    @property
    def distance(self) -> float:
        ...

    @property
    def point(self) -> Vector:
        ...


@final
class Arbiter:
    @property
    def phase(self) -> CollisionPhase:
        ...

    @property
    def space(self) -> SpaceNode:
        ...

    @property
    def first_contact(self) -> bool:
        ...

    @property
    def total_kinetic_energy(self) -> float:
        ...

    @property
    def total_impulse(self) -> Vector:
        ...

    @property
    def elasticity(self) -> float:
        ...

    @elasticity.setter
    def elasticity(self, value: float) -> None:
        ...

    @property
    def friction(self) -> float:
        ...

    @friction.setter
    def friction(self, value: float) -> None:
        ...

    @property
    def surface_velocity(self) -> Vector:
        ...

    @surface_velocity.setter
    def surface_velocity(self, value: Vector) -> None:
        ...

    @property
    def contact_points(self) -> List[CollisionContactPoint]:
        ...

    @contact_points.setter
    def contact_points(self, value: List[CollisionContactPoint]) -> None:
        ...

    @property
    def collision_normal(self) -> Vector:
        ...

    @collision_normal.setter
    def collision_normal(self, value: Vector) -> None:
        ...


class HitboxNode(NodeBase):
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
        trigger_id: int = 0,
        group: int = COLLISION_GROUP_NONE,
        mask: int = COLLISION_BITMASK_ALL,
        collision_mask: int = COLLISION_BITMASK_ALL,
        elasticity: float = 0.95,
        friction: float = 0,
        surface_velocity: Vector = Vector(0., 0.),
        sensor: bool = False,
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
        trigger_id: int = ...,
        group: int = ...,
        mask: int = ...,
        collision_mask: int = ...,
        elasticity: float = ...,
        friction: float = ...,
        surface_velocity: Vector = ...,
        sensor: bool = ...,
    ) -> None:
        ...

    def add_child(self, node: AnyNode) -> AnyNode:
        ...

    @property
    def collision_mask(self) -> int:
        ...

    @collision_mask.setter
    def collision_mask(self, value: int) -> None:
        ...

    @property
    def elasticity(self) -> float:
        ...

    @elasticity.setter
    def elasticity(self, value: float) -> None:
        ...

    @property
    def friction(self) -> float:
        ...

    @friction.setter
    def friction(self, value: float) -> None:
        ...

    @property
    def group(self) -> int:
        ...

    @group.setter
    def group(self, value: int) -> None:
        ...

    @property
    def mask(self) -> int:
        ...

    @mask.setter
    def mask(self, value: int) -> None:
        ...

    @property
    def sensor(self) -> bool:
        ...

    @sensor.setter
    def sensor(self, value: bool) -> None:
        ...

    @property
    def surface_velocity(self) -> Vector:
        ...

    @surface_velocity.setter
    def surface_velocity(self, value: Vector) -> None:
        ...

    @property
    def trigger_id(self) -> int:
        ...

    @trigger_id.setter
    def trigger_id(self, value: int) -> None:
        ...


class BodyNode(NodeBase):
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
        body_type: BodyNodeType = BodyNodeType.dynamic,
        force: Vector = Vector(0, 0),
        velocity: Vector = Vector(0, 0),
        mass: float = 20.0,
        moment: float = 10000.0,
        torque: float = 0,
        torque_degrees: float = 0,
        angular_velocity: float = 0,
        angular_velocity_degrees: float = 0,
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
        body_type: BodyNodeType = ...,
        force: Vector = ...,
        velocity: Vector = ...,
        mass: float = ...,
        moment: float = ...,
        torque: float = ...,
        torque_degrees: float = ...,
        angular_velocity: float = ...,
        angular_velocity_degrees: float = ...,
    ) -> None:
        ...

    def add_child(self, node: AnyNode) -> AnyNode:
        ...

    @property
    def angular_velocity(self) -> float:
        ...

    @angular_velocity.setter
    def angular_velocity(self, value: float) -> None:
        ...

    @property
    def angular_velocity_degrees(self) -> float:
        ...

    @angular_velocity_degrees.setter
    def angular_velocity_degrees(self, value: float) -> None:
        ...

    @property
    def body_type(self) -> BodyNodeType:
        ...

    @body_type.setter
    def body_type(self, value: BodyNodeType) -> None:
        ...

    @property
    def center_of_gravity(self) -> Vector:
        ...

    @center_of_gravity.setter
    def center_of_gravity(self, value: Vector) -> None:
        ...

    @property
    def damping(self) -> float:
        ...

    @damping.setter
    def damping(self, value: float) -> None:
        ...

    @property
    def force(self) -> Vector:
        ...

    @force.setter
    def force(self, value: Vector) -> None:
        ...

    @property
    def gravity(self) -> Vector:
        ...

    @gravity.setter
    def gravity(self, value: Vector) -> None:
        ...

    @property
    def local_force(self) -> Vector:
        ...

    @local_force.setter
    def local_force(self, value: Vector) -> None:
        ...

    @property
    def mass(self) -> float:
        ...

    @mass.setter
    def mass(self, value: float) -> None:
        ...

    @property
    def mass_inverse(self) -> float:
        ...

    @property
    def moment(self) -> float:
        ...

    @moment.setter
    def moment(self, value: float) -> None:
        ...

    @property
    def moment_inverse(self) -> float:
        ...

    @property
    def sleeping(self) -> bool:
        ...

    @sleeping.setter
    def sleeping(self, value: bool) -> None:
        ...

    @property
    def torque(self) -> float:
        ...

    @torque.setter
    def torque(self, value: float) -> None:
        ...

    @property
    def torque_degrees(self) -> float:
        ...

    @torque_degrees.setter
    def torque_degrees(self, value: float) -> None:
        ...

    @property
    def velocity(self) -> Vector:
        ...

    @velocity.setter
    def velocity(self, value: Vector) -> None:
        ...

    @property
    def _angular_velocity_bias(self) -> float:
        ...

    @_angular_velocity_bias.setter
    def _angular_velocity_bias(self, value: float) -> None:
        ...

    @property
    def _velocity_bias(self) -> Vector:
        ...

    @_velocity_bias.setter
    def _velocity_bias(self, value: Vector) -> None:
        ...

    def apply_force_at(self, force: Vector, at: Vector) -> None:
        ...

    def apply_force_at_local(self, force: Vector, at: Vector) -> None:
        ...

    def apply_impulse_at(self, force: Vector, at: Vector) -> None:
        ...

    def apply_impulse_at_local(self, force: Vector, at: Vector) -> None:
        ...

    def set_position_update_callback(
        self, callback: Callable[[BodyNode, float], None],
    ) -> None:
        ...

    def set_velocity_update_callback(
        self, callback: Callable[[BodyNode, Vector, float, float], None],
    ) -> None:
        ...


class SpaceNode(NodeBase):
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
        gravity: Vector = Vector(0, 0),
        damping: float = 1.,
        sleeping_threshold: float = float('inf'),
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
        gravity: Vector = ...,
        damping: float = ...,
        sleeping_threshold: float = ...,
    ) -> None:
        ...

    def add_child(self, node: AnyNode) -> AnyNode:
        ...

    @property
    def damping(self) -> float:
        ...

    @damping.setter
    def damping(self, damping_value: float) -> None:
        ...

    @property
    def gravity(self) -> Vector:
        ...

    @gravity.setter
    def gravity(self, gravity_value: Vector) -> None:
        ...

    @property
    def locked(self) -> bool:
        ...

    @property
    def sleeping_threshold(self) -> float:
        ...

    @sleeping_threshold.setter
    def sleeping_threshold(self, threshold_value: float) -> None:
        ...

    def query_point_neighbors(
        self, point: Vector, max_distance: float,
        *, mask: int = COLLISION_BITMASK_ALL,
        collision_mask: int = COLLISION_BITMASK_ALL,
        group: int = COLLISION_GROUP_NONE,
    ) -> PointQueryResult:
        ...

    def query_ray(
        self, ray_start: Vector, ray_end: Vector, radius: float = 0.,
        *, mask: int = COLLISION_BITMASK_ALL,
        collision_mask: int = COLLISION_BITMASK_ALL,
        group: int = COLLISION_GROUP_NONE,
    ) -> RayQueryResult:
        ...

    def query_shape_overlaps(
        self, shape: AnyShape,
        *, mask: int = COLLISION_BITMASK_ALL,
        collision_mask: int = COLLISION_BITMASK_ALL,
        group: int = COLLISION_GROUP_NONE,
    ) -> ShapeQueryResult:
        ...

    def set_collision_handler(
        self, trigger_a: int, trigger_b: int,
        handler: Callable[[Arbiter, CollisionPair, CollisionPair], Optional[bool]],
        phases_mask: CollisionPhase = ...,
        only_non_deleted_nodes: bool = True,
    ) -> None:
        ...
