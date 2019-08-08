from libcpp.memory cimport unique_ptr
from libcpp.vector cimport vector
from libcpp cimport bool
from libc.stdint cimport int16_t

from .vectors cimport CVector, CColor
from .geometry cimport CAlignment
from .physics cimport CSpaceNode, CBodyNode, CHitboxNode
from .fonts cimport CTextNode
from .shapes cimport CShape
from .sprites cimport CSprite
from .scenes cimport CScene
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
        # UNION!
        CSpaceNode space
        CBodyNode body
        CHitboxNode hitbox
        CTextNode text

        CNode(CNodeType type) except +raise_py_error

        vector[CNode*]& children() except +raise_py_error

        void add_child(CNode* child_node) except +raise_py_error
        const CNodeType type() except +raise_py_error

        CVector position() except +raise_py_error
        CVector absolute_position() except +raise_py_error
        void position(const CVector& position) except +raise_py_error

        double rotation() except +raise_py_error
        void rotation(const double& rotation) except +raise_py_error

        CVector scale() except +raise_py_error
        void scale(const CVector& scale) except +raise_py_error

        int16_t z_index() except +raise_py_error
        void z_index(const int16_t& z_index) except +raise_py_error

        CShape shape() except +raise_py_error
        void shape(const CShape& shape) except +raise_py_error

        CSprite& sprite_ref() except +raise_py_error
        void sprite(const CSprite& sprite) except +raise_py_error

        CColor color() except +raise_py_error
        void color(const CColor& color) except +raise_py_error

        bool visible() except +raise_py_error
        void visible(const bool& visible) except +raise_py_error

        CAlignment origin_alignment() except +raise_py_error
        void origin_alignment(const CAlignment& alignment) except +raise_py_error

        CScene* scene() except +raise_py_error
        CNode* parent() except +raise_py_error

        void setup_wrapper(unique_ptr[CForeignNodeWrapper]&& wrapper)
        CForeignNodeWrapper* wrapper_ptr() except +raise_py_error
