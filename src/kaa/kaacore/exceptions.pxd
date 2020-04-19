from cpython.ref cimport PyObject


cdef extern from "extra/include/python_exceptions_wrapper.h":
    void c_wrap_python_exception "wrap_python_exception"(PyObject* py_exception)
    void raise_py_error()
    void setup_kaacore_error_class(PyObject* py_kaacore_exception)
