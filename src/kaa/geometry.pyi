from __future__ import annotations

import enum
from typing import (
    final, overload, type_check_only, List, Optional, Sequence, Union,
)


@final
class Vector:
    def __init__(self, x: float, y: float) -> None:
        ...

    @staticmethod
    def xy(xy: float) -> Vector:
        ...

    @classmethod
    def from_angle(cls, angle_rad: float) -> Vector:
        ...

    @classmethod
    def from_angle_degrees(cls, angle_deg: float) -> Vector:
        ...

    @property
    def x(self) -> float:
        ...

    @property
    def y(self) -> float:
        ...

    def add(self, other: Vector) -> Vector:
        ...

    def angle_between(self, other: Vector) -> float:
        ...

    def angle_between_degrees(self, other: Vector) -> float:
        ...

    def distance(self, other: Vector) -> float:
        ...

    def dot(self, other: Vector) -> float:
        ...

    def is_zero(self) -> bool:
        ...

    def length(self) -> float:
        ...

    def mul(self, value: float) -> Vector:
        ...

    def normalize(self) -> Vector:
        ...

    def rotate_angle(self, angle_rad: float) -> Vector:
        ...

    def rotate_angle_degrees(self, angle_deg: float) -> Vector:
        ...

    def sub(self, other: Vector) -> Vector:
        ...

    def to_angle(self) -> float:
        ...

    def to_angle_degrees(self) -> float:
        ...

    def transform(self, transformation: Transformation) -> Vector:
        ...

    def __add__(self, other: Vector) -> Vector:
        ...

    def __bool__(self) -> bool:
        ...

    def __eq__(self, other) -> bool:
        ...

    def __hash__(self) -> int:
        ...

    def __mul__(self, other: float) -> Vector:
        ...

    def __rmul__(self, other: float) -> Vector:
        ...

    def __neg__(self) -> Vector:
        ...

    def __or__(self, other: Transformation) -> Vector:
        ...

    def __sub__(self, other: Vector) -> Vector:
        ...

    def __truediv__(self, other: float) -> Vector:
        ...


@type_check_only
class ShapeBase:
    @property
    def bounding_box(self) -> BoundingBox:
        ...

    def transform(self, transformation: Transformation) -> ShapeBase:
        ...

    def __eq__(self, other) -> bool:
        ...

    def __hash__(self) -> int:
        ...

    def __or__(self, other: Transformation) -> ShapeBase:
        ...


@final
class Segment(ShapeBase):
    def __init__(self, a: Vector, b: Vector) -> None:
        ...

    @property
    def point_a(self) -> Vector:
        ...

    @property
    def point_b(self) -> Vector:
        ...


@final
class Circle(ShapeBase):
    def __init__(self, radius: float, center: Vector = Vector(0, 0)) -> None:
        ...

    @property
    def radius(self) -> float:
        ...

    @property
    def center(self) -> Vector:
        ...



@final
class Polygon(ShapeBase):
    def __init__(self, points: Sequence[Vector]) -> None:
        ...

    @staticmethod
    def from_box(size: Vector) -> Polygon:
        ...

    @property
    def points(self) -> List[Vector]:
        ...


AnyShape = Union[Segment, Circle, Polygon]


class PolygonType(enum.IntEnum):
    convex_ccw: PolygonType
    convex_cw: PolygonType
    not_convex: PolygonType


def classify_polygon(points: Sequence[Vector]) -> PolygonType:
    ...


class Alignment(enum.IntEnum):
    bottom: Alignment
    bottom_left: Alignment
    bottom_right: Alignment
    center: Alignment
    left: Alignment
    none: Alignment
    right: Alignment
    top: Alignment
    top_left: Alignment
    top_right: Alignment


@final
class Transformation:
    @overload
    def __init__(
        self, *, translate: Optional[Vector] = None,
        rotate: Optional[float] = None,
        scale: Optional[Vector] = None
    ) -> None:
        ...

    @overload
    def __init__(
        self, *, translate: Optional[Vector] = None,
        rotate_degrees: Optional[float] = None,
        scale: Optional[Vector] = None
    ) -> None:
        ...
    def decompose(self) -> DecomposedTransformation:
        ...

    def inverse(self) -> Transformation:
        ...

    def __eq__(self, other) -> bool:
        ...

    @overload
    def __matmul__(self, other_transformation: Transformation) -> Transformation:
        ...

    @overload
    def __matmul__(self, vector: Vector) -> Vector:
        ...

    @overload
    def __matmul__(self, shape: ShapeBase) -> ShapeBase:
        ...

    def __or__(self, other: Transformation) -> Transformation:
        ...


@type_check_only
class DecomposedTransformation:
    @property
    def rotation(self) -> float:
        ...

    @property
    def rotation_degrees(self) -> float:
        ...

    @property
    def scale(self) -> Vector:
        ...

    @property
    def translation(self) -> Vector:
        ...


@final
class BoundingBox:
    def __init__(self, min_x: float, min_y: float, max_x: float, max_y: float) -> None:
        ...

    @staticmethod
    def single_point(point: Vector) -> BoundingBox:
        ...

    @staticmethod
    def from_points(points: Sequence[Vector]) -> BoundingBox:
        ...

    @property
    def max_x(self) -> float:
        ...

    @property
    def max_y(self) -> float:
        ...

    @property
    def min_x(self) -> float:
        ...

    @property
    def min_y(self) -> float:
        ...

    @property
    def center(self) -> Vector:
        ...

    @property
    def dimensions(self) -> Vector:
        ...

    @property
    def is_nan(self) -> bool:
        ...

    @overload
    def contains(self, point: Vector) -> bool:
        ...

    @overload
    def contains(self, bounding_box: BoundingBox) -> bool:
        ...

    def grow(self, vector: Vector) -> BoundingBox:
        ...

    def intersection(self, bounding_box: BoundingBox) -> BoundingBox:
        ...

    def intersects(self, bounding_box: BoundingBox) -> BoundingBox:
        ...

    def merge(self, bounding_box: BoundingBox) -> BoundingBox:
        ...

    def __eq__(self, other) -> bool:
        ...

    def __hash__(self) -> int:
        ...


class AngleSign(enum.IntEnum):
    mixed: AngleSign
    positive: AngleSign
    negative: AngleSign


def normalize_angle(value: float, angle_sign: AngleSign = AngleSign.mixed) -> float:
    ...


def normalize_angle_degrees(
    value: float, angle_sign: AngleSign = AngleSign.mixed
) -> float:
    ...
