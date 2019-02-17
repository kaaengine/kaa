from libcpp.memory cimport unique_ptr


cdef extern from "kaacore/nodes.h" nogil:
    cdef cppclass CNodeType "NodeType":
        pass

    cdef cppclass CForeignNodeWrapper "ForeignNodeWrapper":
        pass

    cdef cppclass CNode "Node":
        CNodeType type
        unique_ptr[CForeignNodeWrapper] node_wrapper
        # TODO rest of the fields

        Node "CNode" (CNodeType type)
        void add_child(CNode* c_node)
