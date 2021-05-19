from libc.stdint cimport int32_t, uint32_t


cdef extern from "glm/glm.hpp" nogil:
    cdef cppclass CDVec2 "glm::dvec2":
        double x
        double y

        CDVec2()
        CDVec2(double x, double y)
        bint operator==(CDVec2, CDVec2)
        CDVec2 operator*(CDVec2, double)
        CDVec2 operator+(CDVec2, CDVec2)
        CDVec2 operator-(CDVec2, CDVec2)
        double& operator[](size_t)

    CDVec2 c_vector_normalize "glm::normalize" (CDVec2& v)
    double c_vector_dot "glm::dot" (CDVec2& v1, CDVec2& v2)
    double c_vector_distance "glm::distance" (CDVec2& v1, CDVec2& v2)
    double c_vector_length "glm::length" (CDVec2& v)

    cdef cppclass CIVec2 "glm::ivec2":
        int32_t x
        int32_t y

        CIVec2()
        CIVec2(int32_t x, int32_t y)

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

    cdef cppclass CFVec3 "glm::fvec3":
        float x
        float y
        float z

        CFVec3()
        CFVec3(float x, float y, float z)
        float& operator[](int32_t i)

    cdef cppclass CFVec4 "glm::fvec4":
        float x
        float y
        float z
        float w

        CFVec4()
        CFVec4(float x, float y, float z, float w)
        float& operator[](int32_t i)

    cdef cppclass CFMat3 "glm::fmat3":
        CFMat3()
        CFMat3(float scalar)
        CFMat3(
            float x0, float y0, float z0,
			float x1, float y1, float z1,
			float x2, float y2, float z2
        )
        CFMat3(CFVec3 v0, CFVec3 v1, CFVec3 v2)
        CFVec3& operator[](int32_t i)

    cdef cppclass CFMat4 "glm::fmat4":
        CFMat4()
        CFMat4(float scalar)
        CFMat4(
            float x0, float y0, float z0, float w0,
			float x1, float y1, float z1, float w1,
			float x2, float y2, float z2, float w2,
			float x3, float y3, float z3, float w3
        )
        CFMat4(CFVec4 v0, CFVec4 v1, CFVec4 v2, CFVec4 v3)
        CFVec4& operator[](int32_t i)


cdef extern from "glm/gtx/rotate_vector.hpp" nogil:
    CDVec2 c_vector_rotate_angle "glm::rotate" (CDVec2& v, double angle)


cdef extern from "glm/gtx/vector_angle.hpp" nogil:
    double c_vector_oriented_angle "glm::orientedAngle" (CDVec2& v1, CDVec2& c2)
