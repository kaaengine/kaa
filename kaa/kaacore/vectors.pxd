from libc.stdint cimport uint32_t


cdef extern from "glm/glm.hpp" nogil:
    cdef cppclass CVector "glm::dvec2":
        double x
        double y

        CVector()
        CVector(double x, double y)
        bint operator==(CVector, CVector)
        CVector operator*(CVector, double)
        CVector operator+(CVector, CVector)
        CVector operator-(CVector, CVector)

    cdef cppclass CUVec2 "glm::uvec2":
        uint32_t x
        uint32_t y

        CUVec2()
        CUVec2(uint32_t x, uint32_t y)


    cdef cppclass CColor "glm::dvec4":
        double r
        double g
        double b
        double a

        CColor()
        CColor(double r, double g, double b, double a)
        bint operator==(CColor, CColor)
