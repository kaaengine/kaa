#pragma once

#include <functional>
#include <variant>

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


template <typename T>
class PythonicCallbackResult {
    // std::variant won't accept void as type, so we use std::monostate as "safe" type
    typedef std::conditional_t<std::is_void_v<T>, std::monostate, T> T_safe;

    public:
    PythonicCallbackResult()
    : _result()
    {
    }

    // disable constructor if T is void
    template <typename T_ = T,
              typename std::enable_if_t<not std::is_void_v<T_>, std::nullptr_t> = nullptr>
    PythonicCallbackResult(T_ res)
    : _result(res)
    {
    }

    PythonicCallbackResult(PyObject* exc_object)
    : _result(PythonException(exc_object))
    {
    }

    T unwrap_result() const
    {
        if (std::holds_alternative<PythonException>(this->_result)) {
            throw std::get<PythonException>(this->_result);
        }
        if constexpr (not std::is_void_v<T>) {
            return std::get<T>(this->_result);
        }
    }

    private:
    std::variant<T_safe, PythonException> _result;
};


typedef PythonicCallbackResult<int> (*CythonCollisionHandler)(const PythonicCallbackWrapper&, Arbiter,
                                     CollisionPair, CollisionPair);


CollisionHandlerFunc bind_cython_collision_handler(
    const CythonCollisionHandler cy_handler, PythonicCallbackWrapper callback
)
{
    return [cy_handler, callback{std::move(callback)}]
            (Arbiter arbiter, CollisionPair cp1, CollisionPair cp2) -> int {
        return cy_handler(callback, arbiter, cp1, cp2).unwrap_result();
    };
}


typedef PythonicCallbackResult<void> (*CythonTimerCallback)(const PythonicCallbackWrapper&);

TimerCallback bind_cython_timer_callback(
    const CythonTimerCallback cy_handler, PythonicCallbackWrapper callback
)
{
    return [cy_handler, callback{std::move(callback)}]() {
        std::move(cy_handler(callback)).unwrap_result();
    };
}


typedef PythonicCallbackResult<void> (*CythonNodeTransitionCallback)(const PythonicCallbackWrapper&, NodePtr);

NodeTransitionCallbackFunc bind_cython_transition_callback(
    const CythonNodeTransitionCallback cy_handler, PythonicCallbackWrapper callback
)
{
    return [cy_handler, callback{std::move(callback)}](NodePtr node_ptr) {
        cy_handler(callback, node_ptr).unwrap_result();
    };
}


typedef PythonicCallbackResult<int32_t> (*CythonEventCallback)(const PythonicCallbackWrapper&, const Event&);

EventCallback bind_cython_event_callback(
    const CythonEventCallback cy_handler, PythonicCallbackWrapper callback
)
{
    return [cy_handler, callback{std::move(callback)}](const Event& event) -> int32_t {
        return cy_handler(callback, event).unwrap_result();
    };
}

typedef PythonicCallbackResult<void> (*CythonVelocityUpdateCallback)(const PythonicCallbackWrapper&,
    Node*, glm::dvec2, double, double);

VelocityUpdateCallback bind_cython_update_velocity_callback(
    const CythonVelocityUpdateCallback cy_handler, PythonicCallbackWrapper callback
)
{
    return [cy_handler, callback{std::move(callback)}]
        (Node* node, glm::dvec2 gravity, double damping, double dt) -> void {
            return cy_handler(callback, node, gravity, damping, dt).unwrap_result();
    };
}

typedef PythonicCallbackResult<void> (*CythonPositionUpdateCallback)(const PythonicCallbackWrapper&, Node*, double);

PositionUpdateCallback bind_cython_update_position_callback(
    const CythonPositionUpdateCallback cy_handler, PythonicCallbackWrapper callback
)
{
    return [cy_handler, callback{std::move(callback)}](Node* node, double dt) -> void {
        return cy_handler(callback, node, dt).unwrap_result();
    };
}
