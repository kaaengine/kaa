from libcpp.memory cimport unique_ptr
from libcpp.vector cimport vector
from libc.stdint cimport int16_t

from .vectors cimport CVector, CColor
from .geometry cimport CAlignment
from .physics cimport CSpaceNode, CBodyNode, CHitboxNode
from .fonts cimport CTextNode
from .shapes cimport CShape
from .sprites cimport CSprite
from .exceptions cimport raise_py_error


cdef extern from "kaacore/nodes.h" nogil:
    cdef enum CNodeType "kaacore::NodeType":
        basic "kaacore::NodeType::basic",
        space "kaacore::NodeType::space",
        body "kaacore::NodeType::body",
        hitbox "kaacore::NodeType::hitbox",
        text "kaacore::NodeType::text",

    cdef cppclass CForeignNodeWrapper "kaacore::ForeignNodeWrapper":
        pass

    cdef cppclass CNode "kaacore::Node":
        CNodeType type
        CVector position
        double rotation
        CVector scale
        int16_t z_index
        CShape shape
        CAlignment origin_alignment
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

        CNode(CNodeType type) \
            except +raise_py_error
        void add_child(CNode* c_node) \
            except +raise_py_error
        void set_position(const CVector& position) \
            except +raise_py_error
        void set_rotation(const double rotation) \
            except +raise_py_error
        void set_shape(const CShape& shape) \
            except +raise_py_error
        void set_sprite(const CSprite& sprite) \
            except +raise_py_error
