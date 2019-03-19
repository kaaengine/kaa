cdef extern from "glm/glm.hpp" nogil:
    cdef cppclass CVec2 "glm::dvec2":
        double x
        double y

        CVec2()
        CVec2(double x, double y)
        bint operator==(CVec2, CVec2)
        CVec2 operator*(CVec2, double)
        CVec2 operator+(CVec2, CVec2)
        CVec2 operator-(CVec2, CVec2)


    cdef cppclass CColor "glm::dvec4":
        double r
        double g
        double b
        double a

        CColor()
        CColor(double r, double g, double b, double a)
        bint operator==(CColor, CColor)
