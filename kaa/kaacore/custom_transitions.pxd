from libcpp.memory cimport unique_ptr
from libcpp.functional cimport function

from .nodes cimport CNode
from .transitions cimport CTransitionStateBase, CTransitionWarping
from .glue cimport CPythonicCallbackWrapper
from .exceptions cimport raise_py_error


cdef extern from "kaacore/transitions.h":
    cdef cppclass CNodeTransitionCustomizable "kaacore::NodeTransitionCustomizable":
        double duration
        double internal_duration

        CNodeTransitionCustomizable() \
            except +raise_py_error
        CNodeTransitionCustomizable(const double duration, const CTransitionWarping& warping) \
            except +raise_py_error

        unique_ptr[CTransitionStateBase] prepare_state(CNode* node) const
        void evaluate(CTransitionStateBase* state, CNode* node, const double t) const

    ctypedef function[void(CNode*)] CNodeTransitionCallbackFunc "kaacore::NodeTransitionCallbackFunc";


cdef extern from "extra/include/pythonic_callback.h":
    ctypedef void (*CythonNodeTransitionCallback)(
        const CPythonicCallbackWrapper, CNode*
    )
    CNodeTransitionCallbackFunc bind_cython_transition_callback(
        const CythonNodeTransitionCallback cy_handler,
        const CPythonicCallbackWrapper callback
    )
