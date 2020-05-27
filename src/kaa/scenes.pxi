from libc.stdint cimport uint32_t
from libcpp.memory cimport unique_ptr
from cpython.ref cimport PyObject, Py_INCREF, Py_DECREF
from cpython.weakref cimport PyWeakref_NewRef

from .kaacore.glue cimport CPythonicCallbackResult
from .kaacore.nodes cimport CNodePtr
from .kaacore.scenes cimport CScene
from .kaacore.engine cimport is_c_engine_initialized
from .kaacore.log cimport c_log_dynamic, CLogCategory, CLogLevel
from .kaacore.views cimport KAACORE_VIEWS_DEFAULT_Z_INDEX


cdef cppclass CPyScene(CScene):
    object py_scene_weakref

    __init__(object py_scene):
        c_log_dynamic(CLogLevel.debug, CLogCategory.engine,
                    'Created CPyScene')
        this.py_scene_weakref = PyWeakref_NewRef(py_scene, None)

    object get_py_scene():
        cdef object py_scene = this.py_scene_weakref()
        if py_scene is None:
            raise RuntimeError('Accessing already deleted scene.')
        return py_scene

    void on_attach() nogil:
        with gil:
            Py_INCREF(this.get_py_scene())

    void on_enter() nogil:
        this._call_py_on_enter().unwrap_result()

    void update(double dt) nogil:
        this._call_py_update(dt).unwrap_result()

    void on_exit() nogil:
        this._call_py_on_exit().unwrap_result()

    void on_detach() nogil:
        with gil:
            Py_DECREF(this.get_py_scene())

    CPythonicCallbackResult[void] _call_py_update(double dt) with gil:
        try:
            this.get_py_scene().update(dt)
        except BaseException as exc:
            return CPythonicCallbackResult[void](<PyObject*>exc)
        return CPythonicCallbackResult[void]()

    CPythonicCallbackResult[void] _call_py_on_enter() with gil:
        try:
            this.get_py_scene().on_enter()
        except BaseException as exc:
            return CPythonicCallbackResult[void](<PyObject*>exc)
        return CPythonicCallbackResult[void]()

    CPythonicCallbackResult[void] _call_py_on_exit() with gil:
        try:
            this.get_py_scene().on_exit()
        except BaseException as exc:
            return CPythonicCallbackResult[void](<PyObject*>exc)
        return CPythonicCallbackResult[void]()


cdef class Scene:
    cdef:
        object __weakref__
        unique_ptr[CPyScene] _c_scene
        Node _root_node_wrapper
        InputManager input_
        readonly _ViewsManager views

    def __cinit__(self):
        if not is_c_engine_initialized():
            raise RuntimeError(
                'Cannot create scene since engine is not initialized yet.'
            )

        c_log_dynamic(
            CLogLevel.debug, CLogCategory.engine, 'Initializing Scene'
        )
        cdef CPyScene* c_scene = new CPyScene(self)
        assert c_scene != NULL
        self._c_scene = unique_ptr[CPyScene](c_scene)

        self.views = _ViewsManager.create(self)
        self._root_node_wrapper = get_node_wrapper(
            CNodePtr(&self._c_scene.get().root_node)
        )
        self.input_ = InputManager()

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
    def camera(self):
        return self.views[KAACORE_VIEWS_DEFAULT_Z_INDEX].camera
    
    @property
    def clear_color(self):
        return self.views[KAACORE_VIEWS_DEFAULT_Z_INDEX].clear_color

    @clear_color.setter
    def clear_color(self, Color color):
        self.views[KAACORE_VIEWS_DEFAULT_Z_INDEX].clear_color = color

    @property
    def input(self):
        return self.input_

    @property
    def root(self):
        return self._root_node_wrapper
