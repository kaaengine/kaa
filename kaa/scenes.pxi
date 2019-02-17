from cpython.ref cimport PyObject, Py_XINCREF, Py_XDECREF
from libc.stdint cimport uint32_t

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

    def __cinit__(self):
        print("Initializing Scene")
        self.c_scene = new CPyScene(<PyObject*>self)

    def __dealloc__(self):
        del self.c_scene

    def update(self):
        raise NotImplementedError

    @property
    def time(self):
        return self.c_scene.time

    def quit(self):
        quit_game()
