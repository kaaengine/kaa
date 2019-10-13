from cpython.ref cimport PyObject, Py_XINCREF, Py_XDECREF

from libc.stdint cimport uint32_t
from libcpp.memory cimport unique_ptr

from .kaacore.shapes cimport CShape
from .kaacore.sprites cimport CSprite
from .kaacore.nodes cimport (
    CNodeType, CNode, CNodeType, CForeignNodeWrapper
)
from .kaacore.math cimport radians, degrees
from .kaacore.geometry cimport CAlignment


cdef cppclass CPyNodeWrapper(CForeignNodeWrapper):
    PyObject* py_wrapper

    __init__(PyObject* py_wrapper):
        Py_XINCREF(py_wrapper)
        this.py_wrapper = py_wrapper

    __dealloc__():
        Py_XDECREF(this.py_wrapper)
        this.py_wrapper = NULL


cdef class NodeBase:
    cdef:
        CNode* c_node

    def __cinit__(self):
        self.c_node = NULL

    def __init__(self, **options):
        self.setup(**options)

    cdef inline CNode* _get_c_node(self):
        assert self.c_node != NULL, \
            'Operation on uninitialized or deleted Node. Aborting.'
        return self.c_node

    cdef void _attach_c_node(self, CNode* c_node):
        assert self.c_node == NULL
        assert c_node != NULL
        self.c_node = c_node

    cdef void _setup_wrapper(self):
        assert self.c_node != NULL
        self.c_node.setup_wrapper(
            unique_ptr[CForeignNodeWrapper](
                new CPyNodeWrapper(<PyObject*>self)
            )
        )

    cdef void _init_new_node(self, CNodeType type):
        cdef CNode* c_node = new CNode(type)
        self._attach_c_node(c_node)
        self._setup_wrapper()

    def add_child(self, NodeBase node):
        assert self.c_node != NULL
        assert node.c_node != NULL
        self.c_node.add_child(node.c_node)
        return node

    def delete(self):
        assert self.c_node != NULL
        del self.c_node

    def setup(self, **options):
        if 'position' in options:
            self.position = options.pop('position')
        if 'z_index' in options:
            self.z_index = options.pop('z_index')
        if 'rotation' in options:
            self.rotation = options.pop('rotation')
        if 'rotation_degrees' in options:
            self.rotation_degrees = options.pop('rotation_degrees')
        if 'scale' in options:
            self.scale = options.pop('scale')
        if 'offset' in options:
            self.offset = options.pop('offset')
        if 'transformation_offset' in options:
            self.transformation_offset = options.pop('transformation_offset')
        if 'visible' in options:
            self.visible = options.pop('visible')
        if 'color' in options:
            self.color = options.pop('color')
        if 'track_position' in options:
            self.track_position = options.pop('track_position')
        if 'sprite' in options:
            self.sprite = options.pop('sprite')
        if 'shape' in options:
            self.shape = options.pop('shape')
        if 'origin_alignment' in options:
            self.origin_alignment = options.pop('origin_alignment')
        if 'lifetime' in options:
            self.lifetime = options.pop('lifetime')
        if 'transition' in options:
            self.transition = options.pop('transition')
        if 'width' in options:
            self.width = options.pop('width')
        if 'height' in options:
            self.height = options.pop('height')

        if options:
            raise ValueError('Passed unknown options to {}: {}'.format(
                self.__class__.__name__, options.keys()
            ))

        return self

    def update(self, **options):
        # backwards compatibility name
        return self.setup(**options)

    @property
    def children(self):
        cdef:
            CNode* c_node
            vector[CNode*] children_copy = self.c_node.children()

        for c_node in children_copy:
            yield get_node_wrapper(c_node)

    @property
    def type(self):
        return <int>self._get_c_node().type()

    @property
    def scene(self):
        cdef CPyScene* cpy_scene = <CPyScene*>self._get_c_node().scene()
        if cpy_scene:
            return cpy_scene.get_py_scene()

    @property
    def parent(self):
        if self._get_c_node().parent() != NULL:
            return get_node_wrapper(self._get_c_node().parent())

    @property
    def position(self):
        return Vector.from_c_vector(self._get_c_node().position())

    @position.setter
    def position(self, Vector vec):
        self._get_c_node().position(vec.c_vector)

    @property
    def z_index(self):
        self._get_c_node().z_index()

    @z_index.setter
    def z_index(self, int value):
        self._get_c_node().z_index(value)

    @property
    def rotation(self):
        return self._get_c_node().rotation()

    @rotation.setter
    def rotation(self, double value):
        self._get_c_node().rotation(value)

    @property
    def rotation_degrees(self):
        return degrees(self._get_c_node().rotation())

    @rotation_degrees.setter
    def rotation_degrees(self, double value):
        self._get_c_node().rotation(radians(value))

    @property
    def scale(self):
        return Vector.from_c_vector(self._get_c_node().scale())

    @scale.setter
    def scale(self, Vector vec):
        self._get_c_node().scale(vec.c_vector)

    @property
    def color(self):
        return Color.from_c_color(self._get_c_node().color())

    @color.setter
    def color(self, Color col):
        self._get_c_node().color(col.c_color)

    @property
    def visible(self):
        return self._get_c_node().visible()

    @visible.setter
    def visible(self, bint value):
        self._get_c_node().visible(value)

    @property
    def sprite(self):
        if self._get_c_node().sprite_ref().has_texture():
            return get_sprite_wrapper(&self._get_c_node().sprite_ref())

    @sprite.setter
    def sprite(self, Sprite sprite):
        if sprite:
            self._get_c_node().sprite(sprite.c_sprite_ptr[0])
        else:
            self._get_c_node().sprite(CSprite())

    @property
    def shape(self):
        return get_shape_wrapper(self._get_c_node().shape())

    @shape.setter
    def shape(self, ShapeBase new_shape):
        if new_shape is not None:
            self._get_c_node().shape(new_shape.c_shape_ptr[0])
        else:
            self._get_c_node().shape(CShape())

    @property
    def origin_alignment(self):
        return Alignment(<uint32_t>self._get_c_node().origin_alignment())

    @origin_alignment.setter
    def origin_alignment(self, alignment):
        self._get_c_node().origin_alignment(<CAlignment>(<uint32_t>alignment.value))

    @property
    def lifetime(self):
        return self._get_c_node().lifetime()

    @lifetime.setter
    def lifetime(self, uint32_t new_lifetime):
        self._get_c_node().lifetime(new_lifetime)

    @property
    def transition(self):
        if self._get_c_node().transition():
            return get_transition_wrapper(self._get_c_node().transition())

    @transition.setter
    def transition(self, transition_or_list):
        # TODO handle None
        cdef NodeTransitionBase transition
        if isinstance(transition_or_list, list):
            transition = NodeTransitionsSequence(transition_or_list)
        else:
            transition = transition_or_list
        assert transition.c_handle
        self._get_c_node().transition(transition.c_handle)


cdef class Node(NodeBase):
    def __init__(self, **options):
        self._init_new_node(CNodeType.basic)
        super().__init__(**options)


cdef NodeBase get_node_wrapper(CNode* c_node):
    assert c_node != NULL
    cdef NodeBase py_node
    if c_node.wrapper_ptr() != NULL:
        # TODO typeid assert?
        py_node = <object>(
            <CPyNodeWrapper*>c_node.wrapper_ptr()
        ).py_wrapper
    elif c_node.type() == CNodeType.space:
        py_node = SpaceNode.__new__(SpaceNode)
        py_node._attach_c_node(c_node)
    elif c_node.type() == CNodeType.body:
        py_node = BodyNode.__new__(BodyNode)
        py_node._attach_c_node(c_node)
    elif c_node.type() == CNodeType.hitbox:
        py_node = HitboxNode.__new__(HitboxNode)
        py_node._attach_c_node(c_node)
    elif c_node.type() == CNodeType.text:
        py_node = TextNode.__new__(TextNode)
        py_node._attach_c_node(c_node)
    else:
        py_node = Node.__new__(Node)
        py_node._attach_c_node(c_node)
    return py_node
