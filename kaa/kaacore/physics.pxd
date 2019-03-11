from libc.stdint cimport uint8_t
from libcpp.functional cimport function

from .glue cimport CPythonicCallbackWrapper
from .vectors cimport CVec2


cdef extern from "kaacore/nodes.h" nogil:
    ctypedef size_t CollisionTriggerId "kaacore::CollisionTriggerId";
    ctypedef size_t CollisionGroup "kaacore::CollisionGroup";
    ctypedef size_t CollisionBitmask "kaacore::CollisionBitmask";

    cdef enum CCollisionPhase "kaacore::CollisionPhase":
        begin "kaacore::CollisionPhase::begin",
        pre_solve "kaacore::CollisionPhase::pre_solve",
        post_solve "kaacore::CollisionPhase::post_solve",
        separate "kaacore::CollisionPhase::separate",
        any_phase "kaacore::CollisionPhase::any_phase",

    cdef cppclass CArbiter "kaacore::Arbiter":
        pass

    cdef cppclass CCollisionPair "kaacore::CollisionPair":
        pass

    ctypedef function[int(CCollisionPhase, CArbiter, CCollisionPair, CCollisionPair)] \
        CCollisionHandlerFunc "kaacore::CollisionHandlerFunc"

    cdef enum CBodyType "kaacore::BodyType":
        dynamic "kaacore::BodyType::dynamic",
        kinematic "kaacore::BodyType::kinematic",
        static "kaacore::BodyType::static_",

    cdef cppclass CSpaceNode "kaacore::SpaceNode":
        void set_gravity(const CVec2 gravity)
        CVec2 get_gravity() const
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
        pass

    cdef cppclass CHitboxNode "kaacore::HitboxNode":
        pass


cdef extern from "kaacore_glue/pythonic_callback.h":
    ctypedef int (*CythonCollisionHandler)(CPythonicCallbackWrapper,
                                           CCollisionPhase, CArbiter,
                                           CCollisionPair, CCollisionPair)
    CCollisionHandlerFunc bind_cython_collision_handler(
        const CythonCollisionHandler cy_handler,
        const CPythonicCallbackWrapper callback
    )
