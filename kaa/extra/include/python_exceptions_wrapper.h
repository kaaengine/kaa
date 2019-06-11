#include <exception>

#include <Python.h>

#include "kaacore/exceptions.h"


PyObject* _py_kaacore_exception;


struct PythonException : std::exception {
    PyObject* py_exception;

    PythonException(PyObject* py_exception)
    {
        KAACORE_ASSERT(PyGILState_Check());
        this->py_exception = py_exception;
        Py_INCREF(this->py_exception);
    };

    ~PythonException()
    {
        KAACORE_ASSERT(PyGILState_Check());
        Py_DECREF(this->py_exception);
    }

    PythonException(const PythonException& exc)
    {
        KAACORE_ASSERT(PyGILState_Check());
        this->py_exception = exc.py_exception;
        Py_INCREF(this->py_exception);
    }

    const char* what() const noexcept
    {
        return "PythonException";
    }
};


void wrap_python_exception(PyObject* py_exception)
{
    throw PythonException(py_exception);
}


void setup_kaacore_error_class(PyObject* py_kaacore_exception)
{
    ::_py_kaacore_exception = py_kaacore_exception;
}


void raise_py_error()
{
    try {
        throw;
    } catch (const PythonException& exc) {
        PyErr_SetObject(reinterpret_cast<PyObject*>(Py_TYPE(exc.py_exception)),
                        exc.py_exception);
    } catch (const kaacore::exception& exc) {
        PyErr_SetString(_py_kaacore_exception, exc.what());
    } catch (const std::exception& exc) {
        PyErr_SetString(PyExc_RuntimeError, exc.what());
    } catch (...) {
        PyErr_SetString(PyExc_RuntimeError, "Unknown exception");
    }
}
