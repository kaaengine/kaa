cdef extern from "kaacore/nodes.h" nogil:
    cdef enum CBodyType "BodyType":
        dynamic "BodyType::dynamic",
        kinematic "BodyType::kinematic",
        static "BodyType::static_",

    cdef cppclass SpaceNode:
        pass

    cdef cppclass BodyNode:
        pass

    cdef cppclass HitboxNode:
        pass
