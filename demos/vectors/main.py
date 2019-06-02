from kaa.geometry import Vector


def fmt_print(txt, *args):
    print(txt.format(*args) + "\n")


if __name__ == '__main__':
    v0 = Vector(0., 0.)
    v1 = Vector(2., 3.)
    v2 = Vector(1., -5.)
    m = 2.5
    a_deg = 90

    fmt_print("bool({})\n --> {}", v0, bool(v0))
    fmt_print("bool({})\n --> {}", v1, bool(v1))
    fmt_print("{} == {}\n --> {}", v1, v2, v1 == v2)
    fmt_print("{} == {}\n --> {}", v1, v1, v1 == v1)
    fmt_print("{} + {}\n --> {}", v1, v2, v1 + v2)
    fmt_print("{} - {}\n --> {}", v1, v2, v1 - v2)
    fmt_print("{} * {}\n --> {}", v1, m, v1 * m)
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
              v2, v2.to_angle_degrees())
