from libcpp.memory cimport unique_ptr
from libcpp.functional cimport function

from .nodes cimport CNodePtr
from .clock cimport CDuration
from .transitions cimport CTransitionStateBase, CTransitionWarping
from .easings cimport CEasing
from .glue cimport CPythonicCallbackWrapper, CPythonicCallbackResult
from .exceptions cimport raise_py_error


cdef extern from "kaacore/transitions.h":
    cdef cppclass CNodeTransitionCustomizable "kaacore::NodeTransitionCustomizable":
        CDuration duration
        CDuration internal_duration
        CTransitionWarping warping
        CEasing _easing

        CNodeTransitionCustomizable() \
            except +raise_py_error
        CNodeTransitionCustomizable(const CDuration duration, const CTransitionWarping& warping) \
            except +raise_py_error

        unique_ptr[CTransitionStateBase] prepare_state(CNodePtr node) nogil const
        void evaluate(CTransitionStateBase* state, CNodePtr node, const double t) nogil const

    ctypedef function[void(CNodePtr)] CNodeTransitionCallbackFunc "kaacore::NodeTransitionCallbackFunc"


cdef extern from "extra/include/pythonic_callback.h":
    ctypedef CPythonicCallbackResult[void] (*CythonNodeTransitionCallback)(
        const CPythonicCallbackWrapper&, CNodePtr
    )
    CNodeTransitionCallbackFunc bind_cython_transition_callback(
        const CythonNodeTransitionCallback cy_handler,
        const CPythonicCallbackWrapper callback
    )
