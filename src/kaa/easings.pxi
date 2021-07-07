from collections import abc

from .kaacore.easings cimport CEasing, c_ease, c_ease_between


class Easing(IntEnum):
    none = <uint8_t>CEasing.none
    back_in = <uint8_t>CEasing.back_in
    back_in_out = <uint8_t>CEasing.back_in_out
    back_out = <uint8_t>CEasing.back_out
    bounce_in = <uint8_t>CEasing.bounce_in
    bounce_in_out = <uint8_t>CEasing.bounce_in_out
    bounce_out = <uint8_t>CEasing.bounce_out
    circular_in = <uint8_t>CEasing.circular_in
    circular_in_out = <uint8_t>CEasing.circular_in_out
    circular_out = <uint8_t>CEasing.circular_out
    cubic_in = <uint8_t>CEasing.cubic_in
    cubic_in_out = <uint8_t>CEasing.cubic_in_out
    cubic_out = <uint8_t>CEasing.cubic_out
    elastic_in = <uint8_t>CEasing.elastic_in
    elastic_in_out = <uint8_t>CEasing.elastic_in_out
    elastic_out = <uint8_t>CEasing.elastic_out
    exponential_in = <uint8_t>CEasing.exponential_in
    exponential_in_out = <uint8_t>CEasing.exponential_in_out
    exponential_out = <uint8_t>CEasing.exponential_out
    quadratic_in = <uint8_t>CEasing.quadratic_in
    quadratic_in_out = <uint8_t>CEasing.quadratic_in_out
    quadratic_out = <uint8_t>CEasing.quadratic_out
    quartic_in = <uint8_t>CEasing.quartic_in
    quartic_in_out = <uint8_t>CEasing.quartic_in_out
    quartic_out = <uint8_t>CEasing.quartic_out
    quintic_in = <uint8_t>CEasing.quintic_in
    quintic_in_out = <uint8_t>CEasing.quintic_in_out
    quintic_out = <uint8_t>CEasing.quintic_out
    sine_in = <uint8_t>CEasing.sine_in
    sine_in_out = <uint8_t>CEasing.sine_in_out
    sine_out = <uint8_t>CEasing.sine_out


def ease(object easing, double progress):
    return c_ease(<CEasing>(<uint8_t>easing.value), progress)


def ease_between(object easing, double progress, a, b):
    if isinstance(a, (int, float)):
        assert isinstance(b, (int, float)), \
            "`a` is a number, `b` must have the same type."
        return c_ease_between[double](
            <CEasing>(<uint8_t>easing.value),
            progress, a, b
        )

    if isinstance(a, Vector):
        assert isinstance(b, Vector), \
            "`a` is a Vector, `b` must have the same type."
        return Vector.from_c_vector(c_ease_between[CDVec2](
            <CEasing>(<uint8_t>easing.value),
            progress,
            (<Vector>a).c_vector,
            (<Vector>b).c_vector
        ))

    if isinstance(a, Color):
        assert isinstance(b, Color), \
            "`a` is a Color, `b` must have the same type."
        return Color(
            r=min(1., max(0., ease_between(easing, progress, a.r, b.r))),
            g=min(1., max(0., ease_between(easing, progress, a.g, b.g))),
            b=min(1., max(0., ease_between(easing, progress, a.b, b.b))),
            a=min(1., max(0., ease_between(easing, progress, a.a, b.a))),
        )

    if isinstance(a, abc.Sequence):
        assert isinstance(b, abc.Sequence), \
            "`a` is a `abc.Sequence`, `b` must have the same type."
        assert len(a) == len(b), \
            "Sequences `a` ({}) and `b` ({}) must have the same length.".format(
                len(a), len(b),
            )
        return tuple(
            ease_between(easing, progress, a_elem, b_elem)
            for a_elem, b_elem in zip(a, b)
        )

    raise TypeError(
        'Unsupported type of parameters: {}'.format(type(a))
    )
