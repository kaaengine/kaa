from libcpp.vector cimport vector
from libcpp cimport bool

from .vectors cimport CDVec2
from .exceptions cimport raise_py_error


cdef extern from "kaacore/geometry.h" namespace "kaacore" nogil:
    cdef enum CPolygonType "kaacore::PolygonType":
        convex_cw "kaacore::PolygonType::convex_cw",
        convex_ccw "kaacore::PolygonType::convex_ccw",
        not_convex "kaacore::PolygonType::not_convex",

    cdef enum CAlignment "kaacore::Alignment":
        none "kaacore::Alignment::none"
        top "kaacore::Alignment::top"
        bottom "kaacore::Alignment::bottom"
        left "kaacore::Alignment::left"
        right "kaacore::Alignment::right"
        top_left "kaacore::Alignment::top_left"
        bottom_left "kaacore::Alignment::bottom_left"
        top_right "kaacore::Alignment::top_right"
        bottom_right "kaacore::Alignment::bottom_right"
        center "kaacore::Alignment::center"

    cdef cppclass CDecomposedTransformation "kaacore::DecomposedTransformation<double>":
        CDVec2 translation
        double rotation
        CDVec2 scale

    cdef cppclass CTransformation "kaacore::Transformation":
        CTransformation()
        bint operator==(const CTransformation&)

        @staticmethod
        CTransformation translate(const CDVec2&) except +raise_py_error

        @staticmethod
        CTransformation scale(const CDVec2&) except +raise_py_error

        @staticmethod
        CTransformation rotate(const double&) except +raise_py_error

        CTransformation inverse() except +raise_py_error

        double at(const size_t col, const size_t row) except +raise_py_error
        CDecomposedTransformation decompose() except +raise_py_error

    CTransformation operator|(const CTransformation&, const CTransformation&) except +raise_py_error
    CDVec2 operator|(const CDVec2&, const CTransformation&) except +raise_py_error

    CPolygonType c_classify_polygon "kaacore::classify_polygon"(const vector[CDVec2]& points) \
        except +raise_py_error

    cdef cppclass CBoundingBox "kaacore::BoundingBox<double>":
        double min_x
        double min_y
        double max_x
        double max_y

        CBoundingBox()
        CBoundingBox(double min_x, double min_y, double max_x, double max_y)

        bool operator==(const CBoundingBox&)

        bool is_nan()
        CBoundingBox merge(const CBoundingBox& other)
        bool contains(const CDVec2 vector)
        bool contains(const CBoundingBox& bbox)
        bool intersects(const CBoundingBox& bbox)
        CBoundingBox intersection(const CBoundingBox& bbox)
        CBoundingBox grow(const CDVec2 vector)
        CDVec2 center()
        CDVec2 dimensions()

        @staticmethod
        CBoundingBox single_point(const CDVec2 point)

        @staticmethod
        CBoundingBox from_points(const vector[CDVec2]& points)
