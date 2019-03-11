#include <functional>

#include <Python.h>

#include "kaacore/physics.h"
#include "kaacore/log.h"

using namespace kaacore;


struct PythonicCallbackWrapper {
    PyObject* py_callback;

    PythonicCallbackWrapper(PyObject* py_callback) : py_callback(py_callback)
    {
        log("Creating PythonicCallbackWrapper: %p", py_callback);
        Py_INCREF(this->py_callback);
    }

    PythonicCallbackWrapper(const PythonicCallbackWrapper& wrapper)
    {
        this->py_callback = wrapper.py_callback;
        Py_INCREF(this->py_callback);
    }

    ~PythonicCallbackWrapper()
    {
        assert(this->py_callback != nullptr);
        Py_DECREF(this->py_callback);
    }

    PythonicCallbackWrapper& operator=(const PythonicCallbackWrapper& wrapper)
    {
        this->~PythonicCallbackWrapper();
        this->py_callback = wrapper.py_callback;
        Py_INCREF(this->py_callback);
    }
};


typedef int (*CythonCollisionHandler)(PythonicCallbackWrapper, Arbiter,
                                      CollisionPair, CollisionPair);


CollisionHandlerFunc bind_cython_collision_handler(
    const CythonCollisionHandler cy_handler, const PythonicCallbackWrapper callback
)
{
    using namespace std::placeholders;

    return std::bind(cy_handler, callback, _1, _2, _3);
}
