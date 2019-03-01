cdef extern from "kaacore/nodes.h" nogil:
    cdef enum CBodyType "kaacore::BodyType":
        dynamic "kaacore::BodyType::dynamic",
        kinematic "kaacore::BodyType::kinematic",
        static "kaacore::BodyType::static_",

    cdef cppclass CSpaceNode "kaacore::SpaceNode":
        pass

    cdef cppclass CBodyNode "kaacore::BodyNode":
        pass

    cdef cppclass CHitboxNode "kaacore::HitboxNode":
        pass
