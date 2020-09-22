import cython
from libc.stdint cimport uintptr_t
from libcpp.memory cimport unique_ptr
from cpython.ref cimport PyObject

from .kaacore.nodes cimport CNode
from .kaacore.glue cimport CPythonicCallbackWrapper, CPythonicCallbackResult
from .kaacore.transitions cimport (
    CTransitionWarping, CTransitionStateBase, make_node_transition,
    CNodeTransitionCallback,
)
from .kaacore.custom_transitions cimport (
    CNodeTransitionCustomizable, bind_cython_transition_callback
)


cdef CPythonicCallbackResult[void] node_transition_callback_dispatch(
    const CPythonicCallbackWrapper& c_wrapper, CNodePtr c_node_ptr
) with gil:
    # TODO weak-ptr detection
    try:
        (<object>c_wrapper.py_callback)(get_node_wrapper(c_node_ptr))
    except Exception as exc:
        return CPythonicCallbackResult[void](<PyObject*>exc)
    return CPythonicCallbackResult[void]()


@cython.final
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
             const double duration, const CTransitionWarping& warping,
             const CEasing easing):
        this.prepare_func = prepare_func
        this.evaluate_func = evaluate_func
        this.duration = duration * warping.duration_factor()
        this.internal_duration = duration
        this.warping = warping
        this._easing = easing

    unique_ptr[CTransitionStateBase] prepare_state(CNodePtr c_node_ptr) nogil const:
        cdef CPyNodeCustomTransitionState* state_ptr = \
                <CPyNodeCustomTransitionState*>this._py_prepare_state(c_node_ptr).unwrap_result()

        return <unique_ptr[CTransitionStateBase]> \
            unique_ptr[CPyNodeCustomTransitionState](
                state_ptr
            )

    CPythonicCallbackResult[uintptr_t] _py_prepare_state(CNodePtr c_node_ptr) with gil const:
        cdef object state_object
        try:
            state_object = (<object>this.prepare_func.py_callback)(get_node_wrapper(c_node_ptr))
        except BaseException as exc:
            return CPythonicCallbackResult[uintptr_t](<PyObject*>exc)
        else:
            return CPythonicCallbackResult[uintptr_t](
                <uintptr_t>
                new CPyNodeCustomTransitionState(state_object)
            )

    void evaluate(CTransitionStateBase* state, CNodePtr c_node_ptr, const double t) nogil const:
        this._py_evaluate(state, c_node_ptr, t).unwrap_result()

    CPythonicCallbackResult[void] _py_evaluate(
        CTransitionStateBase* state, CNodePtr c_node_ptr, const double t
    ) with gil const:
        cdef CPyNodeCustomTransitionState* custom_state = \
            <CPyNodeCustomTransitionState*>state

        try:
            (<object>this.evaluate_func.py_callback)(custom_state.state_object,
                                                     get_node_wrapper(c_node_ptr), t)
        except BaseException as exc:
            return CPythonicCallbackResult[void](<PyObject*>exc)
        else:
            return CPythonicCallbackResult[void]()


@cython.final
cdef class NodeCustomTransition(NodeTransitionBase):
    def __init__(self, prepare_func, evaluate_func, double duration
                 **options,
     ):
        self._validate_options(options, can_use_easings=True)
        self._setup_handle(
            make_node_transition[CPyNodeCustomTransition](
                # TODO smart weak-ptr wrapping of callbacks
                CPythonicCallbackWrapper(<PyObject*>prepare_func),
                CPythonicCallbackWrapper(<PyObject*>evaluate_func),
                duration,
                self._prepare_warping(options),
                self._prepare_easing(options),
            )
        )
