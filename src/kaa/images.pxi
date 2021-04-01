from .kaacore.images cimport CImage
from .kaacore.hashing cimport c_calculate_hash
from .kaacore.resources cimport CResourceReference

ctypedef CImage* CImage_ptr


cdef class Image:

    cdef CResourceReference[CImage] c_image

    @staticmethod
    cdef Image create(CResourceReference[CImage]& image):
        cdef Image instance = Image.__new__(Image)
        instance.c_image = image
        return instance

    def __init__(self, str path not None):
        self.c_image = CImage.load(path.encode(), 0)

    def __eq__(self, Image other):
        if other is None:
            return False

        return self.c_image == other.c_image

    def __hash__(self):
        return c_calculate_hash[CImage_ptr](self.c_image.get())

    @property
    def dimensions(self):
        return Vector.from_c_vector(self.c_image.get().get_dimensions())
