import enum
from typing import overload

from .geometry import Vector


class Easing(enum.IntEnum):
    none: Easing
    back_in: Easing
    back_in_out: Easing
    back_out: Easing
    bounce_in: Easing
    bounce_in_out: Easing
    bounce_out: Easing
    circular_in: Easing
    circular_in_out: Easing
    circular_out: Easing
    cubic_in: Easing
    cubic_in_out: Easing
    cubic_out: Easing
    elastic_in: Easing
    elastic_in_out: Easing
    elastic_out: Easing
    exponential_in: Easing
    exponential_in_out: Easing
    exponential_out: Easing
    quadratic_in: Easing
    quadratic_in_out: Easing
    quadratic_out: Easing
    quartic_in: Easing
    quartic_in_out: Easing
    quartic_out: Easing
    quintic_in: Easing
    quintic_in_out: Easing
    quintic_out: Easing
    sine_in: Easing
    sine_in_out: Easing
    sine_out: Easing


def ease(easing: Easing, progress: float) -> float:
    ...


@overload
def ease_between(easing: Easing, progress: float, a: float, b: float) -> float:
    ...


@overload
def ease_between(easing: Easing, progress: float, a: Vector, b: Vector) -> Vector:
    ...
