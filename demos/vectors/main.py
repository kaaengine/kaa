from kaa.geometry import Vector, classify_polygon, Transformation


def fmt_print(txt, *args):
    print(txt.format(*args) + "\n")


if __name__ == '__main__':
    v0 = Vector(0., 0.)
    v1 = Vector(2., 3.)
    v2 = Vector(1., -5.)
    v_up = Vector(0., -1.)
    v_down = Vector(0., 1.)
    m = 2.5
    a_deg = 90

    fmt_print("bool({})\n --> {}", v0, bool(v0))
    fmt_print("bool({})\n --> {}", v1, bool(v1))
    fmt_print("{} == {}\n --> {}", v1, v2, v1 == v2)
    fmt_print("{} == {}\n --> {}", v1, v1, v1 == v1)
    fmt_print("{} + {}\n --> {}", v1, v2, v1 + v2)
    fmt_print("{} - {}\n --> {}", v1, v2, v1 - v2)
    fmt_print("{} * {}\n --> {}", v1, m, v1 * m)
    fmt_print("{} / {}\n --> {}", v1, m, v1 / m)
    fmt_print("{} dot {}\n --> {}", v1, v2, v1.dot(v2))
    fmt_print("{} distance to {}\n --> {}", v1, v2, v1.distance(v2))
    fmt_print("negative {}\n --> {}", v1, -v1)
    fmt_print("normalized {}\n --> {}", v1, v1.normalize())
    fmt_print("length of {}\n --> {}", v1, v1.length())
    fmt_print("{} rotated by {} degrees\n --> {}",
              v1, a_deg, v1.rotate_angle_degrees(a_deg))
    fmt_print("vector from angle (degrees) {}\n --> {}",
              a_deg, Vector.from_angle_degrees(a_deg))
    fmt_print("vector {} to angle (degrees)\n --> {}",
              v1, v1.to_angle_degrees())
    fmt_print("vector {} to angle (degrees)\n --> {}",
              v2, v2.to_angle_degrees())
    fmt_print("vector {} to angle (degrees)\n --> {}",
              v_up, v_up.to_angle_degrees())
    fmt_print("vector {} to angle (degrees)\n --> {}",
              v_down, v_down.to_angle_degrees())

    points = [
        Vector(0., 0.), Vector(1., 0.), Vector(0., 1.)
    ]
    rev_points = list(reversed(points))
    points_invalid = [
        Vector(0., 0.), Vector(1., 1.), Vector(1., -1.),
        Vector(-1., -1.), Vector(-1., 1.)
    ]

    fmt_print("classification of polygon {}\n --> {!r}",
              points, classify_polygon(points))
    fmt_print("classification of polygon {}\n --> {!r}",
              rev_points, classify_polygon(rev_points))
    fmt_print("classification of polygon {}\n --> {!r}",
              points_invalid, classify_polygon(points_invalid))

    fmt_print("Transformation()\n --> {}", Transformation())
    fmt_print("Transformation.translate(Vector(20, -10))\n --> {}",
              Transformation.translate(Vector(20, -10)))
    fmt_print("Transformation.rotate_degrees(90)\n --> {}",
              Transformation.rotate_degrees(90))
    fmt_print("Transformation.scale(Vector(2, 2))\n --> {}",
              Transformation.translate(Vector(2, 2)))
    fmt_print("Transformation.translate(Vector(20, -10).inverse())\n --> {}",
              Transformation.translate(Vector(20, -10)).inverse())
    fmt_print("Transformation.scale(Vector(2, 2).inverse())\n --> {}",
              Transformation.translate(Vector(2, 2)).inverse())
    fmt_print("Transformation.translate(Vector(20, -10)) @ Transformation.scale(Vector(2, 2))\n --> {}",
              Transformation.translate(Vector(20, -10)) @ Transformation.scale(Vector(2, 2)))
    fmt_print("Transformation.scale(Vector(2, 2)) @ Transformation.translate(Vector(20, -10))\n --> {}",
              Transformation.scale(Vector(2, 2)) @ Transformation.translate(Vector(20, -10)))
    fmt_print("Transformation.scale(Vector(2, 2)) | Transformation.translate(Vector(20, -10))\n --> {}",
              Transformation.scale(Vector(2, 2)) | Transformation.translate(Vector(20, -10)))
    fmt_print("Vector(5, 5) | Transformation.translate(Vector(20, -10))\n --> {}",
              Vector(5, 5) | Transformation.translate(Vector(20, -10)))
    fmt_print("Vector(5, 5) | Transformation.scale(Vector(2, 2)) | Transformation.translate(Vector(20, -10))\n --> {}",
              Vector(5, 5) | Transformation.scale(Vector(2, 2)) | Transformation.translate(Vector(20, -10)))
