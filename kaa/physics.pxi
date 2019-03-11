from enum import IntEnum

from cpython.ref cimport PyObject, Py_XINCREF, Py_XDECREF
from libc.stdint cimport uint8_t

from .kaacore.nodes cimport CNodeType
from .kaacore.physics cimport (
    CollisionTriggerId, CCollisionPhase, CArbiter, CCollisionPair,
    CCollisionHandlerFunc, bind_cython_collision_handler
)
from .kaacore.glue cimport CPythonicCallbackWrapper


cdef int collision_handler_displatch(CPythonicCallbackWrapper c_wrapper,
                                     CCollisionPhase phase, CArbiter c_arbiter,
                                     CCollisionPair c_pair_a,
                                     CCollisionPair c_pair_b):
    return 1


class CollisionPhase(IntEnum):
    begin = <uint8_t>CCollisionPhase.begin
    pre_solve = <uint8_t>CCollisionPhase.pre_solve
    post_solve = <uint8_t>CCollisionPhase.post_solve
    separate = <uint8_t>CCollisionPhase.separate


cdef class SpaceNode(NodeBase):
    def __init__(self):
        self._init_new_node(CNodeType.space)

    def setup(self, **options):
        if 'gravity' in options:
            self.gravity = options.pop('gravity')
        if 'damping' in options:
            self.damping = options.pop('damping')
        if 'sleeping_threshold' in options:
            self.sleeping_threshold = options.pop('sleeping_threshold')

        return super().setup(**options)

    @property
    def gravity(self):
        return Vector.from_c_vector(self._get_c_node().space.get_gravity())

    @gravity.setter
    def gravity(self, Vector value):
        self._get_c_node().space.set_gravity(value.c_vector)

    @property
    def damping(self):
        return self._get_c_node().space.get_damping()

    @damping.setter
    def damping(self, double value):
        self._get_c_node().space.set_damping(value)

    @property
    def sleeping_threshold(self):
        return self._get_c_node().space.get_sleeping_threshold()

    @sleeping_threshold.setter
    def sleeping_threshold(self, double value):
        self._get_c_node().space.set_sleeping_threshold(value)

    @property
    def is_locked(self):
        return self._get_c_node().space.is_locked()

    def set_collision_handler(self, CollisionTriggerId trigger_a,
                              CollisionTriggerId trigger_b, object handler,
                              uint8_t phases_mask=<uint8_t>CCollisionPhase.any_phase,
                              bint only_non_deleted_nodes=True):
        ## backward-compatibility handling
        import inspect
        if len(inspect.signature(handler).parameters) != 5:
            def _backward_compatible_wrapper(phase, space, arbiter, pair_a, pair_b):
               #c_log_warning(
               #    "[DEPRECATION WARNING] "
               #    "new-style collision callbacks receive 5 parameters: "
               #    "phase, space, arbiter, pair_a, pair_b"
               #)
                return handler(phase, space, arbiter)
            final_handler = _backward_compatible_wrapper
        else:
            final_handler = handler

        cdef CCollisionHandlerFunc bound_handler = bind_cython_collision_handler(
            collision_handler_displatch,
            CPythonicCallbackWrapper(<PyObject*>final_handler),
        )
        self._get_c_node().space.set_collision_handler(
            trigger_a, trigger_b,
            bound_handler, phases_mask=phases_mask,
            only_non_deleted_nodes=only_non_deleted_nodes
        )


cdef class BodyNode(NodeBase):
    def __init__(self):
        self._init_new_node(CNodeType.body)


cdef class HitboxNode(NodeBase):
    def __init__(self):
        self._init_new_node(CNodeType.hitbox)
