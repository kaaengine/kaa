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
        double& operator[](size_t)

    CVector CVector_normalize "glm::normalize" (CVector& v)
    double CVector_dot "glm::dot" (CVector& v1, CVector& v2)
    double CVector_distance "glm::distance" (CVector& v1, CVector& v2)
    double CVector_length "glm::length" (CVector& v)

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


cdef extern from "glm/gtx/rotate_vector.hpp" nogil:
    CVector CVector_rotate_angle "glm::rotate" (CVector& v, double angle)


cdef extern from "glm/gtx/vector_angle.hpp" nogil:
    double CVector_oriented_angle "glm::orientedAngle" (CVector& v1, CVector& c2)
