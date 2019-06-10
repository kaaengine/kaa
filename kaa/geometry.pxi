from enum import IntEnum

from libc.stdint cimport uint32_t
from libcpp.vector cimport vector

from .kaacore.vectors cimport CVector
from .kaacore.geometry cimport CPolygonType, c_classify_polygon


class PolygonType(IntEnum):
    convex_cw = <uint32_t>CPolygonType.convex_cw
    convex_ccw = <uint32_t>CPolygonType.convex_ccw
    not_convex = <uint32_t>CPolygonType.not_convex


def classify_polygon(points):
    cdef vector[CVector] c_points
    c_points.reserve(len(points))
    for pt in points:
        c_points.push_back((<Vector>pt).c_vector)
    return PolygonType(<uint32_t>c_classify_polygon(c_points))
