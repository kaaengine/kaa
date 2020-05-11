from cpython.ref cimport PyObject

from libcpp cimport bool


cdef extern from "extra/include/python_exceptions_wrapper.h":
    cdef cppclass CPythonException "PythonException":
        CPythonException() nogil
        void setup(PyObject* py_exception)
        bool operator bool()

    void c_throw_wrapped_python_exception \
        "throw_wrapped_python_exception"(CPythonException py_exception) nogil

    void raise_py_error()
    void setup_kaacore_error_class(PyObject* py_kaacore_exception)
