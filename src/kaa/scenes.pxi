import cython
import weakref
from libc.stdint cimport uint32_t
from libcpp.memory cimport unique_ptr
from cpython.weakref cimport PyWeakref_NewRef
from cpython.ref cimport PyObject, Py_INCREF, Py_DECREF

from .kaacore.scenes cimport CScene
from .kaacore.nodes cimport CNodePtr
from .kaacore.clock cimport CDuration
from .kaacore.glue cimport CPythonicCallbackResult
from .kaacore.engine cimport is_c_engine_initialized
from .kaacore.render_passes cimport default_pass_index
from .kaacore.viewports cimport default_viewport_z_index
from .kaacore.log cimport c_emit_log_dynamic, CLogLevel, _log_category_wrapper

DEF SCENE_RESOURCE_FREELIST_SIZE = 8


cdef cppclass CPyScene(CScene):
    object py_scene_weakref

    __init__(object py_scene):
        c_emit_log_dynamic(CLogLevel.debug, _log_category_wrapper,
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

    void update(CDuration dt) nogil:
        this._call_py_update(dt).unwrap_result()

    void on_exit() nogil:
        this._call_py_on_exit().unwrap_result()

    void on_detach() nogil:
        with gil:
            Py_DECREF(this.get_py_scene())

    CPythonicCallbackResult[void] _call_py_update(CDuration dt) with gil:
        try:
            this.get_py_scene().update(dt.count())
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
        unique_ptr[CPyScene] c_scene
        Node _root_node_wrapper
        InputManager input_
        readonly _ViewportsManager viewports
        readonly _RenderPassesManager render_passes
        readonly _SpatialIndexManager spatial_index

    def __cinit__(self):
        if not is_c_engine_initialized():
            raise RuntimeError(
                'Cannot create scene since engine is not initialized yet.'
            )

        c_emit_log_dynamic(
            CLogLevel.debug, _log_category_wrapper, 'Initializing Scene'
        )
        cdef CPyScene* c_scene = new CPyScene(self)
        assert c_scene != NULL
        self.c_scene = unique_ptr[CPyScene](c_scene)

        self.input_ = InputManager()
        self.viewports = _ViewportsManager.create(self)
        self.render_passes = _RenderPassesManager.create(self)
        self.spatial_index = _SpatialIndexManager.create(self)
        self._root_node_wrapper = get_node_wrapper(
            CNodePtr(&self.c_scene.get().root_node)
        )

    @property
    def engine(self):
        return get_engine()

    @property
    def root(self):
        return self._root_node_wrapper

    @property
    def camera(self):
        return self.viewports[default_viewport_z_index].camera

    @property
    def input(self):
        return self.input_

    @property
    def clear_color(self):
        return self.render_passes[default_pass_index].clear_color

    @clear_color.setter
    def clear_color(self, Color color):
        self.render_passes[default_pass_index].clear_color = color

    @property
    def total_time(self):
        return self.c_scene.get().total_time().count()

    @property
    def time_scale(self):
        return self.c_scene.get().get_time_scale()

    @time_scale.setter
    def time_scale(self, double scale):
        self.c_scene.get().set_time_scale(scale)

    def on_enter(self):
        pass

    def update(self, dt):
        raise NotImplementedError

    def on_exit(self):
        pass


@cython.freelist(SCENE_RESOURCE_FREELIST_SIZE)
cdef class _SceneResource:
    cdef bint c_is_valid

    def __cinit__(self, Scene scene):
        self.c_is_valid = True

        def _finalizer():
            self.c_is_valid = False
        weakref.finalize(scene, _finalizer)

    def __init__(self, *args, **kwargs):
        raise RuntimeError(
            f'{self.__class__} must not be instantiated manually!'
        )

    def __copy__(self):
        raise NotImplementedError

    def __deepcopy__(self):
        raise NotImplementedError

    def __reduce__(self):
        raise NotImplementedError

    cdef int32_t check_valid(self) except -1:
        if not self.c_is_valid:
            raise RuntimeError(
                f'Accessing already deleted resource ({self.__class__}).'
            )
