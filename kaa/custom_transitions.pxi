from libcpp.memory cimport unique_ptr

from .kaacore.nodes cimport CNode
from .kaacore.glue cimport CPythonicCallbackWrapper
from .kaacore.transitions cimport (
    CTransitionWarping, CTransitionStateBase, make_node_transition,
    CNodeTransitionCallback,
)
from .kaacore.custom_transitions cimport (
    CNodeTransitionCustomizable, bind_cython_transition_callback
)


cdef void node_transition_callback_dispatch(
    const CPythonicCallbackWrapper c_wrapper, CNode* c_node
):
    # TODO weak-ptr detection
    (<object>c_wrapper.py_callback)(get_node_wrapper(c_node))


cdef class NodeTransitionCallback(NodeTransitionBase):
    def __init__(self, callback_func):
        self._setup_handle(
            make_node_transition[CNodeTransitionCallback](
                bind_cython_transition_callback(
                    node_transition_callback_dispatch,
                    CPythonicCallbackWrapper(<PyObject*>callback_func),
                )
            )
        )


cdef cppclass CPyNodeCustomTransitionState(CTransitionStateBase):
    object state_object

    __init__(object state_object):
        this.state_object = state_object


cdef cppclass CPyNodeCustomTransition(CNodeTransitionCustomizable):
    CPythonicCallbackWrapper prepare_func
    CPythonicCallbackWrapper evaluate_func

    __init__(const CPythonicCallbackWrapper& prepare_func,
             const CPythonicCallbackWrapper& evaluate_func,
             const double duration, const CTransitionWarping& warping):
        this.prepare_func = prepare_func
        this.evaluate_func = evaluate_func
        this.duration = duration
        this.internal_duration = duration

    unique_ptr[CTransitionStateBase] prepare_state(CNode* c_node) const:
        cdef object state_object = (<object>this.prepare_func.py_callback)(get_node_wrapper(c_node))
        return <unique_ptr[CTransitionStateBase]> \
            unique_ptr[CPyNodeCustomTransitionState](
                new CPyNodeCustomTransitionState(state_object)
            )

    void evaluate(CTransitionStateBase* state, CNode* c_node, const double t) const:
        cdef CPyNodeCustomTransitionState* custom_state = \
            <CPyNodeCustomTransitionState*>state

        (<object>this.evaluate_func.py_callback)(custom_state.state_object,
                                                 get_node_wrapper(c_node), t)


cdef class NodeCustomTransition(NodeTransitionBase):
    def __init__(self, prepare_func, evaluate_func, double duration
                 # TODO warping
     ):
        self._setup_handle(
            make_node_transition[CPyNodeCustomTransition](
                # TODO smart weak-ptr wrapping of callbacks
                CPythonicCallbackWrapper(<PyObject*>prepare_func),
                CPythonicCallbackWrapper(<PyObject*>evaluate_func),
                duration,
                CTransitionWarping()
            )
        )
