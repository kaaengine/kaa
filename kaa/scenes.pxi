from libc.stdint cimport uint32_t
from cpython.ref cimport PyObject, Py_INCREF, Py_DECREF
from cpython.weakref cimport PyWeakref_NewRef

from .kaacore.scenes cimport CScene


cdef cppclass CPyScene(CScene):
    object py_scene_weakref

    __init__(object py_scene):
        print("Created CPyScene")
        this.py_scene_weakref = PyWeakref_NewRef(py_scene, None)

    object get_py_scene():
        cdef object py_scene = this.py_scene_weakref()
        if py_scene is None:
            raise RuntimeError(
                "Tried to retrieve scene which was already destroyed"
            )
        return py_scene

    void on_enter() nogil:
        with gil:
            try:
                this.get_py_scene().on_enter()
            except Exception as py_exc:
                c_wrap_python_exception(<PyObject*>py_exc)


    void update(uint32_t dt) nogil:
        with gil:
            try:
                this.get_py_scene().update(dt)
            except Exception as py_exc:
                c_wrap_python_exception(<PyObject*>py_exc)

    void on_exit() nogil:
        with gil:
            try:
                this.get_py_scene().on_exit()
            except Exception as py_exc:
                c_wrap_python_exception(<PyObject*>py_exc)


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
        CPyScene* c_scene
        Node py_root_node_wrapper
        readonly InputManager input_manager
        readonly _SceneCamera camera

    def __cinit__(self):
        print("Initializing Scene")
        self.c_scene = new CPyScene(self)
        self.py_root_node_wrapper = get_node_wrapper(&self.c_scene.root_node)
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
    def time(self):
        return self.c_scene.time

    @property
    def input(self):
        return self.input_manager

    @property
    def root(self):
        return self.py_root_node_wrapper
