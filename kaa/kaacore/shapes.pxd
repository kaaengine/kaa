from libcpp.vector cimport vector

from .vectors cimport CVec2


cdef extern from "kaacore/shape.h" nogil:
    cdef enum CShapeType "kaacore::ShapeType":
        none "kaacore::ShapeType::none",
        segment "kaacore::ShapeType::segment",
        circle "kaacore::ShapeType::circle",
        polygon "kaacore::ShapeType::polygon",
        freeform "kaacore::ShapeType::freeform",

    cdef cppclass CShape "kaacore::Shape":
        CShapeType type
        vector[CVec2] points
        double radius

        CShape()

        @staticmethod
        CShape Segment(const CVec2 a, const CVec2 b)

        @staticmethod
        CShape Circle(const CVec2 center, const double radius)

        @staticmethod
        CShape Box(const CVec2 size)

        @staticmethod
        CShape Polygon(const vector[CVec2]& points)
