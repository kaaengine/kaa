from cpython.ref cimport PyObject, Py_XINCREF, Py_XDECREF

from libcpp.memory cimport unique_ptr

from .kaacore.nodes cimport (
    CNodeType, CNode, CForeignNodeWrapper
)


cdef cppclass CPyNodeWrapper(CForeignNodeWrapper):
    PyObject* py_wrapper

    __init__(PyObject* py_wrapper):
        # print("Creating CPyNodeWrapper %x" % int(py_wrapper))
        Py_XINCREF(py_wrapper)
        this.py_wrapper = py_wrapper

    __dealloc__():
        # print("Destroying CPyNodeWrapper %x" % int(py_wrapper))
        Py_XDECREF(this.py_wrapper)
        this.py_wrapper = NULL


cdef class NodeBase:
    cdef:
        CNode* c_node

    def __cinit__(self):
        self.c_node = NULL

    @property
    def type(self):
        return <int>self.c_node.type

    cdef void _attach_c_node(self, CNode* c_node):
        assert self.c_node == NULL
        assert c_node != NULL

    cdef void _setup_wrapper(self):
        assert self.c_node != NULL
        self.c_node.node_wrapper = \
            unique_ptr[CForeignNodeWrapper](
                new CPyNodeWrapper(<PyObject*>self)
            )

    cdef void _init_new_node(self):
        cdef CNode* c_node = new CNode()
        self._attach_c_node(c_node)
        self._setup_wrapper()

    def add_child(self, NodeBase node):
        assert self.c_node != NULL
        assert node.c_node != NULL
        self.c_node.add_child(node.c_node)


cdef class Node(NodeBase):
    def __init__(self):
        self._init_new_node()


cdef NodeBase get_node_wrapper(CNode* c_node):
    assert c_node != NULL
    cdef NodeBase py_node
    if c_node.node_wrapper.get() != NULL:
        # TODO typeid assert?
        py_node = <object>(
            <CPyNodeWrapper*>c_node.node_wrapper.get()
        ).py_wrapper
    else:
        py_node = Node.__new(Node)
        py_node._attach_c_node(c_node)
    return py_node
