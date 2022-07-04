import cython
import weakref
from libc.stdint cimport int16_t
from cpython.weakref cimport PyWeakref_NewRef

from .kaacore.camera cimport CCamera
from .kaacore.vectors cimport CDVec2, CIVec2, CUVec2
from .kaacore.viewports cimport (
    CViewport, CViewportsManager, min_viewport_z_index, max_viewport_z_index
)


@cython.final
cdef class _ViewportsManager(_SceneResource):
    cdef:
        object _scene_weakref
        CViewportsManager* c_viewports

    @staticmethod
    cdef _ViewportsManager create(Scene scene):
        cdef _ViewportsManager viewports_manager = _ViewportsManager.__new__(
            _ViewportsManager, scene
        )
        viewports_manager._scene_weakref = PyWeakref_NewRef(scene, None)
        viewports_manager.c_viewports = &scene.c_scene.get().viewports
        return viewports_manager

    cdef CViewportsManager* get_c_viewports(self) except NULL:
        self.check_valid()
        return self.c_viewports

    def __getitem__(self, int16_t z_index):
        cdef CViewport* c_viewport = self.get_c_viewports().get(z_index)
        return _Viewport.create(c_viewport, self._scene_weakref())

    def __setitem__(self, z_index, value):
        raise NotImplementedError

    @cython.wraparound(False)
    @cython.boundscheck(False)
    def __iter__(self):
        cdef int16_t z_index
        for z_index in range(min_viewport_z_index, max_viewport_z_index + 1):
            yield self[z_index]

    def __len__(self):
        return self.get_c_views().size()


@cython.final
cdef class _Viewport(_SceneResource):
    cdef:
        CViewport* c_viewport
        readonly _Camera camera

    def __str__(self):
        return f'Viewport[{self.z_index}]'

    @staticmethod
    cdef _Viewport create(CViewport* c_viewport, Scene scene):
        cdef _Viewport viewport = _Viewport.__new__(_Viewport, scene)
        viewport.c_viewport = c_viewport
        viewport.camera = _Camera.create(&c_viewport.camera, scene)
        return viewport

    cdef CViewport* get_c_viewport(self) except NULL:
        self.check_valid()
        return self.c_viewport

    @property
    def z_index(self):
        return self.get_c_viewport().z_index()

    @property
    def origin(self):
        return Vector.from_c_vector(
            <CDVec2>self.get_c_viewport().origin()
        )

    @origin.setter
    def origin(self, Vector origin not None):
        self.get_c_viewport().origin(
            <CIVec2>origin.c_vector
        )

    @property
    def dimensions(self):
        return Vector.from_c_vector(
            <CDVec2>self.get_c_viewport().dimensions()
        )

    @dimensions.setter
    def dimensions(self, Vector dimensions not None):
        assert dimensions.c_vector.x > 0
        assert dimensions.c_vector.y > 0

        self.get_c_viewport().dimensions(
            <CUVec2>dimensions.c_vector
        )


@cython.final
cdef class _Camera(_SceneResource):
    cdef CCamera* c_camera

    @staticmethod
    cdef _Camera create(CCamera* c_camera, Scene scene):
        cdef _Camera camera = _Camera.__new__(_Camera, scene)
        camera.c_camera = c_camera
        return camera

    cdef CCamera* get_c_camera(self) except NULL:
        self.check_valid()
        return self.c_camera

    @property
    def position(self):
        return Vector.from_c_vector(
            self.get_c_camera().position()
        )

    @position.setter
    def position(self, Vector vector not None):
        self.get_c_camera().position(vector.c_vector)

    @property
    def rotation(self):
        return self.get_c_camera().rotation()

    @rotation.setter
    def rotation(self, double value):
        self.get_c_camera().rotation(value)

    @property
    def rotation_degrees(self):
        return degrees(self.get_c_camera().rotation())

    @rotation_degrees.setter
    def rotation_degrees(self, double value):
        self.get_c_camera().rotation(radians(value))

    @property
    def scale(self):
        return Vector.from_c_vector(self.get_c_camera().scale())

    @scale.setter
    def scale(self, Vector vector not None):
        self.c_camera.scale(vector.c_vector)

    def unproject_position(self, Vector position not None):
        return Vector.from_c_vector(
            self.get_c_camera().unproject_position(position.c_vector)
        )

    @property
    def visible_area_bounding_box(self):
        return BoundingBox.create(self.get_c_camera().visible_area_bounding_box())
