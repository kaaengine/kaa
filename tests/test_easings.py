import pytest

from kaa.easings import Easing, ease, ease_between
from kaa.geometry import Vector
from kaa.colors import Color


@pytest.mark.parametrize("easing", list(Easing))
def test_ease_edge_values_float(easing):
    assert ease(easing, 0.) == pytest.approx(0., abs=1e-3)
    assert ease(easing, 1.) == pytest.approx(1., abs=1e-3)


@pytest.mark.parametrize("easing", list(Easing))
def test_ease_between_edge_values_float(easing):
    assert ease_between(easing, 0., a=0., b=1.) == pytest.approx(0., abs=1e-3)
    assert ease_between(easing, 1., a=0., b=1.) == pytest.approx(1., abs=1e-3)


@pytest.mark.parametrize("easing", list(Easing))
def test_ease_between_edge_values_vector(easing):
    a, b = Vector.xy(0), Vector.xy(1)
    _to_tuple = lambda v: (v.x, v.y)

    assert (
        _to_tuple(ease_between(easing, 0., a=a, b=b))
        == pytest.approx(_to_tuple(a), abs=1e-3)
    )
    assert (
        _to_tuple(ease_between(easing, 1., a=a, b=b))
        == pytest.approx(_to_tuple(b), abs=1e-3)
    )


@pytest.mark.parametrize("easing", list(Easing))
def test_ease_between_edge_values_color(easing):
    a, b = Color(0., 0., 0., 0.), Color(1., 1., 1., 1.)
    _to_tuple = lambda c: (c.r, c.g, c.b, c.a)

    assert (
        _to_tuple(ease_between(easing, 0., a=a, b=b))
        == pytest.approx(_to_tuple(a), abs=1e-3)
    )
    assert (
        _to_tuple(ease_between(easing, 1., a=a, b=b))
        == pytest.approx(_to_tuple(b), abs=1e-3)
    )


@pytest.mark.parametrize("easing", list(Easing))
def test_ease_between_edge_values_tuple(easing):
    a, b = (0., 1.), (1., 0.)

    assert (
        ease_between(easing, 0., a=a, b=b)
        == pytest.approx(a, abs=1e-3)
    )
    assert (
        ease_between(easing, 1., a=a, b=b)
        == pytest.approx(b, abs=1e-3)
    )
