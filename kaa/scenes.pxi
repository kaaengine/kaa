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


cdef class Scene:
    cdef:
        CPyScene* c_scene
        Node py_root_node_wrapper
        readonly InputManager input_manager

    def __cinit__(self):
        print("Initializing Scene")
        self.c_scene = new CPyScene(<PyObject*>self)
        self.py_root_node_wrapper = get_node_wrapper(&self.c_scene.root_node)
        self.input_manager = InputManager()

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
