from libc.stdint cimport uint8_t
from libcpp.functional cimport function

from .glue cimport CPythonicCallbackWrapper
from .vectors cimport CVector
from .nodes cimport CNode
from .exceptions cimport raise_py_error


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
        void set_gravity(const CVector gravity) \
            except +raise_py_error
        CVector get_gravity() \
            except +raise_py_error
        void set_damping(const double damping) \
            except +raise_py_error
        double get_damping() \
            except +raise_py_error
        void set_sleeping_threshold(const double threshold) \
            except +raise_py_error
        double get_sleeping_threshold() \
            except +raise_py_error
        bint is_locked() \
            except +raise_py_error
        void set_collision_handler(
            CollisionTriggerId trigger_a, CollisionTriggerId trigger_b,
            CCollisionHandlerFunc handler,
            uint8_t phases_mask, bint only_non_deleted_nodes
        ) except +raise_py_error

    cdef cppclass CBodyNode "kaacore::BodyNode":
        void set_body_type(const CBodyNodeType type) \
            except +raise_py_error
        CBodyNodeType get_body_type() \
            except +raise_py_error

        void set_mass(const double m) \
            except +raise_py_error
        double get_mass() \
            except +raise_py_error

        void set_moment(const double i) \
            except +raise_py_error
        double get_moment() \
            except +raise_py_error

        void set_velocity(const CVector velocity) \
            except +raise_py_error
        CVector get_velocity() \
            except +raise_py_error

        void set_force(const CVector force) \
            except +raise_py_error
        CVector get_force() \
            except +raise_py_error

        void set_torque(const double torque) \
            except +raise_py_error
        double get_torque() \
            except +raise_py_error

        void set_angular_velocity(const double angular_velocity) \
            except +raise_py_error
        double get_angular_velocity() \
            except +raise_py_error

        bint is_sleeping() \
            except +raise_py_error
        void sleep() \
            except +raise_py_error
        void activate() \
            except +raise_py_error

    cdef cppclass CHitboxNode "kaacore::HitboxNode":
        void set_trigger_id(const CollisionTriggerId trigger_id) \
            except +raise_py_error
        CollisionTriggerId get_trigger_id() \
            except +raise_py_error

        void set_group(const CollisionGroup group) \
            except +raise_py_error
        CollisionGroup get_group() \
            except +raise_py_error

        void set_mask(const CollisionBitmask mask) \
            except +raise_py_error
        CollisionBitmask get_mask() \
            except +raise_py_error

        void set_collision_mask(const CollisionBitmask mask) \
            except +raise_py_error
        CollisionBitmask get_collision_mask() \
            except +raise_py_error


cdef extern from "extra/include/pythonic_callback.h":
    ctypedef int (*CythonCollisionHandler)(CPythonicCallbackWrapper,
                                           CArbiter,
                                           CCollisionPair, CCollisionPair)
    CCollisionHandlerFunc bind_cython_collision_handler(
        const CythonCollisionHandler cy_handler,
        const CPythonicCallbackWrapper callback
    )
