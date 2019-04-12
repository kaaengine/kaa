from libc.stdint cimport int32_t


cdef extern from "glm/glm.hpp" nogil:
    cdef cppclass CIVector "glm::ivec2":
        int32_t x
        int32_t y

        CIVector()
        CIVector(int32_t x, int32_t y)
        bint operator==(CIVector, CIVector)
        CVector operator*(CIVector, int32_t)
        CVector operator+(CIVector, CIVector)
        CVector operator-(CIVector, CIVector)


    cdef cppclass CVector "glm::dvec2":
        double x
        double y

        CVector()
        CVector(double x, double y)
        bint operator==(CVector, CVector)
        CVector operator*(CVector, double)
        CVector operator+(CVector, CVector)
        CVector operator-(CVector, CVector)


    cdef cppclass CColor "glm::dvec4":
        double r
        double g
        double b
        double a

        CColor()
        CColor(double r, double g, double b, double a)
        bint operator==(CColor, CColor)
