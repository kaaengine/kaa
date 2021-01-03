from libcpp.vector cimport vector
from libcpp cimport bool

from .vectors cimport CDVec2
from .geometry cimport CTransformation, CBoundingBox
from .exceptions cimport raise_py_error


cdef extern from "kaacore/shapes.h" namespace "kaacore" nogil:
    cdef enum CShapeType "kaacore::ShapeType":
        none "kaacore::ShapeType::none",
        segment "kaacore::ShapeType::segment",
        circle "kaacore::ShapeType::circle",
        polygon "kaacore::ShapeType::polygon",
        freeform "kaacore::ShapeType::freeform",

    cdef cppclass CShape "kaacore::Shape":
        CShapeType type
        vector[CDVec2] points
        double radius

        CShape()

        bool operator==(const CShape&)
        bool operator bool()

        @staticmethod
        CShape Segment(const CDVec2 a, const CDVec2 b) \
            except +raise_py_error

        @staticmethod
        CShape Circle(const double radius, const CDVec2 center) \
            except +raise_py_error

        @staticmethod
        CShape Box(const CDVec2 size) \
            except +raise_py_error

        @staticmethod
        CShape Polygon(const vector[CDVec2]& points) \
            except +raise_py_error

        CShape transform(const CTransformation& transformation) \
            except +raise_py_error

        CBoundingBox bounding_box() except +raise_py_error
