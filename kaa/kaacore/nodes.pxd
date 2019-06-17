from libcpp.memory cimport unique_ptr
from libcpp.vector cimport vector
from libc.stdint cimport int16_t

from .vectors cimport CVector, CColor
from .physics cimport CSpaceNode, CBodyNode, CHitboxNode
from .fonts cimport CTextNode
from .shapes cimport CShape
from .sprites cimport CSprite


cdef extern from "kaacore/nodes.h" nogil:
    cdef enum CNodeType "kaacore::NodeType":
        basic "kaacore::NodeType::basic",
        space "kaacore::NodeType::space",
        body "kaacore::NodeType::body",
        hitbox "kaacore::NodeType::hitbox",
        text "kaacore::NodeType::text",

    cdef cppclass CForeignNodeWrapper "kaacore::ForeignNodeWrapper":
        pass

    cdef cppclass CChildrenIterator "kaacore::ChildrenIterator":
        vector[CNode*].const_iterator begin() const
        vector[CNode*].const_iterator end() const

    cdef cppclass CNode "kaacore::Node":
        CNodeType type
        CVector position
        double rotation
        CVector scale
        int16_t z_index
        CShape shape
        CSprite sprite
        CColor color
        bint visible

        CNode* parent
        vector[CNode*] children

        unique_ptr[CForeignNodeWrapper] node_wrapper

        # UNION!
        CSpaceNode space
        CBodyNode body
        CHitboxNode hitbox
        CTextNode text

        # TODO rest of the fields

        CNode(CNodeType type)
        void add_child(CNode* c_node)
        CChildrenIterator iter_children()
        void set_position(const CVector& position)
        void set_rotation(const double rotation)
        void set_shape(const CShape& shape)
        void set_sprite(const CSprite& sprite)
