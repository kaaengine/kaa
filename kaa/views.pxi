import cython
from libc.stdint cimport int16_t, int32_t

from .kaacore.camera cimport CCamera
from .kaacore.views cimport CView, CViewsManager
from .kaacore.vectors cimport CVector, CIVector, CUVector


cdef class _ExternalResourceReference:
    cdef bint _c_is_valid

    def __cinit__(self):
        self._c_is_valid = True
    
    def __init__(self):
        raise RuntimeError(f'{self.__class__} must not be instantiated manually!')

    def __getattribute__(self, name):
        self._check_valid()
        return super().__getattribute__(name)
    
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
cdef class ViewsManager(_ExternalResourceReference):
    cdef:
        dict _cache
        CViewsManager* _c_views

    @staticmethod
    cdef ViewsManager create(CViewsManager* c_views):
        cdef ViewsManager views_manager = ViewsManager.__new__(ViewsManager)
        views_manager._c_views = c_views
        views_manager._cache = {}
        return views_manager
    
    cdef void _mark_invalid(self):
        self._c_is_valid = False
        cdef View view
        for view in self._cache.values():
            view._mark_invalid()

    def __getitem__(self, int16_t z_index):
        self._check_valid()

        try:
            return self._cache[z_index]
        except KeyError:
            pass
        
        cdef:
            CView* c_view = self._c_views.get(z_index)
            View view = View.create(c_view)

        self._cache[z_index] = view
        return view

    def __setitem__(self, z_index, value):
        raise NotImplementedError
    
    def __iter__(self):
        self._check_valid()

        cdef:
            int32_t z_index
            size_t size = self._c_views.size()
            int32_t begin = -size // 2
            int32_t end = size // 2

        for z_index in range(begin, end):
            yield self[z_index]


@cython.final
cdef class View(_ExternalResourceReference):
    cdef:
        CView* _c_view
        readonly Camera camera
    
    def __str__(self):
        return f'View[{self.z_index}]'
    
    @staticmethod
    cdef View create(CView* c_view):
        cdef View view = View.__new__(View)
        view._c_view = c_view
        view.camera = Camera.create(&c_view.camera)
        return view
    
    cdef void _mark_invalid(self):
        self._c_is_valid = False
        self.camera._mark_invalid()
    
    @property
    def z_index(self):
        return self._c_view.z_index()

    @property
    def clear_color(self):
        return Color.from_c_color(self._c_view.clear_color())
    
    @clear_color.setter
    def clear_color(self, Color color):
        if color is None:
            self._c_view.reset_clear_color()
        else:
            self._c_view.clear_color(color.c_color)

    @property
    def origin(self):
        return Vector.from_c_vector(
            <CVector>self._c_view.origin()
        )

    @origin.setter
    def origin(self, Vector origin not None):
        self._c_view.origin(
            <CIVector>origin.c_vector
        )

    @property
    def dimensions(self):
        return Vector.from_c_vector(
            <CVector>self._c_view.dimensions()
        )

    @dimensions.setter
    def dimensions(self, Vector dimensions not None):
        assert dimensions.c_vector.x > 0
        assert dimensions.c_vector.y > 0

        self._c_view.dimensions(
            <CUVector>dimensions.c_vector
        )
    

@cython.final
cdef class Camera(_ExternalResourceReference):
    cdef CCamera* _c_camera

    @staticmethod
    cdef Camera create(CCamera* c_camera):
        cdef Camera camera = Camera.__new__(Camera)
        camera._c_camera = c_camera
        return camera
    
    cdef void _mark_invalid(self):
        self._c_is_valid = False
    
    @property
    def position(self):
        return Vector.from_c_vector(self._c_camera.position())

    @position.setter
    def position(self, Vector vector not None):
        self._c_camera.position(vector.c_vector)

    @property
    def rotation(self):
        return self._c_camera.rotation()

    @rotation.setter
    def rotation(self, double value):
        self._c_camera.rotation(value)

    @property
    def rotation_degrees(self):
        return degrees(self._c_camera.rotation())

    @rotation_degrees.setter
    def rotation_degrees(self, double value):
        self._c_camera.rotation(radians(value))

    @property
    def scale(self):
        return Vector.from_c_vector(self._c_camera.scale())

    @scale.setter
    def scale(self, Vector vector not None):
        self._c_camera.scale(vector.c_vector)

    def unproject_position(self, Vector position not None):
        return Vector.from_c_vector(
            self._c_camera.unproject_position(position.c_vector)
        )
