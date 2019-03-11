from cpython.ref cimport PyObject

cdef extern from "kaacore_glue/pythonic_callback.h":
    cdef cppclass CPythonicCallbackWrapper "PythonicCallbackWrapper":
        PyObject* py_callback

        CPythonicCallbackWrapper(PyObject* py_callback)
        CPythonicCallbackWrapper(const CPythonicCallbackWrapper& wrapper)
