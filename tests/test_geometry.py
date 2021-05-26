import math

import pytest

from kaa.geometry import Vector, normalize_angle, normalize_angle_degrees, AngleSign


def test_vector():
    v1 = Vector.xy(1.)
    assert v1.x == 1. and v1.y == 1.
    v2 = Vector(2., 2.)
    assert v2.x == 2. and v2.y == 2.
    assert v1 == Vector(1., 1.)
    assert v2 == Vector(2., 2.)

    zero = Vector(0, 0)
    assert not zero
    assert zero.is_zero()

    assert v1 + v2 == Vector.xy(3)
    assert Vector.xy(3.) - v2 == v1
    assert v1 * 10 == Vector.xy(10.)
    assert Vector.xy(10.) / 10 == v1
    assert -v1 == Vector.xy(-1.)

    rotated_vector = Vector(1, 0).rotate_angle_degrees(90)
    assert pytest.approx(rotated_vector.x) == 0
    assert pytest.approx(rotated_vector.y) == 1.

    v = Vector.from_angle_degrees(90)
    assert pytest.approx(rotated_vector.x) == 0
    assert pytest.approx(rotated_vector.y) == 1.
    assert v.to_angle_degrees() == 90
    assert Vector(1., 0).angle_between_degrees(Vector(0, 1.)) == 90

    assert Vector(1., 0).normalize().dot(Vector(1, 1.).normalize()) > 0
    assert Vector(1., 0).normalize().dot(Vector(0, 1.).normalize()) == 0
    assert Vector(1., 0).normalize().dot(Vector(-1, 1.).normalize()) < 0

    assert Vector(0, 0).distance(Vector(10., 0)) == 10.

    v = Vector(10., 10.)
    assert v.normalize() == v / v.length()
    assert v.length() == math.sqrt(v.x ** 2 + v.y ** 2)


def test_normalize_angle_mixed():
    assert normalize_angle(math.pi) == -math.pi
    assert normalize_angle(math.pi, AngleSign.mixed) == -math.pi
    
    assert normalize_angle(-math.pi / 2, AngleSign.mixed) == -math.pi / 2
    assert normalize_angle(math.pi, AngleSign.mixed) == -math.pi


def test_normalize_angle_positive():
    assert normalize_angle(-math.pi / 4, AngleSign.positive) == 7 * math.pi / 4


def test_normalize_angle_negative():
    assert normalize_angle(math.pi / 4, AngleSign.negative) == -7 * math.pi / 4


def test_normalize_angle_degrees_mixed():
    assert normalize_angle_degrees(180.) == -180.
    assert normalize_angle_degrees(180., AngleSign.mixed) == -180.
    
    assert normalize_angle_degrees(-90., AngleSign.mixed) == -90.
    assert normalize_angle_degrees(180., AngleSign.mixed) == -180.


def test_normalize_angle_degrees_positive():
    assert normalize_angle_degrees(-45., AngleSign.positive) == 315.


def test_normalize_angle_degrees_negative():
    assert normalize_angle_degrees(45., AngleSign.negative) == -315.
