import cython
import weakref
from libc.stdint cimport int16_t, int32_t
from cpython.weakref cimport PyWeakref_NewRef

from .kaacore.camera cimport CCamera
from .kaacore.views cimport CView, CViewsManager
from .kaacore.vectors cimport CDVec2, CIVec2, CUVec2


cdef class _SceneResource:
    cdef bint _c_is_valid

    def __cinit__(self, Scene scene):
        self._c_is_valid = True

        def _finalizer():
            self._c_is_valid = False
        weakref.finalize(scene, _finalizer)
    
    def __init__(self, *args, **kwargs):
        raise RuntimeError(f'{self.__class__} must not be instantiated manually!')

    def __copy__(self):
        raise NotImplementedError
    
    def __deepcopy__(self):
        raise NotImplementedError

    def __reduce__(self):
        raise NotImplementedError
    
    cdef int32_t _check_valid(self) except -1:
        if not self._c_is_valid:
            raise RuntimeError(f'Accessing already deleted resource ({self.__class__}).')
    

@cython.final
cdef class _ViewsManager(_SceneResource):
    cdef:
        dict _cache
        object _scene_weakref
        CViewsManager* _c_views

    @staticmethod
    cdef _ViewsManager create(Scene scene):
        cdef _ViewsManager views_manager = _ViewsManager.__new__(_ViewsManager, scene)
        views_manager._scene_weakref = PyWeakref_NewRef(scene, None)
        views_manager._c_views = &scene._c_scene.get().views
        views_manager._cache = {}
        return views_manager
    
    cdef CViewsManager* _get_c_views(self) except NULL:
        self._check_valid()
        return self._c_views
    
    def __getitem__(self, int16_t z_index):
        try:
            return self._cache[z_index]
        except KeyError:
            pass
        
        cdef:
            CView* c_view = self._get_c_views().get(z_index)
            _View view = _View.create(c_view, self._scene_weakref())

        self._cache[z_index] = view
        return view

    def __setitem__(self, z_index, value):
        raise NotImplementedError
    
    def __iter__(self):
        cdef:
            int32_t z_index
            size_t size = self._get_c_views().size()
            int32_t begin = -size // 2
            int32_t end = size // 2

        for z_index in range(begin, end):
            yield self[z_index]


@cython.final
cdef class _View(_SceneResource):
    cdef:
        CView* _c_view
        readonly _Camera camera
    
    def __str__(self):
        return f'View[{self.z_index}]'
    
    @staticmethod
    cdef _View create(CView* c_view, Scene scene):
        cdef _View view = _View.__new__(_View, scene)
        view._c_view = c_view
        view.camera = _Camera.create(&c_view.camera, scene)
        return view
    
    cdef CView* _get_c_view(self) except NULL:
        self._check_valid()
        return self._c_view
    
    @property
    def z_index(self):
        return self._get_c_view().z_index()

    @property
    def clear_color(self):
        return Color.from_c_color(self._get_c_view().clear_color())
    
    @clear_color.setter
    def clear_color(self, Color color):
        if color is None:
            self._get_c_view().reset_clear_color()
        else:
            self._get_c_view().clear_color(color.c_color)

    @property
    def origin(self):
        return Vector.from_c_vector(
            <CDVec2>self._get_c_view().origin()
        )

    @origin.setter
    def origin(self, Vector origin not None):
        self._get_c_view().origin(
            <CIVec2>origin.c_vector
        )

    @property
    def dimensions(self):
        return Vector.from_c_vector(
            <CDVec2>self._get_c_view().dimensions()
        )

    @dimensions.setter
    def dimensions(self, Vector dimensions not None):
        assert dimensions.c_vector.x > 0
        assert dimensions.c_vector.y > 0

        self._get_c_view().dimensions(
            <CUVec2>dimensions.c_vector
        )
    

@cython.final
cdef class _Camera(_SceneResource):
    cdef CCamera* _c_camera

    @staticmethod
    cdef _Camera create(CCamera* c_camera, Scene scene):
        cdef _Camera camera = _Camera.__new__(_Camera, scene)
        camera._c_camera = c_camera
        return camera
    
    cdef CCamera* _get_c_camera(self) except NULL:
        self._check_valid()
        return self._c_camera
    
    @property
    def position(self):
        return Vector.from_c_vector(
            self._get_c_camera().position()
        )

    @position.setter
    def position(self, Vector vector not None):
        self._get_c_camera().position(vector.c_vector)

    @property
    def rotation(self):
        return self._get_c_camera().rotation()

    @rotation.setter
    def rotation(self, double value):
        self._get_c_camera().rotation(value)

    @property
    def rotation_degrees(self):
        return degrees(self._ger_c_camera().rotation())

    @rotation_degrees.setter
    def rotation_degrees(self, double value):
        self._get_c_camera().rotation(radians(value))

    @property
    def scale(self):
        return Vector.from_c_vector(self._get_c_camera().scale())

    @scale.setter
    def scale(self, Vector vector not None):
        self._c_camera.scale(vector.c_vector)

    def unproject_position(self, Vector position not None):
        return Vector.from_c_vector(
            self._get_c_camera().unproject_position(position.c_vector)
        )
