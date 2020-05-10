import inspect
import weakref
from enum import IntEnum

import cython
from cpython.ref cimport PyObject
from libc.stdint cimport uint8_t
from libcpp.vector cimport vector
from cymove cimport cymove as cmove

from .kaacore.nodes cimport CNode, CNodeType
from .kaacore.physics cimport (
    CollisionTriggerId, CCollisionPhase, CArbiter, CCollisionPair,
    CollisionGroup, CollisionBitmask, CCollisionHandlerFunc,
    bind_cython_collision_handler, CBodyNodeType,
    CCollisionContactPoint, CShapeQueryResult,
    collision_bitmask_all, collision_bitmask_none, collision_group_none
)
from .kaacore.math cimport radians, degrees
from .kaacore.glue cimport CPythonicCallbackWrapper
from .kaacore.exceptions cimport c_wrap_python_exception


COLLISION_BITMASK_ALL = collision_bitmask_all
COLLISION_BITMASK_NONE = collision_bitmask_none
COLLISION_GROUP_NONE = collision_group_none


cdef int collision_handler_displatch(const CPythonicCallbackWrapper& c_wrapper,
                                     CArbiter c_arbiter,
                                     CCollisionPair c_pair_a,
                                     CCollisionPair c_pair_b):
    cdef object callback
    if c_wrapper.is_weakref:
        callback = (<object>c_wrapper.py_callback)()
        if callback is None:
            raise RuntimeError(
                "Collision handler tried to call destroyed callback object"
            )
    else:
        callback = <object>c_wrapper.py_callback
    cdef Arbiter arbiter = _prepare_arbiter(c_arbiter)
    cdef CollisionPair pair_a = _prepare_collision_pair(c_pair_a)
    cdef CollisionPair pair_b = _prepare_collision_pair(c_pair_b)
    cdef object ret
    try:
        ret = callback(arbiter, pair_a, pair_b)
    except Exception as py_exc:
        c_wrap_python_exception(<PyObject*>py_exc)
    else:
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
    cdef CNodePtr c_body
    cdef CNodePtr c_hitbox

    cdef NodeBase _body_node_wrapper
    cdef NodeBase _hitbox_node_wrapper

    def __cinit__(self):
        self._body_node_wrapper = None
        self._hitbox_node_wrapper = None

    def __init__(self):
        raise RuntimeError(f'{self.__class__} must not be instantiated manually!')

    @property
    def body(self):
        if self.c_body:
            if self._body_node_wrapper is None:
                self._body_node_wrapper = get_node_wrapper(self.c_body)
            return self._body_node_wrapper

    @property
    def hitbox(self):
        if self.c_hitbox:
            if self._hitbox_node_wrapper is None:
                self._hitbox_node_wrapper = get_node_wrapper(self.c_hitbox)
            return self._hitbox_node_wrapper


@cython.freelist(64)
cdef class CollisionContactPoint:
    cdef CCollisionContactPoint c_collision_contact_point

    @staticmethod
    cdef CollisionContactPoint create(CCollisionContactPoint& c_collision_contact_point):
        cdef CollisionContactPoint collision_contact_point = \
            CollisionContactPoint.__new__(CollisionContactPoint)
        collision_contact_point.c_collision_contact_point = c_collision_contact_point
        return collision_contact_point

    def __init__(self):
        raise RuntimeError(f'{self.__class__} must not be instantiated manually!')

    @property
    def point_a(self):
        return Vector.from_c_vector(self.c_collision_contact_point.point_a)

    @property
    def point_b(self):
        return Vector.from_c_vector(self.c_collision_contact_point.point_b)

    @property
    def distance(self):
        return self.c_collision_contact_point.distance


@cython.freelist(32)
cdef class ShapeQueryResult:
    cdef CShapeQueryResult c_shape_query_result

    cdef NodeBase _body_node_wrapper
    cdef NodeBase _hitbox_node_wrapper
    cdef list _contact_points_list

    def __cinit__(self):
        self._body_node_wrapper = None
        self._hitbox_node_wrapper = None
        self._contact_points_list = None

    @staticmethod
    cdef ShapeQueryResult create(CShapeQueryResult& c_shape_query_result):
        cdef ShapeQueryResult shape_query_result = \
            ShapeQueryResult.__new__(ShapeQueryResult)
        shape_query_result.c_shape_query_result = c_shape_query_result
        return shape_query_result

    @staticmethod
    cdef list create_list(vector[CShapeQueryResult]& c_shape_query_results_vector):
        return [
            ShapeQueryResult.create(c_res) for c_res in c_shape_query_results_vector
        ]

    def __init__(self):
        raise RuntimeError(f'{self.__class__} must not be instantiated manually!')

    @property
    def body(self):
        if self.c_shape_query_result.body_node:
            if self._body_node_wrapper is None:
                self._body_node_wrapper = get_node_wrapper(self.c_shape_query_result.body_node)
            return self._body_node_wrapper

    @property
    def hitbox(self):
        if self.c_shape_query_result.hitbox_node:
            if self._hitbox_node_wrapper is None:
                self._hitbox_node_wrapper = get_node_wrapper(self.c_shape_query_result.hitbox_node)
            return self._hitbox_node_wrapper

    @property
    def contact_points(self):
        if self._contact_points_list is None:
            self._contact_points_list = [
                CollisionContactPoint.create(c_ccp)
                for c_ccp in self.c_shape_query_result.contact_points
            ]
        return self._contact_points_list.copy()


@cython.freelist(1)
cdef class Arbiter:
    cdef CArbiter* c_arbiter

    def __init__(self):
        raise RuntimeError(f'{self.__class__} must not be instantiated manually!')

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
        self._make_c_node(CNodeType.space)
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
        return Vector.from_c_vector(self._get_c_node().space.gravity())

    @gravity.setter
    def gravity(self, Vector value):
        self._get_c_node().space.gravity(value.c_vector)

    @property
    def damping(self):
        return self._get_c_node().space.damping()

    @damping.setter
    def damping(self, double value):
        self._get_c_node().space.damping(value)

    @property
    def sleeping_threshold(self):
        return self._get_c_node().space.sleeping_threshold()

    @sleeping_threshold.setter
    def sleeping_threshold(self, double value):
        self._get_c_node().space.sleeping_threshold(value)

    @property
    def locked(self):
        return self._get_c_node().space.locked()

    def set_collision_handler(self, CollisionTriggerId trigger_a,
                              CollisionTriggerId trigger_b, object handler,
                              uint8_t phases_mask=<uint8_t>CCollisionPhase.any_phase,
                              bint only_non_deleted_nodes=True):
        cdef object final_handler
        cdef bint final_handler_is_weakref
        if inspect.ismethod(handler):
            final_handler = weakref.WeakMethod(handler)
            final_handler_is_weakref = True
        else:
            final_handler = handler
            final_handler_is_weakref = False

        cdef CCollisionHandlerFunc bound_handler = bind_cython_collision_handler(
            collision_handler_displatch,
            CPythonicCallbackWrapper(<PyObject*>final_handler,
                                     final_handler_is_weakref),
        )
        self._get_c_node().space.set_collision_handler(
            trigger_a, trigger_b,
            cmove(bound_handler), phases_mask=phases_mask,
            only_non_deleted_nodes=only_non_deleted_nodes
        )

    def query_shape_overlaps(self, ShapeBase shape not None, Vector position=Vector(0., 0.),
                             *, CollisionBitmask mask=collision_bitmask_all,
                             CollisionBitmask collision_mask=collision_bitmask_all,
                             CollisionGroup group=collision_group_none):
        return ShapeQueryResult.create_list(
            self._get_c_node().space.query_shape_overlaps(
                shape.c_shape_ptr[0], position.c_vector, mask, collision_mask, group
            )
        )

cdef class BodyNode(NodeBase):
    def __init__(self, **options):
        self._make_c_node(CNodeType.body)
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
        return BodyNodeType(<uint8_t>self._get_c_node().body.body_type())

    @body_type.setter
    def body_type(self, body_t):
        self._get_c_node().body.body_type(<CBodyNodeType>(<uint8_t>body_t.value))

    @property
    def force(self):
        return Vector.from_c_vector(self._get_c_node().body.force())

    @force.setter
    def force(self, Vector vec not None):
        self._get_c_node().body.force(vec.c_vector)

    def apply_force_at(self, Vector force not None, Vector at not None):
        self._get_c_node().body.apply_force_at(
            force.c_vector, at.c_vector
        )

    def apply_impulse_at(self, Vector force not None, Vector at not None):
        self._get_c_node().body.apply_impulse_at(
            force.c_vector, at.c_vector
        )

    @property
    def velocity(self):
        return Vector.from_c_vector(self._get_c_node().body.velocity())

    @velocity.setter
    def velocity(self, Vector vec not None):
        self._get_c_node().body.velocity(vec.c_vector)

    @property
    def torque(self):
        return self._get_c_node().body.torque()

    @torque.setter
    def torque(self, double rad_sec):
        self._get_c_node().body.torque(rad_sec)

    @property
    def torque_degrees(self):
        return degrees(self._get_c_node().body.torque())

    @torque_degrees.setter
    def torque_degrees(self, double deg_sec):
        self._get_c_node().body.torque(radians(deg_sec))

    @property
    def angular_velocity(self):
        return self._get_c_node().body.angular_velocity()

    @angular_velocity.setter
    def angular_velocity(self, double rad_sec):
        self._get_c_node().body.angular_velocity(rad_sec)

    @property
    def angular_velocity_degrees(self):
        return degrees(self._get_c_node().body.angular_velocity())

    @angular_velocity_degrees.setter
    def angular_velocity_degrees(self, double deg_sec):
        self._get_c_node().body.angular_velocity(radians(deg_sec))

    @property
    def mass(self):
        return self._get_c_node().body.mass()

    @mass.setter
    def mass(self, double value):
        self._get_c_node().body.mass(value)

    @property
    def moment(self):
        return self._get_c_node().body.moment()

    @moment.setter
    def moment(self, double value):
        self._get_c_node().body.moment(value)

    @property
    def sleeping(self):
        return self._get_c_node().body.sleeping()

    @sleeping.setter
    def sleeping(self, bool sleeping):
        self._get_c_node().body.sleeping(sleeping)


cdef class HitboxNode(NodeBase):
    def __init__(self, **options):
        self._make_c_node(CNodeType.hitbox)
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
        return self._get_c_node().hitbox.group()

    @group.setter
    def group(self, CollisionGroup cgrp):
        self._get_c_node().hitbox.group(cgrp)

    @property
    def mask(self):
        return self._get_c_node().hitbox.mask()

    @mask.setter
    def mask(self, CollisionBitmask mask):
        self._get_c_node().hitbox.mask(mask)

    @property
    def collision_mask(self):
        return self._get_c_node().hitbox.collision_mask()

    @collision_mask.setter
    def collision_mask(self, CollisionBitmask mask):
        self._get_c_node().hitbox.collision_mask(mask)

    @property
    def trigger_id(self):
        return self._get_c_node().hitbox.trigger_id()

    @trigger_id.setter
    def trigger_id(self, CollisionTriggerId id):
        self._get_c_node().hitbox.trigger_id(id)
