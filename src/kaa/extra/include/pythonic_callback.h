#pragma once

#include <functional>

#include <Python.h>

#include "kaacore/physics.h"
#include "kaacore/transitions.h"
#include "kaacore/node_ptr.h"
#include "kaacore/nodes.h"
#include "kaacore/timers.h"
#include "kaacore/input.h"
#include "kaacore/log.h"

#include "extra/include/python_exceptions_wrapper.h"

using namespace kaacore;


struct PythonicCallbackWrapper {
    PyObject* py_callback;
    bool is_weakref;

    PythonicCallbackWrapper()
        : py_callback(nullptr), is_weakref(false)
    {
        log<LogLevel::debug>("Creating empty PythonicCallbackWrapper.");
    }

    PythonicCallbackWrapper(PyObject* py_callback, bool is_weakref=false)
        : py_callback(py_callback), is_weakref(is_weakref)
    {
        log<LogLevel::debug>("Creating PythonicCallbackWrapper: %p.", py_callback);
        PyGILState_STATE gstate = PyGILState_Ensure();
        Py_INCREF(this->py_callback);
        PyGILState_Release(gstate);
    }

    PythonicCallbackWrapper(const PythonicCallbackWrapper& other)
    {
        PyGILState_STATE gstate = PyGILState_Ensure();
        this->py_callback = other.py_callback;
        this->is_weakref = other.is_weakref;
        log<LogLevel::debug>("Copying PythonicCallbackWrapper: %p.", this->py_callback);
        Py_INCREF(this->py_callback);
        PyGILState_Release(gstate);
    }

    PythonicCallbackWrapper(PythonicCallbackWrapper&& other)
        : py_callback(other.py_callback), is_weakref(other.is_weakref)
    {
        other.py_callback = nullptr;
        other.is_weakref = false;
        log<LogLevel::debug>("Moving PythonicCallbackWrapper: %p.", this->py_callback);
    }

    ~PythonicCallbackWrapper()
    {
        if (this->py_callback != nullptr) {
            PyGILState_STATE gstate = PyGILState_Ensure();
            Py_DECREF(this->py_callback);
            log<LogLevel::debug>(
                "Destroying PythonicCallbackWrapper: %p.", this->py_callback
            );
            PyGILState_Release(gstate);
        }
    }

    PythonicCallbackWrapper& operator=(const PythonicCallbackWrapper& other)
    {
        if (this == &other) {
            return *this;
        }

        if (this->py_callback != nullptr) {
            PyGILState_STATE gstate = PyGILState_Ensure();
            Py_DECREF(this->py_callback);
            PyGILState_Release(gstate);
        }

        this->py_callback = other.py_callback;
        this->is_weakref = other.is_weakref;
        if (this->py_callback) {
            PyGILState_STATE gstate = PyGILState_Ensure();
            Py_INCREF(this->py_callback);
            PyGILState_Release(gstate);
        }
        return *this;
    }

    PythonicCallbackWrapper& operator=(PythonicCallbackWrapper&& other)
    {
        if (this == &other) {
            return *this;
        }

        if (this->py_callback != nullptr) {
            PyGILState_STATE gstate = PyGILState_Ensure();
            Py_DECREF(this->py_callback);
            PyGILState_Release(gstate);
        }

        this->py_callback = other.py_callback;
        this->is_weakref = other.is_weakref;
        other.py_callback = nullptr;
        other.is_weakref = false;
        return *this;
    }
};



typedef int (*CythonCollisionHandler)(PythonException&, const PythonicCallbackWrapper&, Arbiter,
                                      CollisionPair, CollisionPair);


CollisionHandlerFunc bind_cython_collision_handler(
    const CythonCollisionHandler cy_handler, PythonicCallbackWrapper callback
)
{
    return [cy_handler, callback{std::move(callback)}]
            (Arbiter arbiter, CollisionPair cp1, CollisionPair cp2) -> int {
        PythonException python_exception;
        auto ret = cy_handler(python_exception, callback, arbiter, cp1, cp2);
        throw_wrapped_python_exception(python_exception);
        return ret;
    };
}

typedef void (*CythonTimerCallback)(PythonException&, const PythonicCallbackWrapper&);

TimerCallback bind_cython_timer_callback(
    const CythonTimerCallback cy_handler, PythonicCallbackWrapper callback
)
{
    return [cy_handler, callback{std::move(callback)}]() {
        PythonException python_exception;
        cy_handler(python_exception, callback);
        throw_wrapped_python_exception(python_exception);
    };
}


typedef void (*CythonNodeTransitionCallback)(PythonException&, const PythonicCallbackWrapper&, NodePtr);

NodeTransitionCallbackFunc bind_cython_transition_callback(
    const CythonNodeTransitionCallback cy_handler, PythonicCallbackWrapper callback
)
{
    return [cy_handler, callback{std::move(callback)}](NodePtr node_ptr) {
        PythonException python_exception;
        cy_handler(python_exception, callback, node_ptr);
        throw_wrapped_python_exception(python_exception);
    };
}

typedef int32_t (*CythonEventCallback)(PythonException&, const PythonicCallbackWrapper&, const Event&);

EventCallback bind_cython_event_callback(
    const CythonEventCallback cy_handler, PythonicCallbackWrapper callback
)
{
    return [cy_handler, callback{std::move(callback)}](const Event& event) -> int32_t {
        PythonException python_exception;
        auto ret = cy_handler(python_exception, callback, event);
        throw_wrapped_python_exception(python_exception);
        return ret;
    };
}
