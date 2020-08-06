from enum import IntEnum

import cython
from libcpp.vector cimport vector
from cymove cimport cymove as cmove

from .kaacore.vectors cimport CDVec2
from .kaacore.sprites cimport CSprite
from .kaacore.transitions cimport (
    CNodeTransitionHandle, CTransitionWarping,
    CNodeTransitionsManager,
    CAttributeTransitionMethod, CNodePositionTransition,
    CNodeRotationTransition, CNodeScaleTransition,
    CNodeColorTransition, CBodyNodeVelocityTransition,
    CBodyNodeAngularVelocityTransition, CNodeTransitionDelay,
    CNodeSpriteTransition,
    make_node_transition, make_node_transitions_sequence,
    make_node_transitions_parallel
)
from .kaacore.nodes cimport CNodePtr
from .kaacore.easings cimport CEasing


class AttributeTransitionMethod(IntEnum):
    set = <uint8_t>CAttributeTransitionMethod.set
    add = <uint8_t>CAttributeTransitionMethod.add
    multiply = <uint8_t>CAttributeTransitionMethod.multiply


cdef class NodeTransitionBase:
    cdef CNodeTransitionHandle c_handle

    cdef void _setup_handle(self, const CNodeTransitionHandle& handle):
        self.c_handle = handle

    cdef void _validate_options(self, dict options, bool can_use_easings) except *:
        for k in options:
            if not (
                k in {'loops', 'back_and_forth'}
                or (can_use_easings and k == 'easing')
            ):
                raise TypeError("Unrecognized transition option: {}".format(k))

    cdef CTransitionWarping _prepare_warping(self, dict options) except *:
        return CTransitionWarping(
            options.get('loops', 1),
            options.get('back_and_forth', False),
        )

    cdef CEasing _prepare_easing(self, dict options) except *:
        return <CEasing>(<uint8_t>options.get('easing', Easing.none))


cdef class UnknownTransition(NodeTransitionBase):
    def __init__(self):
        raise RuntimeError(f'{self.__class__} must not be instantiated manually!')


@cython.final
cdef class NodePositionTransition(NodeTransitionBase):
    def __init__(self, Vector value_advance, double duration, *,
                 advance_method=AttributeTransitionMethod.set,
                 **options,
     ):
        self._validate_options(options, can_use_easings=True)
        self._setup_handle(
            make_node_transition[CNodePositionTransition](
                value_advance.c_vector,
                (<CAttributeTransitionMethod>(<uint8_t>advance_method.value)),
                duration,
                self._prepare_warping(options),
                self._prepare_easing(options),
            )
        )


@cython.final
cdef class NodeRotationTransition(NodeTransitionBase):
    def __init__(self, double value_advance, double duration, *,
                 advance_method=AttributeTransitionMethod.set,
                 **options,
     ):
        self._validate_options(options, can_use_easings=True)
        self._setup_handle(
            make_node_transition[CNodeRotationTransition](
                value_advance,
                (<CAttributeTransitionMethod>(<uint8_t>advance_method.value)),
                duration,
                self._prepare_warping(options),
                self._prepare_easing(options),
            )
        )


@cython.final
cdef class NodeScaleTransition(NodeTransitionBase):
    def __init__(self, Vector value_advance, double duration, *,
                 advance_method=AttributeTransitionMethod.set,
                 **options,
     ):
        self._validate_options(options, can_use_easings=True)
        self._setup_handle(
            make_node_transition[CNodeScaleTransition](
                value_advance.c_vector,
                (<CAttributeTransitionMethod>(<uint8_t>advance_method.value)),
                duration,
                self._prepare_warping(options),
                self._prepare_easing(options),
            )
        )


@cython.final
cdef class NodeColorTransition(NodeTransitionBase):
    def __init__(self, Color value_advance, double duration, *,
                 advance_method=AttributeTransitionMethod.set,
                 **options,
     ):
        self._validate_options(options, can_use_easings=True)
        self._setup_handle(
            make_node_transition[CNodeColorTransition](
                value_advance.c_color,
                (<CAttributeTransitionMethod>(<uint8_t>advance_method.value)),
                duration,
                self._prepare_warping(options),
                self._prepare_easing(options),
            )
        )


@cython.final
cdef class BodyNodeVelocityTransition(NodeTransitionBase):
    def __init__(self, Vector value_advance, double duration, *,
                 advance_method=AttributeTransitionMethod.set,
                 **options,
     ):
        self._validate_options(options, can_use_easings=True)
        self._setup_handle(
            make_node_transition[CBodyNodeVelocityTransition](
                value_advance.c_vector,
                (<CAttributeTransitionMethod>(<uint8_t>advance_method.value)),
                duration,
                self._prepare_warping(options),
                self._prepare_easing(options),
            )
        )


@cython.final
cdef class BodyNodeAngularVelocityTransition(NodeTransitionBase):
    def __init__(self, double value_advance, double duration, *,
                 advance_method=AttributeTransitionMethod.set,
                 **options,
     ):
        self._validate_options(options, can_use_easings=True)
        self._setup_handle(
            make_node_transition[CBodyNodeAngularVelocityTransition](
                value_advance,
                (<CAttributeTransitionMethod>(<uint8_t>advance_method.value)),
                duration,
                self._prepare_warping(options),
                self._prepare_easing(options),
            )
        )


@cython.final
cdef class NodeSpriteTransition(NodeTransitionBase):
    def __init__(self, list sprites, double duration, *,
                 **options,
    ):
        cdef vector[CSprite] c_sprites_vector
        cdef Sprite sprite
        c_sprites_vector.reserve(len(sprites))
        for sprite in sprites:
            c_sprites_vector.push_back(sprite.c_sprite)

        self._validate_options(options, can_use_easings=True)
        self._setup_handle(
            make_node_transition[CNodeSpriteTransition](
                cmove(c_sprites_vector),
                duration,
                self._prepare_warping(options),
                self._prepare_easing(options),
            )
        )


cdef dict SPECIALIZED_TRANSITIONS = {
        Node.position: NodePositionTransition,
        Node.rotation: NodeRotationTransition,
        Node.scale: NodeScaleTransition,
        Node.color: NodeColorTransition,
        Node.sprite: NodeSpriteTransition,
        BodyNode.velocity: BodyNodeVelocityTransition,
        BodyNode.angular_velocity: BodyNodeAngularVelocityTransition
    }


def NodeTransition(attribute, *args, **kwargs):
    try:
        return SPECIALIZED_TRANSITIONS[attribute](*args, **kwargs)
    except KeyError as e:
        raise ValueError(
            f'Transition for {attribute} attribute is not supported!'
        ) from e


@cython.final
cdef class NodeTransitionDelay(NodeTransitionBase):
    def __init__(self, double duration):
        self._setup_handle(
            make_node_transition[CNodeTransitionDelay](duration)
        )


@cython.final
cdef class NodeTransitionsSequence(NodeTransitionBase):
    def __init__(self, list sub_transitions,
                 **options,
    ):
        cdef vector[CNodeTransitionHandle] c_sub_transitions
        c_sub_transitions.reserve(len(sub_transitions))

        cdef NodeTransitionBase sub_tr
        for sub_tr in sub_transitions:
            c_sub_transitions.push_back(sub_tr.c_handle)

        self._validate_options(options, can_use_easings=False)
        self._setup_handle(
            make_node_transitions_sequence(
                c_sub_transitions,
                self._prepare_warping(options),
            )
        )


@cython.final
cdef class NodeTransitionsParallel(NodeTransitionBase):
    def __init__(self, list sub_transitions,
                 **options,
    ):
        cdef vector[CNodeTransitionHandle] c_sub_transitions
        c_sub_transitions.reserve(len(sub_transitions))

        cdef NodeTransitionBase sub_tr
        for sub_tr in sub_transitions:
            c_sub_transitions.push_back(sub_tr.c_handle)

        self._validate_options(options, can_use_easings=False)
        self._setup_handle(
            make_node_transitions_parallel(
                c_sub_transitions,
                self._prepare_warping(options),
            )
        )


cdef NodeTransitionBase get_transition_wrapper(const CNodeTransitionHandle& transition):
    cdef NodeTransitionBase py_transition
    # TODO recongize transition type

    py_transition = UnknownTransition.__new__(UnknownTransition)
    py_transition._setup_handle(transition)

    return py_transition


cdef class _NodeTransitionsManager:
    cdef CNodePtr c_node

    def __init__(self):
        raise RuntimeError(f'{self.__class__} must not be instantiated manually!')

    @staticmethod
    cdef create(CNodePtr c_node):
        assert c_node
        cdef _NodeTransitionsManager manager = \
            _NodeTransitionsManager.__new__(_NodeTransitionsManager)
        manager.c_node = c_node
        return manager

    def get(self, str transition_name):
        cdef CNodeTransitionHandle c_transition = \
            self.c_node.get().transitions_manager().get(transition_name.encode('ascii'))
        if c_transition:
            return get_transition_wrapper(cmove(c_transition))

    def set(self, str transition_name, NodeTransitionBase transition):
        if transition is not None:
            self.c_node.get().transitions_manager().set(
                transition_name.encode('ascii'), transition.c_handle
            )
        else:
            self.c_node.get().transitions_manager().set(
                transition_name.encode('ascii'), CNodeTransitionHandle()
            )
