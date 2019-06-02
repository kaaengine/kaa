from cpython.ref cimport PyObject

cdef extern from "extra/include/pythonic_callback.h":
    cdef cppclass CPythonicCallbackWrapper "PythonicCallbackWrapper":
        PyObject* py_callback

        CPythonicCallbackWrapper(PyObject* py_callback)
        CPythonicCallbackWrapper(const CPythonicCallbackWrapper& wrapper)
