from .kaacore.textures cimport CTexture
from .kaacore.hashing cimport c_calculate_hash
from .kaacore.resources cimport CResourceReference

ctypedef CTexture* CTexture_ptr


cdef class Texture:

    cdef CResourceReference[CTexture] c_texture

    @staticmethod
    cdef Texture create(CResourceReference[CTexture]& texture):
        cdef Texture instance = Texture.__new__(Texture)
        instance.c_texture = texture
        return instance

    def __init__(self, str path not None):
        self.c_texture = CTexture.load(path.encode(), 0)

    def __eq__(self, Texture other):
        if other is None:
            return False

        return self.c_texture == other.c_texture

    def __hash__(self):
        return c_calculate_hash[CTexture_ptr](self.c_texture.get())

    @property
    def dimensions(self):
        return Vector.from_c_vector(self.c_texture.get().get_dimensions())
