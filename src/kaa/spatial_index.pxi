cimport cython

from .kaacore.spatial_index cimport CSpatialIndex


@cython.final
cdef class _SpatialIndexManager(_SceneResource):
    cdef CSpatialIndex* c_spatial_index

    @staticmethod
    cdef _SpatialIndexManager create(Scene scene):
        cdef _SpatialIndexManager spatial_index_manager = _SpatialIndexManager.__new__(
            _SpatialIndexManager, scene
        )
        spatial_index_manager.c_spatial_index = &scene.c_scene.get().spatial_index
        return spatial_index_manager

    cdef CSpatialIndex* get_c_spatial_index(self) except NULL:
        self.check_valid()
        return self.c_spatial_index

    def query_bounding_box(self, BoundingBox bbox not None, bool include_shapeless=True):
        return [
            get_node_wrapper(c_node_ptr)
            for c_node_ptr in self.get_c_spatial_index().query_bounding_box(
                bbox.c_bounding_box, include_shapeless
            )
        ]

    def query_point(self, Vector point not None):
        return [
            get_node_wrapper(c_node_ptr)
            for c_node_ptr in self.get_c_spatial_index().query_point(
                point.c_vector
            )
        ]
