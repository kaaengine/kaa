from libcpp cimport bool


cdef extern from "<optional>" namespace "std" nogil:
    cdef cppclass nullopt_t:
        nullopt_t()

    cdef nullopt_t nullopt

    cdef cppclass optional[T]:
        ctypedef T value_type

        optional()
        optional(nullopt_t)
        optional(optional&) except +
        optional(T&) except +
        optional& operator=(optional&)
        optional& operator=[U](U&)

        T& value()
        T& value_or[U](U& default_value)
        void swap(optional&)
        void reset()
        T& emplace(...)
        T& operator*()

        bool has_value()
        bool operator bool()
        bool operator!()
        bool operator==[U](optional&, U&)
        bool operator!=[U](optional&, U&)
        bool operator<[U](optional&, U&)
        bool operator>[U](optional&, U&)
        bool operator<=[U](optional&, U&)
        bool operator>=[U](optional&, U&)

    optional[T] make_optional[T](...) except +
