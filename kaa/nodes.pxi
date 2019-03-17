from cpython.ref cimport PyObject, Py_XINCREF, Py_XDECREF

from libcpp.memory cimport unique_ptr

from .kaacore.shapes cimport CShape
from .kaacore.sprites cimport CSprite
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
        return node

    def delete(self):
        assert self.c_node != NULL
        del self.c_node

    def setup(self, **options):
       #assert not (
       #    'width' in options and 'height' in options and 'shape' in options
       #), "width+height and shape are not allowed together"

       #if (
       #    'width' not in options and 'height' not in options and
       #    'shape' not in options and 'sprite' in options and
       #    options['sprite'] is not None
       #):
       #    sprite_size = Sprite(options['sprite']).size
       #    options['width'] = sprite_size.x
       #    options['height'] = sprite_size.y

       #if ('width' in options and 'height' in options):
       #    size = Vector(options['width'], options['height'])
       #    options['shape'] = Polygon.from_box(
       #        size * -0.5, size * 0.5
       #    )

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
        if 'track_position' in options:
            self.track_position = options.pop('track_position')
        if 'sprite' in options:
            self.sprite = options.pop('sprite')
        if 'shape' in options:
            self.shape = options.pop('shape')
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
    def type(self):
        return <int>self._get_c_node().type

    @property
    def parent(self):
        if self._get_c_node().parent != NULL:
            return get_node_wrapper(self._get_c_node().parent)

    @property
    def position(self):
        raise Vector.from_c_vector(self._get_c_node().position)

    @position.setter
    def position(self, Vector vec):
        self._get_c_node().set_position(vec.c_vector)

    @property
    def z_index(self):
        self._get_c_node().z_index

    @z_index.setter
    def z_index(self, int value):
        self._get_c_node().z_index = value

    @property
    def rotation(self):
        return self._get_c_node().rotation

    @rotation.setter
    def rotation(self, double value):
        self._get_c_node().rotation = value

    #@property
    #def rotation_degrees(self):
    #    return glm_deg(self._get_c_node().rotation.z)

    #@rotation_degrees.setter
    #def rotation_degrees(self, double value):
    #    self._get_c_node().rotation.z = glm_rad(value)

    @property
    def scale(self):
        return Vector.from_c_vector(self._get_c_node().scale)

    @scale.setter
    def scale(self, Vector vec):
        self._get_c_node().scale = vec.c_vector

    @property
    def visible(self):
        return self._get_c_node().visible

    @visible.setter
    def visible(self, bint value):
        self._get_c_node().visible = value

    @property
    def sprite(self):
        if self._get_c_node().sprite.has_texture():
            return get_sprite_wrapper(&self._get_c_node().sprite)

    @sprite.setter
    def sprite(self, Sprite sprite):
        if sprite:
            self._get_c_node().set_sprite(sprite.c_sprite_ptr[0])
        else:
            self._get_c_node().set_sprite(CSprite())

    @property
    def shape(self):
        return get_shape_wrapper(&self._get_c_node().shape)

    @shape.setter
    def shape(self, ShapeBase new_shape):
        if new_shape is not None:
            self._get_c_node().set_shape(new_shape.c_shape_ptr[0])
        else:
            self._get_c_node().set_shape(CShape())


cdef class Node(NodeBase):
    def __init__(self, **options):
        self._init_new_node(CNodeType.basic)
        super().__init__(**options)


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
