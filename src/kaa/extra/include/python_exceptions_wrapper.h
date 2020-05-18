#pragma once

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
    }

    ~PythonException()
    {
        if (this->py_exception != nullptr) {
            PyGILState_STATE gstate = PyGILState_Ensure();
            Py_DECREF(this->py_exception);
            PyGILState_Release(gstate);
        }
    }

    PythonException(const PythonException& exc)
    {
        this->py_exception = exc.py_exception;
        if (this->py_exception) {
            PyGILState_STATE gstate = PyGILState_Ensure();
            Py_INCREF(this->py_exception);
            PyGILState_Release(gstate);
        }
    }

    PythonException(PythonException&& exc)
    {
        this->py_exception = exc.py_exception;
        exc.py_exception = nullptr;
    }

    PythonException& operator=(const PythonException& other)
    {
        if (this->py_exception) {
            PyGILState_STATE gstate = PyGILState_Ensure();
            Py_DECREF(this->py_exception);
            PyGILState_Release(gstate);
        }

        this->py_exception = other.py_exception;
        if (this->py_exception) {
            PyGILState_STATE gstate = PyGILState_Ensure();
            Py_INCREF(this->py_exception);
            PyGILState_Release(gstate);
        }
    }

    PythonException& operator=(PythonException&& other)
    {
        if (this->py_exception) {
            PyGILState_STATE gstate = PyGILState_Ensure();
            Py_DECREF(this->py_exception);
            PyGILState_Release(gstate);
        }

        this->py_exception = other.py_exception;
        other.py_exception = nullptr;
    }

    const char* what() const noexcept
    {
        return "PythonException";
    }
};


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
