cdef extern from "extra/include/hashing.h" nogil:
    size_t c_calculate_hash "calculate_hash"[T](const T&)
