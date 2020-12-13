cdef extern from "<chrono>" namespace "std::chrono" nogil:
    cdef cppclass duration[Repr, Period=*]:
        duration()
        duration(Repr) except +

        Repr count()


cdef extern from "kaacore/clock.h" nogil:
    ctypedef duration[long double] CSeconds "kaacore::Seconds"
