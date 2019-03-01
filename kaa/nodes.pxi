from cpython.ref cimport PyObject, Py_XINCREF, Py_XDECREF

from libcpp.memory cimport unique_ptr

from .kaacore.shapes cimport CShape
from .kaacore.nodes cimport (
    CNodeType, CNode, CNodeType, CForeignNodeWrapper
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
        self.c_node = c_node

    cdef void _setup_wrapper(self):
        assert self.c_node != NULL
        self.c_node.node_wrapper = \
            unique_ptr[CForeignNodeWrapper](
                new CPyNodeWrapper(<PyObject*>self)
            )

    cdef void _init_new_node(self, CNodeType type):
        cdef CNode* c_node = new CNode(type)
        self._attach_c_node(c_node)
        self._setup_wrapper()

    def add_child(self, NodeBase node):
        assert self.c_node != NULL
        assert node.c_node != NULL
        self.c_node.add_child(node.c_node)

    @property
    def position(self):
        raise NotImplementedError

    @position.setter
    def position(self, Vector vec):
        self.c_node.set_position(vec.c_vector)

    @property
    def shape(self):
        raise NotImplementedError

    @shape.setter
    def shape(self, ShapeBase new_shape):
        if new_shape is not None:
            self.c_node.set_shape(new_shape.c_shape_ptr[0])
        else:
            self.c_node.set_shape(CShape())


cdef class Node(NodeBase):
    def __init__(self):
        self._init_new_node(CNodeType.basic)


cdef class SpaceNode(NodeBase):
    def __init__(self):
        self._init_new_node(CNodeType.space)


cdef class BodyNode(NodeBase):
    def __init__(self):
        self._init_new_node(CNodeType.body)


cdef class HitboxNode(NodeBase):
    def __init__(self):
        self._init_new_node(CNodeType.hitbox)


cdef NodeBase get_node_wrapper(CNode* c_node):
    assert c_node != NULL
    cdef NodeBase py_node
    if c_node.node_wrapper.get() != NULL:
        # TODO typeid assert?
        py_node = <object>(
            <CPyNodeWrapper*>c_node.node_wrapper.get()
        ).py_wrapper
    elif c_node.type == CNodeType.space:
        py_node = SpaceNode.__new__(SpaceNode)
        py_node._attach_c_node(c_node)
    elif c_node.type == CNodeType.body:
        py_node = BodyNode.__new__(BodyNode)
        py_node._attach_c_node(c_node)
    elif c_node.type == CNodeType.hitbox:
        py_node = HitboxNode.__new__(HitboxNode)
        py_node._attach_c_node(c_node)
    else:
        py_node = Node.__new__(Node)
        py_node._attach_c_node(c_node)
    return py_node
