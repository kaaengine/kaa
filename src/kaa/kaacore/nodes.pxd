from libc.stdint cimport uint16_t, int16_t, uint32_t
from libcpp cimport bool
from libcpp.vector cimport vector
from libcpp.memory cimport unique_ptr
from libcpp.unordered_set cimport unordered_set

from ..extra.optional cimport optional

from .vectors cimport CDVec2, CColor
from .geometry cimport CAlignment, CTransformation, CBoundingBox
from .physics cimport CSpaceNode, CBodyNode, CHitboxNode
from .fonts cimport CTextNode
from .shapes cimport CShape
from .clock cimport CDuration
from .sprites cimport CSprite
from .scenes cimport CScene
from .transitions cimport CNodeTransitionHandle, CNodeTransitionsManager
from .exceptions cimport raise_py_error
from .resources cimport CResourceReference
from .materials cimport CMaterial


cdef extern from "kaacore/node_ptr.h" namespace "kaacore" nogil:
    cdef cppclass CNodePtr "kaacore::NodePtr":
        CNodePtr()
        CNodePtr(CNode*)
        bool operator==(const CNode*)
        bool operator bool()
        CNode* get() except +raise_py_error
        void destroy() except +raise_py_error

    cdef cppclass CNodeOwnerPtr "kaacore::NodeOwnerPtr":
        CNodeOwnerPtr()
        bool operator==(const CNode*)
        bool operator bool()
        CNode* get() except +raise_py_error
        void destroy() except +raise_py_error


cdef extern from "kaacore/nodes.h" namespace "kaacore" nogil:
    cdef enum CNodeType "kaacore::NodeType":
        basic "kaacore::NodeType::basic",
        space "kaacore::NodeType::space",
        body "kaacore::NodeType::body",
        hitbox "kaacore::NodeType::hitbox",
        text "kaacore::NodeType::text",

    cdef cppclass CForeignNodeWrapper "kaacore::ForeignNodeWrapper":
        void on_add_to_parent()
        void on_attach()
        void on_detach()

    cdef cppclass CNode "kaacore::Node":
        # UNION!
        CSpaceNode space
        CBodyNode body
        CHitboxNode hitbox
        CTextNode text

        vector[CNode*] children() except +raise_py_error

        void add_child(CNodeOwnerPtr child_node) except +raise_py_error
        const CNodeType type() except +raise_py_error

        CDVec2 position() except +raise_py_error
        CDVec2 absolute_position() except +raise_py_error

        CDVec2 get_relative_position(const CNode* const ancestor) except +raise_py_error
        void position(const CDVec2& position) except +raise_py_error

        double rotation() except +raise_py_error
        double absolute_rotation() except +raise_py_error
        void rotation(const double rotation) except +raise_py_error

        CDVec2 scale() except +raise_py_error
        CDVec2 absolute_scale() except +raise_py_error
        void scale(const CDVec2& scale) except +raise_py_error

        CTransformation absolute_transformation() except +raise_py_error
        CTransformation get_relative_transformation(const CNode* const ancestor) except +raise_py_error

        CTransformation transformation() except +raise_py_error
        void transformation(const CTransformation& transformation) except +raise_py_error

        optional[int16_t] z_index() except +raise_py_error
        void z_index(const optional[int16_t]& z_index) except +raise_py_error
        int16_t effective_z_index() except +raise_py_error

        CShape shape() except +raise_py_error
        void shape(const CShape& shape) except +raise_py_error

        CSprite sprite() except +raise_py_error
        void sprite(const CSprite& sprite) except +raise_py_error

        CResourceReference[CMaterial]& material() except +raise_py_error
        void material(const CResourceReference[CMaterial]& material) except +raise_py_error

        CColor color() except +raise_py_error
        void color(const CColor& color) except +raise_py_error

        bool visible() except +raise_py_error
        void visible(const bool visible) except +raise_py_error

        CAlignment origin_alignment() except +raise_py_error
        void origin_alignment(const CAlignment alignment) except +raise_py_error

        CDuration lifetime() except +raise_py_error
        void lifetime(const CDuration lifetime) except +raise_py_error

        CNodeTransitionHandle transition() except +raise_py_error
        void transition(const CNodeTransitionHandle& transition) except +raise_py_error

        CNodeTransitionsManager& transitions_manager() except +raise_py_error

        CScene* scene() except +raise_py_error
        CNodePtr parent() except +raise_py_error

        void views(const optional[unordered_set[int16_t]]& z_indices) except +raise_py_error
        const optional[vector[int16_t]] views() except +raise_py_error
        const vector[int16_t] effective_views() except +raise_py_error

        void setup_wrapper(unique_ptr[CForeignNodeWrapper]&& wrapper)
        CForeignNodeWrapper* wrapper_ptr() except +raise_py_error

        bool indexable() except +raise_py_error
        void indexable(const bool indexable) except +raise_py_error

        uint16_t root_distance() except +raise_py_error

        CBoundingBox bounding_box() except +raise_py_error

    CNodeOwnerPtr c_make_node "kaacore::make_node" (CNodeType) except +raise_py_error
