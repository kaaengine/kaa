from libc.stdint cimport uint32_t
from libcpp cimport bool
from libcpp.vector cimport vector
from libcpp.memory cimport unique_ptr
from libcpp.string cimport string

from .exceptions cimport raise_py_error


cdef extern from "kaacore/transitions.h" nogil:
    cdef cppclass CNodeTransitionHandle "kaacore::NodeTransitionHandle":
        CNodeTransitionHandle()
        bool operator bool()

    cdef cppclass CTransitionStateBase "kaacore::TransitionStateBase":
        pass

    cdef cppclass CTransitionWarping "kaacore::TransitionWarping":
        CTransitionWarping() except +raise_py_error
        CTransitionWarping(uint32_t loops, bool back_and_forth) except +raise_py_error
        double duration_factor() const


    cdef CNodeTransitionHandle make_node_transition[T](...) except +raise_py_error
    cdef CNodeTransitionHandle make_node_transitions_sequence(const vector[CNodeTransitionHandle]&, ...) \
        except +raise_py_error
    cdef CNodeTransitionHandle make_node_transitions_parallel(const vector[CNodeTransitionHandle]&, ...) \
        except +raise_py_error

    cdef cppclass CNodeTransitionsManager "kaacore::NodeTransitionsManager":
        CNodeTransitionHandle get(const string& name) except +raise_py_error
        void set(const string& name, const CNodeTransitionHandle& transition) except +raise_py_error


cdef extern from "kaacore/node_transitions.h" nogil:
    cdef enum CAttributeTransitionMethod "kaacore::AttributeTransitionMethod":
        set "kaacore::AttributeTransitionMethod::set"
        add "kaacore::AttributeTransitionMethod::add"
        multiply "kaacore::AttributeTransitionMethod::multiply"

    cdef cppclass CNodeTransitionDelay "kaacore::NodeTransitionDelay":
        pass

    cdef cppclass CNodeTransitionCallback "kaacore::NodeTransitionCallback":
        pass

    cdef cppclass CNodePositionTransition "kaacore::NodePositionTransition":
        pass

    cdef cppclass CNodeRotationTransition "kaacore::NodeRotationTransition":
        pass

    cdef cppclass CNodeScaleTransition "kaacore::NodeScaleTransition":
        pass

    cdef cppclass CNodeColorTransition "kaacore::NodeColorTransition":
        pass

    cdef cppclass CNodeSpriteTransition "kaacore::NodeSpriteTransition":
        pass

    cdef cppclass CBodyNodeVelocityTransition "kaacore::BodyNodeVelocityTransition":
        pass

    cdef cppclass CBodyNodeAngularVelocityTransition "kaacore::BodyNodeAngularVelocityTransition":
        pass
