from libc.stdint cimport uint8_t
from libcpp.functional cimport function
from libcpp.vector cimport vector
from libcpp cimport bool

from .glue cimport CPythonicCallbackWrapper
from .vectors cimport CVector
from .shapes cimport CShape
from .nodes cimport CNode, CNodePtr
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
        CVector point_a
        CVector point_b
        double distance

    cdef cppclass CShapeQueryResult "kaacore::ShapeQueryResult":
        CNodePtr body_node
        CNodePtr hitbox_node
        vector[CCollisionContactPoint] contact_points

    cdef cppclass CSpaceNode "kaacore::SpaceNode":
        void gravity(const CVector& gravity) \
            except +raise_py_error
        CVector gravity() \
            except +raise_py_error
        void damping(const double& damping) \
            except +raise_py_error
        double damping() \
            except +raise_py_error
        void sleeping_threshold(const double& threshold) \
            except +raise_py_error
        double sleeping_threshold() \
            except +raise_py_error
        bint locked() \
            except +raise_py_error
        void set_collision_handler(
            CollisionTriggerId trigger_a, CollisionTriggerId trigger_b,
            CCollisionHandlerFunc handler,
            uint8_t phases_mask, bint only_non_deleted_nodes
        ) except +raise_py_error
        vector[CShapeQueryResult] query_shape_overlaps(const CShape& shape, const CVector& position) \
            except +raise_py_error

    cdef cppclass CBodyNode "kaacore::BodyNode":
        void body_type(const CBodyNodeType& type) \
            except +raise_py_error
        CBodyNodeType body_type() \
            except +raise_py_error

        void mass(const double& m) \
            except +raise_py_error
        double mass() \
            except +raise_py_error

        void moment(const double& i) \
            except +raise_py_error
        double moment() \
            except +raise_py_error

        void velocity(const CVector& velocity) \
            except +raise_py_error
        CVector velocity() \
            except +raise_py_error

        void force(const CVector& force) \
            except +raise_py_error
        CVector force() \
            except +raise_py_error

        void torque(const double& torque) \
            except +raise_py_error
        double torque() \
            except +raise_py_error

        void angular_velocity(const double& angular_velocity) \
            except +raise_py_error
        double angular_velocity() \
            except +raise_py_error

        bool sleeping() \
            except +raise_py_error
        void sleeping(const bool& sleeping) \
            except +raise_py_error

    cdef cppclass CHitboxNode "kaacore::HitboxNode":
        void trigger_id(const CollisionTriggerId& trigger_id) \
            except +raise_py_error
        CollisionTriggerId trigger_id() \
            except +raise_py_error

        void group(const CollisionGroup& group) \
            except +raise_py_error
        CollisionGroup group() \
            except +raise_py_error

        void mask(const CollisionBitmask& mask) \
            except +raise_py_error
        CollisionBitmask mask() \
            except +raise_py_error

        void collision_mask(const CollisionBitmask& mask) \
            except +raise_py_error
        CollisionBitmask collision_mask() \
            except +raise_py_error


cdef extern from "extra/include/pythonic_callback.h":
    ctypedef int (*CythonCollisionHandler)(CPythonicCallbackWrapper,
                                           CArbiter,
                                           CCollisionPair, CCollisionPair)
    CCollisionHandlerFunc bind_cython_collision_handler(
        const CythonCollisionHandler cy_handler,
        const CPythonicCallbackWrapper callback
    )
