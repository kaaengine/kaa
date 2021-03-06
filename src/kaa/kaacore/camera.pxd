from .vectors cimport CDVec2
from .geometry cimport CBoundingBox
from .exceptions cimport raise_py_error


cdef extern from "kaacore/camera.h" namespace "kaacore" nogil:
    cdef cppclass CCamera "kaacore::Camera":
        CDVec2 position()
        void position(const CDVec2&)
        double rotation()
        void rotation(const double)
        CDVec2 scale()
        void scale(const CDVec2&)
        CDVec2 unproject_position(const CDVec2& pos) except +raise_py_error
        CBoundingBox visible_area_bounding_box()
