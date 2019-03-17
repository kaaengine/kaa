from .kaacore.sprites cimport CSprite


cdef class AssetsLoader:
    def load_image(self, str path):
        cdef CSprite c_sprite = CSprite.load(path.encode(), 0)
        cdef Sprite py_sprite = Sprite.__new__(Sprite)
        py_sprite._set_stack_c_sprite()
        py_sprite.c_sprite_ptr[0] = c_sprite
        return py_sprite
