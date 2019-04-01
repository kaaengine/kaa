from libc.stdint cimport uint8_t
from libcpp.functional cimport function

from .glue cimport CPythonicCallbackWrapper
from .vectors cimport CVector
from .nodes cimport CNode


cdef extern from "kaacore/nodes.h" nogil:
    ctypedef size_t CollisionTriggerId "kaacore::CollisionTriggerId"
    ctypedef size_t CollisionGroup "kaacore::CollisionGroup"
    ctypedef size_t CollisionBitmask "kaacore::CollisionBitmask"

    cdef enum CCollisionPhase "kaacore::CollisionPhase":
        begin "kaacore::CollisionPhase::begin",
        pre_solve "kaacore::CollisionPhase::pre_solve",
        post_solve "kaacore::CollisionPhase::post_solve",
        separate "kaacore::CollisionPhase::separate",
        any_phase "kaacore::CollisionPhase::any_phase",

    cdef cppclass CArbiter "kaacore::Arbiter":
        CCollisionPhase phase
        CNode* space

    cdef cppclass CCollisionPair "kaacore::CollisionPair":
        CNode* body_node
        CNode* hitbox_node

    ctypedef function[int(CArbiter, CCollisionPair, CCollisionPair)] \
        CCollisionHandlerFunc "kaacore::CollisionHandlerFunc"

    cdef enum CBodyNodeType "kaacore::BodyNodeType":
        dynamic "kaacore::BodyNodeType::dynamic",
        kinematic "kaacore::BodyNodeType::kinematic",
        static "kaacore::BodyNodeType::static_",

    cdef cppclass CSpaceNode "kaacore::SpaceNode":
        void set_gravity(const CVector gravity)
        CVector get_gravity() const
        void set_damping(const double damping)
        double get_damping() const
        void set_sleeping_threshold(const double threshold)
        double get_sleeping_threshold() const
        bint is_locked() const
        void set_collision_handler(
            CollisionTriggerId trigger_a, CollisionTriggerId trigger_b,
            CCollisionHandlerFunc handler,
            uint8_t phases_mask, bint only_non_deleted_nodes
        )

    cdef cppclass CBodyNode "kaacore::BodyNode":
        void set_body_type(const CBodyNodeType type)
        CBodyNodeType get_body_type() const

        void set_mass(const double m)
        double get_mass() const

        void set_moment(const double i)
        double get_moment() const

        void set_velocity(const CVector velocity)
        CVector get_velocity() const

        void set_force(const CVector force)
        CVector get_force() const

        void set_torque(const double torque)
        double get_torque() const

        void set_angular_velocity(const double angular_velocity)
        double get_angular_velocity() const

        bint is_sleeping() const
        void sleep()
        void activate()

    cdef cppclass CHitboxNode "kaacore::HitboxNode":
        void set_trigger_id(const CollisionTriggerId trigger_id)
        CollisionTriggerId get_trigger_id() const

        void set_group(const CollisionGroup group)
        CollisionGroup get_group() const

        void set_mask(const CollisionBitmask mask)
        CollisionBitmask get_mask() const

        void set_collision_mask(const CollisionBitmask mask)
        CollisionBitmask get_collision_mask() const


cdef extern from "kaacore_glue/pythonic_callback.h":
    ctypedef int (*CythonCollisionHandler)(CPythonicCallbackWrapper,
                                           CArbiter,
                                           CCollisionPair, CCollisionPair)
    CCollisionHandlerFunc bind_cython_collision_handler(
        const CythonCollisionHandler cy_handler,
        const CPythonicCallbackWrapper callback
    )
