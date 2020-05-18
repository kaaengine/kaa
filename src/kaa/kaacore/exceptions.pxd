from cpython.ref cimport PyObject


cdef extern from "extra/include/python_exceptions_wrapper.h":
    void raise_py_error()
    void setup_kaacore_error_class(PyObject* py_kaacore_exception)
