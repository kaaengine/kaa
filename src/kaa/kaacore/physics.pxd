from libc.stdint cimport uint8_t
from libcpp.functional cimport function
from libcpp.vector cimport vector
from libcpp cimport bool

from .glue cimport CPythonicCallbackWrapper, CPythonicCallbackResult
from .vectors cimport CDVec2
from .shapes cimport CShape
from .nodes cimport CNode, CNodePtr
from .exceptions cimport raise_py_error
from ..extra.optional cimport optional


cdef extern from "kaacore/physics.h" nogil:
    ctypedef size_t CollisionTriggerId "kaacore::CollisionTriggerId"
    ctypedef size_t CollisionGroup "kaacore::CollisionGroup"
    ctypedef size_t CollisionBitmask "kaacore::CollisionBitmask"

    cdef:
        CollisionGroup collision_group_none
        CollisionBitmask collision_bitmask_none
        CollisionBitmask collision_bitmask_all

    cdef enum CCollisionPhase "kaacore::CollisionPhase":
        begin "kaacore::CollisionPhase::begin",
        pre_solve "kaacore::CollisionPhase::pre_solve",
        post_solve "kaacore::CollisionPhase::post_solve",
        separate "kaacore::CollisionPhase::separate",
        any_phase "kaacore::CollisionPhase::any_phase",

    cdef cppclass CArbiter "kaacore::Arbiter":
        CCollisionPhase phase
        CNodePtr space

    cdef cppclass CCollisionPair "kaacore::CollisionPair":
        CNodePtr body_node
        CNodePtr hitbox_node

    ctypedef function[int(CArbiter, CCollisionPair, CCollisionPair)] \
        CCollisionHandlerFunc "kaacore::CollisionHandlerFunc"

    cdef enum CBodyNodeType "kaacore::BodyNodeType":
        dynamic "kaacore::BodyNodeType::dynamic",
        kinematic "kaacore::BodyNodeType::kinematic",
        static "kaacore::BodyNodeType::static_",

    cdef cppclass CCollisionContactPoint "kaacore::CollisionContactPoint":
        CDVec2 point_a
        CDVec2 point_b
        double distance

    cdef cppclass CShapeQueryResult "kaacore::ShapeQueryResult":
        CNodePtr body_node
        CNodePtr hitbox_node
        vector[CCollisionContactPoint] contact_points

    cdef cppclass CSpaceNode "kaacore::SpaceNode":
        void gravity(const CDVec2& gravity) except +raise_py_error
        CDVec2 gravity() except +raise_py_error
        void damping(const double damping) except +raise_py_error
        double damping() except +raise_py_error
        void sleeping_threshold(const double threshold) except +raise_py_error
        double sleeping_threshold() except +raise_py_error
        bint locked() except +raise_py_error
        void set_collision_handler(
            CollisionTriggerId trigger_a, CollisionTriggerId trigger_b,
            CCollisionHandlerFunc handler,
            uint8_t phases_mask, bint only_non_deleted_nodes
        ) except +raise_py_error
        vector[CShapeQueryResult] query_shape_overlaps(
            const CShape& shape, const CDVec2& position, const CollisionBitmask mask,
            const CollisionBitmask collision_mask, const CollisionGroup group,
        ) except +raise_py_error

    ctypedef function[void(CNode*, CDVec2, double, double)] \
        CVelocityUpdateCallback "kaacore::VelocityUpdateCallback"

    ctypedef function[void(CNode*, double)] \
        CPositionUpdateCallback "kaacore::PositionUpdateCallback"

    cdef cppclass CBodyNode "kaacore::BodyNode":
        void body_type(const CBodyNodeType& type) except +raise_py_error
        CBodyNodeType body_type() except +raise_py_error

        void mass(const double m) except +raise_py_error
        double mass() except +raise_py_error
        double mass_inverse() except +raise_py_error

        void moment(const double i) except +raise_py_error
        double moment() except +raise_py_error
        double moment_inverse() except +raise_py_error

        void center_of_gravity(const CDVec2 cog) except +raise_py_error
        CDVec2 center_of_gravity() except +raise_py_error

        void velocity(const CDVec2& velocity) except +raise_py_error
        CDVec2 velocity() except +raise_py_error

        void local_force(const CDVec2& force) except +raise_py_error
        CDVec2 local_force() except +raise_py_error
        void force(const CDVec2& force) except +raise_py_error
        CDVec2 force() except +raise_py_error
        void apply_force_at_local(const CDVec2& force, const CDVec2& at) except +raise_py_error
        void apply_impulse_at_local(const CDVec2& impulse, const CDVec2& at) except +raise_py_error
        void apply_force_at(const CDVec2& force, const CDVec2& at) except +raise_py_error
        void apply_impulse_at(const CDVec2& impulse, const CDVec2& at) except +raise_py_error

        void torque(const double torque) except +raise_py_error
        double torque() except +raise_py_error

        void angular_velocity(const double& angular_velocity) except +raise_py_error
        double angular_velocity() except +raise_py_error

        void damping(const optional[double]& damping) except +raise_py_error
        optional[double] damping() except +raise_py_error

        void gravity(const optional[CDVec2]& gravity) except +raise_py_error
        optional[CDVec2] gravity() except +raise_py_error

        bint sleeping() except +raise_py_error
        void sleeping(const bint sleeping) except +raise_py_error

        CDVec2 _velocity_bias() except +raise_py_error
        void _velocity_bias(const CDVec2& velocity) except +raise_py_error

        double _angular_velocity_bias() except +raise_py_error
        void _angular_velocity_bias(const double torque) except +raise_py_error

        void set_velocity_update_callback(CVelocityUpdateCallback callback)
        void set_position_update_callback(CPositionUpdateCallback callback)

    cdef cppclass CHitboxNode "kaacore::HitboxNode":
        void trigger_id(const CollisionTriggerId& trigger_id) except +raise_py_error
        CollisionTriggerId trigger_id() except +raise_py_error

        void group(const CollisionGroup& group) except +raise_py_error
        CollisionGroup group() except +raise_py_error

        void mask(const CollisionBitmask& mask) except +raise_py_error
        CollisionBitmask mask() except +raise_py_error

        void collision_mask(const CollisionBitmask& mask) except +raise_py_error
        CollisionBitmask collision_mask() except +raise_py_error


cdef extern from "extra/include/pythonic_callback.h":
    ctypedef CPythonicCallbackResult[int] (*CythonCollisionHandler)(
        const CPythonicCallbackWrapper&, CArbiter,
        CCollisionPair, CCollisionPair
    )
    CCollisionHandlerFunc bind_cython_collision_handler(
        const CythonCollisionHandler cy_handler,
        const CPythonicCallbackWrapper callback
    )

    ctypedef CPythonicCallbackResult[void] (*CythonVelocityUpdateCallback)(
        const CPythonicCallbackWrapper&,
        CNode*, CDVec2,double, double)

    CVelocityUpdateCallback bind_cython_update_velocity_callback(
        const CythonVelocityUpdateCallback, CPythonicCallbackWrapper
    )

    ctypedef CPythonicCallbackResult[void] (*CythonPositionUpdateCallback)(
        const CPythonicCallbackWrapper&, CNode*, double)

    CPositionUpdateCallback bind_cython_update_position_callback(
        const CythonPositionUpdateCallback, CPythonicCallbackWrapper
    )
