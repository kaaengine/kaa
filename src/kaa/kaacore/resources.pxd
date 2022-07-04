from libcpp cimport bool
from libcpp.memory cimport shared_ptr
from .exceptions cimport raise_py_error


cdef extern from "kaacore/resources.h" namespace "kaacore" nogil:

    cdef cppclass CResourceReference "kaacore::ResourceReference"[T]:
        shared_ptr[T] res_ptr

        CResourceReference()
        CResourceReference(const shared_ptr[T]& ptr)
        bool operator bool()
        bool operator==(const CResourceReference[T]& other)
        T* get "get_valid"() except +raise_py_error
