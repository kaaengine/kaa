from libcpp.memory cimport unique_ptr
from libcpp.vector cimport vector
from libc.stdint cimport int16_t

from .vectors cimport CVec2
from .physics cimport SpaceNode, BodyNode, HitboxNode
from .shapes cimport CShape


cdef extern from "kaacore/nodes.h" nogil:
    cdef enum CNodeType "NodeType":
        basic "NodeType::basic",
        space "NodeType::space",
        body "NodeType::body",
        hitbox "NodeType::hitbox",

    cdef cppclass CForeignNodeWrapper "ForeignNodeWrapper":
        pass

    cdef cppclass CNode "Node":
        CNodeType type
        CVec2 position
        double rotation
        CVec2 scale
        int16_t z_index
        CShape shape
        # CSprite sprite  TODO
        # glm::dvec4 color = {1., 1., 1., 1.};  TODO
        bint visible

        CNode* parent
        vector[CNode*] children

        unique_ptr[CForeignNodeWrapper] node_wrapper

        # UNION!
        SpaceNode space
        BodyNode body
        HitboxNode hitbox

        # TODO rest of the fields

        CNode(CNodeType type)
        void add_child(CNode* c_node)
        void set_position(const CVec2& position)
        void set_shape(const CShape& shape)
