from libcpp cimport bool
from libcpp.vector cimport vector

from .nodes cimport CNodePtr
from .vectors cimport CDVec2
from .geometry cimport CBoundingBox
from .exceptions cimport raise_py_error


cdef extern from "kaacore/spatial_index.h" nogil:
    cdef cppclass CSpatialIndex "kaacore::SpatialIndex":
        vector[CNodePtr] query_bounding_box(const CBoundingBox& bbox, bool include_shapeless) \
            except +raise_py_error
        vector[CNodePtr] query_point(const CDVec2 point) \
            except +raise_py_error
