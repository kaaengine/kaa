from cpython.ref cimport PyObject, Py_XINCREF, Py_XDECREF

from libcpp cimport bool
from libcpp.memory cimport unique_ptr
from libc.stdint cimport int16_t, uint32_t
from libcpp.unordered_set cimport unordered_set

from cymove cimport cymove as cmove

from .extra.optional cimport optional, nullopt

from .kaacore.shapes cimport CShape
from .kaacore.clock cimport CDuration
from .kaacore.sprites cimport CSprite
from .kaacore.glue cimport CPythonicCallbackResult
from .kaacore.nodes cimport (
    CNodeType, CNode, CNodePtr, CNodeOwnerPtr, CForeignNodeWrapper,
    c_make_node,
)
from .kaacore.transitions cimport CNodeTransitionHandle
from .kaacore.math cimport radians, degrees
from .kaacore.geometry cimport CAlignment


cdef cppclass CPyNodeWrapper(CForeignNodeWrapper):
    PyObject* py_wrapper
    bool added_to_parent
    bool on_attach_defined
    bool on_detach_defined

    __init__(
        PyObject* py_wrapper, const bool on_attach_defined,
        const bool on_detach_defined
    ) nogil:
        this.py_wrapper = py_wrapper
        this.added_to_parent = False
        this.on_attach_defined = on_attach_defined
        this.on_detach_defined = on_detach_defined

    void on_add_to_parent() with gil:
        Py_XINCREF(py_wrapper)
        this.added_to_parent = True

    void on_attach() nogil:
        if not this.on_attach_defined:
            return

        with gil:
            try:
                (<NodeBase>this.py_wrapper).on_attach()
            except BaseException as exc:
                CPythonicCallbackResult[void](<PyObject*>exc).unwrap_result()

    void on_detach() with gil:
        cdef:
            CPythonicCallbackResult[void] result
            NodeBase py_wrapper = <NodeBase>this.py_wrapper

        if this.on_detach_defined:
            try:
                py_wrapper.on_detach()
            except BaseException as exc:
               result = CPythonicCallbackResult[void](<PyObject*>exc)

        py_wrapper._reset()
        result.unwrap_result()
        this._release_wrapper()

    __dealloc__() nogil:
        if this.added_to_parent:
            with gil:
                this._release_wrapper()

    void _release_wrapper() with gil:
        Py_XDECREF(this.py_wrapper)
        this.py_wrapper = NULL
        this.added_to_parent = False


cdef class NodeBase:
    cdef:
        # When node is created by class __init__ this member will be filled,
        # it's destructor will be called along with class destructor
        # (destroying underlying cnode if appropriate).
        # It's not used if Node class is used as a
        # wrapper for existing node.
        CNodeOwnerPtr _c_node_owner_ptr
        CNodePtr _c_node_ptr

    def __init__(self, **options):
        self.setup(**options)

    cdef void _reset(self):
        self._c_node_ptr = CNodePtr()

    cdef inline CNode* _get_c_node(self) except NULL:
        cdef CNode* c_node = self._c_node_ptr.get()
        assert c_node != NULL, \
            'Operation on uninitialized or deleted Node.'
        return c_node

    cdef void _make_c_node(self, CNodeType type):
        self._c_node_owner_ptr = cmove(c_make_node(type))
        self._c_node_ptr = CNodePtr(self._c_node_owner_ptr.get())
        cdef:
            on_attach_defined = callable(getattr(self, 'on_attach', None))
            on_detach_defined = callable(getattr(self, 'on_detach', None))
        self._c_node_ptr.get().setup_wrapper(
            unique_ptr[CForeignNodeWrapper](
                new CPyNodeWrapper(
                    <PyObject*>self, on_attach_defined, on_detach_defined
                )
            )
        )

    cdef void _attach_c_node(self, CNodePtr c_node_ptr):
        assert self._c_node_ptr.get() == NULL, "Node is already initialized, cannot attach."
        assert c_node_ptr, "Cannot atach NULL node."
        self._c_node_ptr = c_node_ptr

    def __bool__(self):
        return self._c_node_ptr.get() != NULL

    def add_child(self, NodeBase node):
        assert self._c_node_ptr, "Cannot add_child to NULL node."
        assert node._c_node_ptr, "Cannot add NULL node as child."
        assert node._c_node_owner_ptr, "Node added as child must be owned node."
        self._c_node_ptr.get().add_child(node._c_node_owner_ptr)
        return node

    def delete(self):
        assert self._c_node_ptr, "Node already deleted."
        self._c_node_ptr.destroy()

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
        if 'transformation' in options:
            self.transformation = options.pop('transformation')
        if 'visible' in options:
            self.visible = options.pop('visible')
        if 'color' in options:
            self.color = options.pop('color')
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
        if 'views' in options:
            self.views = options.pop('views')
        if 'indexable' in options:
            self.indexable = options.pop('indexable')

        if options:
            raise ValueError('Passed unknown options to {}: {}'.format(
                self.__class__.__name__, options.keys()
            ))

        return self

    @property
    def children(self):
        cdef:
            CNode* c_node
            vector[CNode*] children_copy = self._get_c_node().children()

        for c_node in children_copy:
            yield get_node_wrapper(CNodePtr(c_node))

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
        if self._get_c_node().parent():
            return get_node_wrapper(self._get_c_node().parent())
    
    @property
    def views(self):
        cdef:
            int16_t c_index
            set result = set()
            optional[vector[int16_t]] c_indices = self._get_c_node().views()
        
        if c_indices.has_value():
            for c_index in range(c_indices.value().size()):
                result.add(c_indices.value()[c_index])
            return result
    
    @views.setter
    def views(self, set z_indices):
        cdef:
            int16_t z_index
            unordered_set[int16_t] c_z_indices

        if z_indices is not None:
            for z_index in z_indices:
                c_z_indices.insert(z_index)
            self._get_c_node().views(optional[unordered_set[int16_t]](c_z_indices))
        else:
            self._get_c_node().views(optional[unordered_set[int16_t]](nullopt))

    @property
    def effective_views(self):
        cdef:
            int16_t c_index
            set result = set()
            vector[int16_t] c_indices = self._get_c_node().effective_views()

        for c_index in range(c_indices.size()):
            result.add(c_indices[c_index])
        return result

    @property
    def position(self):
        return Vector.from_c_vector(self._get_c_node().position())
    
    @property
    def absolute_position(self):
        return Vector.from_c_vector(self._get_c_node().absolute_position())

    @position.setter
    def position(self, Vector vec):
        self._get_c_node().position(vec.c_vector)
    
    def get_relative_position(self, NodeBase ancestor not None):
        return Vector.from_c_vector(
            self._get_c_node().get_relative_position(ancestor._get_c_node())
        )

    @property
    def z_index(self):
        cdef optional[int16_t] optional_z_index = self._get_c_node().z_index()
        if optional_z_index.has_value():
            return optional_z_index.value()

    @z_index.setter
    def z_index(self, value):
        if value is not None:
            self._get_c_node().z_index(optional[int16_t](<int>value))
        else:
            self._get_c_node().z_index(optional[int16_t](nullopt))

    @property
    def effective_z_index(self):
        return self._get_c_node().effective_z_index()

    @property
    def rotation(self):
        return self._get_c_node().rotation()

    @property
    def absolute_rotation(self):
        return self._get_c_node().absolute_rotation()

    @rotation.setter
    def rotation(self, double value):
        self._get_c_node().rotation(value)

    @property
    def rotation_degrees(self):
        return degrees(self._get_c_node().rotation())
    
    @property
    def absolute_rotation_degrees(self):
        return degrees(self._get_c_node().absolute_rotation())

    @rotation_degrees.setter
    def rotation_degrees(self, double value):
        self._get_c_node().rotation(radians(value))

    @property
    def scale(self):
        return Vector.from_c_vector(self._get_c_node().scale())
    
    @property
    def absolute_scale(self):
        return Vector.from_c_vector(self._get_c_node().absolute_scale())

    @scale.setter
    def scale(self, Vector vec):
        self._get_c_node().scale(vec.c_vector)

    @property
    def transformation(self):
        return Transformation.create(self._get_c_node().transformation())

    @transformation.setter
    def transformation(self, Transformation transformation not None):
        self._get_c_node().transformation(transformation.c_transformation)

    @property
    def absolute_transformation(self):
        return Transformation.create(self._get_c_node().absolute_transformation())

    def get_relative_transformation(self, NodeBase ancestor not None):
        return Transformation.create(
            self._get_c_node().get_relative_transformation(
                ancestor._get_c_node()
            )
        )

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
        if self._get_c_node().sprite().has_texture():
            return Sprite.create(self._get_c_node().sprite())

    @sprite.setter
    def sprite(self, Sprite sprite):
        if sprite is not None:
            self._get_c_node().sprite(sprite.c_sprite)
        else:
            self._get_c_node().sprite(CSprite())

    @property
    def shape(self):
        if self._get_c_node().shape():
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
        return self._get_c_node().lifetime().count()

    @lifetime.setter
    def lifetime(self, double new_lifetime):
        self._get_c_node().lifetime(CDuration(new_lifetime))

    @property
    def transition(self):
        if self._get_c_node().transition():
            return get_transition_wrapper(self._get_c_node().transition())

    @transition.setter
    def transition(self, transition_or_list):
        cdef NodeTransitionBase transition
        if transition_or_list is not None:
            if isinstance(transition_or_list, list):
                transition = NodeTransitionsSequence(transition_or_list)
            else:
                transition = transition_or_list
            assert transition.c_handle
            self._get_c_node().transition(transition.c_handle)
        else:
            self._get_c_node().transition(CNodeTransitionHandle())

    @property
    def transitions_manager(self):
        return _NodeTransitionsManager.create(self._c_node_ptr)

    @property
    def indexable(self):
        return self._get_c_node().indexable()

    @indexable.setter
    def indexable(self, bool value):
        self._get_c_node().indexable(value)

    @property
    def root_distance(self):
        return self._get_c_node().root_distance()

    @property
    def bounding_box(self):
        return BoundingBox.create(self._get_c_node().bounding_box())


cdef class Node(NodeBase):
    def __init__(self, **options):
        self._make_c_node(CNodeType.basic)
        super().__init__(**options)


cdef NodeBase get_node_wrapper(CNodePtr c_node_ptr):
    cdef CNode* c_node = c_node_ptr.get()
    assert c_node != NULL, "Cannot make wrapper for NULL node."
    cdef NodeBase py_node
    if c_node.wrapper_ptr() != NULL:
        # TODO typeid assert?
        py_node = <object>(
            <CPyNodeWrapper*>c_node.wrapper_ptr()
        ).py_wrapper
    elif c_node.type() == CNodeType.space:
        py_node = SpaceNode.__new__(SpaceNode)
        py_node._attach_c_node(c_node_ptr)
    elif c_node.type() == CNodeType.body:
        py_node = BodyNode.__new__(BodyNode)
        py_node._attach_c_node(c_node_ptr)
    elif c_node.type() == CNodeType.hitbox:
        py_node = HitboxNode.__new__(HitboxNode)
        py_node._attach_c_node(c_node_ptr)
    elif c_node.type() == CNodeType.text:
        py_node = TextNode.__new__(TextNode)
        py_node._attach_c_node(c_node_ptr)
    else:
        py_node = Node.__new__(Node)
        py_node._attach_c_node(c_node_ptr)
    return py_node
