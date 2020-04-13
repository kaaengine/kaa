
from .vectors cimport CVector
from .exceptions cimport raise_py_error


cdef extern from "kaacore/camera.h" nogil:
    cdef cppclass CCamera "kaacore::Camera":
        CVector position()
        void position(const CVector&)
        double rotation()
        void rotation(const double)
        CVector scale()
        void scale(const CVector&)
        CVector unproject_position(const CVector& pos) except +raise_py_error