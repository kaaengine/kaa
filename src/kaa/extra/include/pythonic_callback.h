#include <functional>

#include <Python.h>

#include "kaacore/physics.h"
#include "kaacore/transitions.h"
#include "kaacore/node_ptr.h"
#include "kaacore/nodes.h"
#include "kaacore/timers.h"
#include "kaacore/input.h"
#include "kaacore/log.h"

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
        Py_INCREF(this->py_callback);
    }

    PythonicCallbackWrapper(const PythonicCallbackWrapper& other)
    {
        this->py_callback = other.py_callback;
        this->is_weakref = other.is_weakref;
        log<LogLevel::debug>("Copying PythonicCallbackWrapper: %p.", this->py_callback);
        Py_INCREF(this->py_callback);
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
            Py_DECREF(this->py_callback);
            log<LogLevel::debug>(
                "Destroying PythonicCallbackWrapper: %p.", this->py_callback
            );
        }
    }

    PythonicCallbackWrapper& operator=(const PythonicCallbackWrapper& other)
    {
        if (this == &other) {
            return *this;
        }

        if (this->py_callback != nullptr) {
            Py_DECREF(this->py_callback);
        }

        this->py_callback = other.py_callback;
        this->is_weakref = other.is_weakref;
        Py_INCREF(this->py_callback);
        return *this;
    }

    PythonicCallbackWrapper& operator=(PythonicCallbackWrapper&& other)
    {
        if (this == &other) {
            return *this;
        }

        if (this->py_callback != nullptr) {
            Py_DECREF(this->py_callback);
        }

        this->py_callback = other.py_callback;
        this->is_weakref = other.is_weakref;
        other.py_callback = nullptr;
        other.is_weakref = false;
        return *this;
    }
};


typedef int (*CythonCollisionHandler)(const PythonicCallbackWrapper&, Arbiter,
                                      CollisionPair, CollisionPair);


CollisionHandlerFunc bind_cython_collision_handler(
    const CythonCollisionHandler cy_handler, PythonicCallbackWrapper callback
)
{
    using namespace std::placeholders;

    return std::bind(cy_handler, std::move(callback), _1, _2, _3);
}

typedef void (*CythonTimerCallback)(const PythonicCallbackWrapper&);

TimerCallback bind_cython_timer_callback(
    const CythonTimerCallback cy_handler, PythonicCallbackWrapper callback
)
{
    return std::bind(cy_handler, std::move(callback));
}


typedef void (*CythonNodeTransitionCallback)(const PythonicCallbackWrapper&, NodePtr);

NodeTransitionCallbackFunc bind_cython_transition_callback(
    const CythonNodeTransitionCallback cy_handler, PythonicCallbackWrapper callback
)
{
    using namespace std::placeholders;

    return std::bind(cy_handler, std::move(callback), _1);
}

typedef int32_t (*CythonEventCallback)(const PythonicCallbackWrapper&, const Event&);

EventCallback bind_cython_event_callback(
    const CythonEventCallback cy_handler, PythonicCallbackWrapper callback
)
{
    using namespace std::placeholders;

    return std::bind(cy_handler, std::move(callback), _1);
}
