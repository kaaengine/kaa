cdef extern from "glm/glm.hpp" namespace "glm" nogil:
    cdef cppclass CVec2 "glm::dvec2":
        double x
        double y

        CVec2()
        CVec2(double x, double y)
        bint operator==(CVec2, CVec2)
