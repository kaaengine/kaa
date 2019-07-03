from libc.stdint cimport uint32_t
from cpython.ref cimport PyObject, Py_XINCREF, Py_XDECREF

from .kaacore.scenes cimport CScene


cdef cppclass CPyScene(CScene):
    PyObject* py_scene

    __init__(PyObject* py_scene):
        print("Created CPyScene")
        Py_XINCREF(py_scene)
        this.py_scene = py_scene

    __dealloc__():
        Py_XDECREF(this.py_scene)
        this.py_scene = NULL

    void on_enter() nogil:
        with gil:
            (<object>this.py_scene).on_enter()

    void update(uint32_t dt) nogil:
        with gil:
            (<object>this.py_scene).update(dt)

    void on_exit() nogil:
        with gil:
            (<object>this.py_scene).on_exit()


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


cdef class Scene:
    cdef:
        CPyScene* c_scene
        Node py_root_node_wrapper
        readonly InputManager input_manager
        readonly _SceneCamera camera

    def __cinit__(self):
        print("Initializing Scene")
        self.c_scene = new CPyScene(<PyObject*>self)
        self.py_root_node_wrapper = get_node_wrapper(&self.c_scene.root_node)
        self.input_manager = InputManager()
        self.camera = _SceneCamera()
        self.camera.attach_c_scene(self.c_scene)

    def __dealloc__(self):
        del self.c_scene

    def on_enter(self):
        pass

    def update(self):
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
