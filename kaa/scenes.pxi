from libc.stdint cimport uint32_t
from cpython.ref cimport PyObject, Py_INCREF, Py_DECREF
from cpython.weakref cimport PyWeakref_NewRef

from .kaacore.nodes cimport CNodePtr
from .kaacore.scenes cimport CScene
from .kaacore.engine cimport get_c_engine
from .kaacore.log cimport c_log_dynamic, CLogCategory, CLogLevel


cdef cppclass CPyScene(CScene):
    object py_scene_weakref

    __init__(object py_scene):
        c_log_dynamic(CLogLevel.debug, CLogCategory.engine,
                    "Created CPyScene")
        this.py_scene_weakref = PyWeakref_NewRef(py_scene, None)

    object get_py_scene():
        cdef object py_scene = this.py_scene_weakref()
        if py_scene is None:
            raise RuntimeError(
                "Tried to retrieve scene which was already destroyed."
            )
        return py_scene

    void on_attach() nogil:
        with gil:
            Py_INCREF(this.get_py_scene())

    void on_enter() nogil:
        with gil:
            try:
                this.get_py_scene().on_enter()
            except BaseException as py_exc:
                c_wrap_python_exception(<PyObject*>py_exc)

    void update(uint32_t dt) nogil:
        with gil:
            try:
                this.get_py_scene().update(dt)
            except BaseException as py_exc:
                c_wrap_python_exception(<PyObject*>py_exc)

    void on_exit() nogil:
        with gil:
            try:
                this.get_py_scene().on_exit()
            except BaseException as py_exc:
                c_wrap_python_exception(<PyObject*>py_exc)

    void on_detach() nogil:
        with gil:
            Py_DECREF(this.get_py_scene())


cdef class _SceneCamera:
    cdef CPyScene* c_scene

    def __cinit__(self):
        self.c_scene = NULL

    cdef attach_c_scene(self, CPyScene* c_scene):
        assert self.c_scene == NULL
        self.c_scene = c_scene

    @property
    def position(self):
        return Vector.from_c_vector(self.c_scene.camera.position)

    @position.setter
    def position(self, Vector vec):
        self.c_scene.camera.position = vec.c_vector

    @property
    def rotation(self):
        return self.c_scene.camera.rotation.rotation

    @rotation.setter
    def rotation(self, double value):
        self.c_scene.camera.rotation = value

    @property
    def rotation_degrees(self):
        return degrees(self.c_scene.camera.rotation)

    @rotation_degrees.setter
    def rotation_degrees(self, double value):
        self.c_scene.camera.rotation = radians(value)

    @property
    def scale(self):
        return Vector.from_c_vector(self.c_scene.camera.scale)

    @scale.setter
    def scale(self, Vector vec):
        self.c_scene.camera.scale = vec.c_vector

    def unproject_position(self, Vector pos):
        return Vector.from_c_vector(
            self.c_scene.camera.unproject_position(pos.c_vector)
        )


cdef class Scene:
    cdef:
        object __weakref__
        CPyScene* c_scene
        Node py_root_node_wrapper
        readonly InputManager input_manager
        readonly _SceneCamera camera

    def __cinit__(self):
        if get_c_engine() == NULL:
            raise RuntimeError(
                'Cannot create scene since engine is not initialized yet.'
            )

        c_log_dynamic(
            CLogLevel.debug, CLogCategory.engine, 'Initializing Scene'
        )
        self.c_scene = new CPyScene(self)
        self.py_root_node_wrapper = get_node_wrapper(CNodePtr(&self.c_scene.root_node))
        self.input_manager = InputManager()
        self.camera = _SceneCamera()
        self.camera.attach_c_scene(self.c_scene)

    def __dealloc__(self):
        del self.c_scene

    def on_enter(self):
        pass

    def update(self, dt):
        raise NotImplementedError

    def on_exit(self):
        pass

    @property
    def engine(self):
        return get_engine()

    @property
    def input(self):
        return self.input_manager

    @property
    def root(self):
        return self.py_root_node_wrapper
