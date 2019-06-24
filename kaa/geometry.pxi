from enum import IntEnum

from libc.stdint cimport uint32_t
from libcpp.vector cimport vector

from .kaacore.vectors cimport CVector
from .kaacore.geometry cimport CPolygonType, CAlignment, c_classify_polygon


class PolygonType(IntEnum):
    convex_cw = <uint32_t>CPolygonType.convex_cw
    convex_ccw = <uint32_t>CPolygonType.convex_ccw
    not_convex = <uint32_t>CPolygonType.not_convex


class Alignment(IntEnum):
    none = <uint32_t>CAlignment.none
    top = <uint32_t>CAlignment.top
    bottom = <uint32_t>CAlignment.bottom
    left = <uint32_t>CAlignment.left
    right = <uint32_t>CAlignment.right
    top_left = <uint32_t>CAlignment.top_left
    bottom_left = <uint32_t>CAlignment.bottom_left
    top_right = <uint32_t>CAlignment.top_right
    bottom_right = <uint32_t>CAlignment.bottom_right
    center = <uint32_t>CAlignment.center


def classify_polygon(points):
    cdef vector[CVector] c_points
    c_points.reserve(len(points))
    for pt in points:
        c_points.push_back((<Vector>pt).c_vector)
    return PolygonType(<uint32_t>c_classify_polygon(c_points))
