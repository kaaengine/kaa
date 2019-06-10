from libcpp.vector cimport vector

from .vectors cimport CVector


cdef extern from "kaacore/geometry.h" nogil:
    cdef enum CPolygonType "kaacore::PolygonType":
        convex_cw "kaacore::PolygonType::convex_cw",
        convex_ccw "kaacore::PolygonType::convex_ccw",
        not_convex "kaacore::PolygonType::not_convex",

    CPolygonType c_classify_polygon "kaacore::classify_polygon"(const vector[CVector]& points)
