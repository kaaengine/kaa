from libcpp.vector cimport vector

from .vectors cimport CVector


cdef extern from "kaacore/shapes.h" nogil:
    cdef enum CShapeType "kaacore::ShapeType":
        none "kaacore::ShapeType::none",
        segment "kaacore::ShapeType::segment",
        circle "kaacore::ShapeType::circle",
        polygon "kaacore::ShapeType::polygon",
        freeform "kaacore::ShapeType::freeform",

    cdef cppclass CShape "kaacore::Shape":
        CShapeType type
        vector[CVector] points
        double radius

        CShape()

        @staticmethod
        CShape Segment(const CVector a, const CVector b)

        @staticmethod
        CShape Circle(const double radius, const CVector center)

        @staticmethod
        CShape Box(const CVector size)

        @staticmethod
        CShape Polygon(const vector[CVector]& points)
