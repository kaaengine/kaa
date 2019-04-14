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

    void update(uint32_t dt) nogil:
        with gil:
            (<object>this.py_scene).update(dt)


cdef class Scene:
    cdef:
        CPyScene* c_scene
        Node py_root_node_wrapper
        readonly InputManager input
        readonly AssetsLoader assets

    def __cinit__(self):
        print("Initializing Scene")
        self.c_scene = new CPyScene(<PyObject*>self)
        self.py_root_node_wrapper = get_node_wrapper(&self.c_scene.root_node)
        self.input = InputManager()
        self.assets = AssetsLoader()

    def __dealloc__(self):
        del self.c_scene

    def update(self):
        raise NotImplementedError

    @property
    def engine(self):
        return get_engine()

    @property
    def time(self):
        return self.c_scene.time

    @property
    def root(self):
        return self.py_root_node_wrapper
