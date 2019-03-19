from enum import IntEnum

import cython
from cpython.ref cimport PyObject, Py_XINCREF, Py_XDECREF
from libc.stdint cimport uint8_t

from .kaacore.nodes cimport CNode, CNodeType
from .kaacore.physics cimport (
    CollisionTriggerId, CCollisionPhase, CArbiter, CCollisionPair,
    CollisionGroup, CollisionBitmask, CCollisionHandlerFunc,
    bind_cython_collision_handler, CBodyNodeType
)
from .kaacore.math cimport radians, degrees
from .kaacore.glue cimport CPythonicCallbackWrapper


cdef int collision_handler_displatch(CPythonicCallbackWrapper c_wrapper,
                                     CArbiter c_arbiter,
                                     CCollisionPair c_pair_a,
                                     CCollisionPair c_pair_b):
    cdef object callback = <object>c_wrapper.py_callback
    cdef Arbiter arbiter = _prepare_arbiter(c_arbiter)
    cdef CollisionPair pair_a = _prepare_collision_pair(c_pair_a)
    cdef CollisionPair pair_b = _prepare_collision_pair(c_pair_b)
    cdef object ret = callback(arbiter, pair_a, pair_b)
    return ret if ret is not None else 1


class CollisionPhase(IntEnum):
    begin = <uint8_t>CCollisionPhase.begin
    pre_solve = <uint8_t>CCollisionPhase.pre_solve
    post_solve = <uint8_t>CCollisionPhase.post_solve
    separate = <uint8_t>CCollisionPhase.separate


class BodyNodeType(IntEnum):
    dynamic = <uint8_t>CBodyNodeType.dynamic
    kinematic = <uint8_t>CBodyNodeType.kinematic
    static = <uint8_t>CBodyNodeType.static


@cython.freelist(2)
cdef class CollisionPair:
    cdef CNode* c_body
    cdef CNode* c_hitbox

    def __init__(self):
        raise ValueError("Do not initialize manually!")

    @property
    def body(self):
        if self.c_body != NULL:
            return get_node_wrapper(self.c_body)

    @property
    def hitbox(self):
        if self.c_hitbox != NULL:
            return get_node_wrapper(self.c_hitbox)


@cython.freelist(1)
cdef class Arbiter:
    cdef CArbiter* c_arbiter

    def __init__(self):
        raise ValueError("Do not initialize manually!")

    @property
    def phase(self):
        return CollisionPhase(<uint8_t>self.c_arbiter.phase)

    @property
    def space(self):
        return get_node_wrapper(self.c_arbiter.space)


cdef CollisionPair _prepare_collision_pair(CCollisionPair& c_pair):
    cdef CollisionPair pair = CollisionPair.__new__(CollisionPair)
    pair.c_body = c_pair.body_node
    pair.c_hitbox = c_pair.hitbox_node
    return pair


cdef Arbiter _prepare_arbiter(CArbiter& c_arbiter):
    cdef Arbiter arbiter = Arbiter.__new__(Arbiter)
    arbiter.c_arbiter = &c_arbiter
    return arbiter


cdef class SpaceNode(NodeBase):
    def __init__(self, **options):
        self._init_new_node(CNodeType.space)
        super().__init__(**options)

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
    def __init__(self, **options):
        self._init_new_node(CNodeType.body)
        super().__init__(**options)

    def setup(self, **options):
        if 'body_type' in options:
            self.body_type = options.pop('body_type')
        if 'force' in options:
            self.force = options.pop('force')
        if 'velocity' in options:
            self.velocity = options.pop('velocity')
        if 'torque' in options:
            self.torque = options.pop('torque')
        if 'torque_degrees' in options:
            self.torque_degrees = options.pop('torque_degrees')
        if 'angular_velocity' in options:
            self.angular_velocity = options.pop('angular_velocity')
        if 'angular_velocity_degrees' in options:
            self.angular_velocity_degrees = options.pop('angular_velocity_degrees')
        if 'mass' in options:
            self.mass = options.pop('mass')
        if 'moment' in options:
            self.moment = options.pop('moment')

        return super().setup(**options)

    @property
    def body_type(self):
        return BodyNodeType(<uint8_t>self._get_c_node().body.get_body_type())

    @body_type.setter
    def body_type(self, body_t):
        self._get_c_node().body.set_body_type(<CBodyNodeType>(<uint8_t>body_t.value))

    @property
    def force(self):
        return Vector.from_c_vector(self._get_c_node().body.get_force())

    @force.setter
    def force(self, Vector vec):
        self._get_c_node().body.set_force(vec.c_vector)

    @property
    def velocity(self):
        return Vector.from_c_vector(self._get_c_node().body.get_velocity())

    @velocity.setter
    def velocity(self, Vector vec):
        self._get_c_node().body.set_velocity(vec.c_vector)

    @property
    def torque(self):
        return self._get_c_node().body.get_torque()

    @torque.setter
    def torque(self, double rad_sec):
        self._get_c_node().body.set_torque(rad_sec)

    @property
    def torque_degrees(self):
        return degrees(self._get_c_node().body.get_torque())

    @torque_degrees.setter
    def torque_degrees(self, double deg_sec):
        self._get_c_node().body.set_torque(radians(deg_sec))

    @property
    def angular_velocity(self):
        return self._get_c_node().body.get_angular_velocity()

    @angular_velocity.setter
    def angular_velocity(self, double rad_sec):
        self._get_c_node().body.set_angular_velocity(rad_sec)

    @property
    def angular_velocity_degrees(self):
        return degrees(self._get_c_node().body.get_angular_velocity())

    @angular_velocity_degrees.setter
    def angular_velocity_degrees(self, double deg_sec):
        self._get_c_node().body.set_angular_velocity(radians(deg_sec))

    @property
    def mass(self):
        return self._get_c_node().body.get_mass()

    @mass.setter
    def mass(self, double value):
        self._get_c_node().body.set_mass(value)

    @property
    def moment(self):
        return self._get_c_node().body.get_moment()

    @moment.setter
    def moment(self, double value):
        self._get_c_node().body.set_moment(value)

    @property
    def sleeping(self):
        return self._get_c_node().body.is_sleeping()

    def sleep(self):
        self._get_c_node().body.sleep()

    def activate(self):
        self._get_c_node().body.activate()


cdef class HitboxNode(NodeBase):
    def __init__(self, **options):
        self._init_new_node(CNodeType.hitbox)
        super().__init__(**options)

    def setup(self, **options):
        if 'shape' in options:  # XXX this must be updated first
            self.shape = options.pop('shape')

        if 'group' in options:
            self.group = options.pop('group')
        if 'mask' in options:
            self.mask = options.pop('mask')
        if 'collision_mask' in options:
            self.collision_mask = options.pop('collision_mask')
        if 'trigger_id' in options:
            self.trigger_id = options.pop('trigger_id')

        return super().setup(**options)

    @property
    def group(self):
        return self._get_c_node().hitbox.get_group()

    @group.setter
    def group(self, CollisionGroup cgrp):
        self._get_c_node().hitbox.set_group(cgrp)

    @property
    def mask(self):
        return self._get_c_node().hitbox.get_mask()

    @mask.setter
    def mask(self, CollisionBitmask mask):
        self._get_c_node().hitbox.set_mask(mask)

    @property
    def collision_mask(self):
        return self._get_c_node().hitbox.get_collision_mask()

    @collision_mask.setter
    def collision_mask(self, CollisionBitmask mask):
        self._get_c_node().hitbox.set_collision_mask(mask)

    @property
    def trigger_id(self):
        return self._get_c_node().hitbox.get_trigger_id()

    @trigger_id.setter
    def trigger_id(self, CollisionTriggerId id):
        self._get_c_node().hitbox.set_trigger_id(id)
