cimport cython

from libcpp cimport bool
from libcpp.vector cimport vector

from .kaacore.sprites cimport CSprite, c_split_spritesheet
from .kaacore.hashing cimport c_calculate_hash

DEF SPRITE_FREELIST_SIZE = 250


@cython.freelist(SPRITE_FREELIST_SIZE)
cdef class Sprite:
    cdef CSprite c_sprite

    @staticmethod
    cdef Sprite create(const CSprite& c_sprite):
        cdef Sprite sprite = Sprite.__new__(Sprite)
        sprite.c_sprite = c_sprite
        return sprite

    @staticmethod
    def from_texture(Texture texture not None):
        cdef:
            CSprite c_sprite = CSprite(texture.c_texture)
            Sprite instance = Sprite.__new__(Sprite)

        instance.c_sprite = c_sprite
        return instance

    def __init__(self, str path):
        self.c_sprite = CSprite.load(path.encode())

    def __eq__(self, Sprite other):
        return self.c_sprite == other.c_sprite

    def __hash__(self):
        return c_calculate_hash[CSprite](self.c_sprite)

    def crop(self, Vector origin, Vector dimensions):
        assert self.c_sprite.has_texture()
        return Sprite.create(self.c_sprite.crop(
            origin.c_vector, dimensions.c_vector
        ))

    @property
    def texture(self):
        return Texture.create(self.c_sprite.texture)

    @property
    def origin(self):
        return Vector.from_c_vector(self.c_sprite.origin)

    @property
    def dimensions(self):
        return Vector.from_c_vector(self.c_sprite.dimensions)

    @property
    def size(self):
        return Vector.from_c_vector(self.c_sprite.get_size())


def split_spritesheet(
    Sprite spritesheet, Vector frame_dimensions,
    size_t frames_offset=0, size_t frames_count=0,
    Vector frame_padding=Vector(0, 0),
):
    cdef vector[CSprite] c_sprites = c_split_spritesheet(
        spritesheet.c_sprite, frame_dimensions.c_vector,
        frames_offset, frames_count, frame_padding.c_vector
    )
    cdef CSprite c_sprite

    return [Sprite.create(c_sprite) for c_sprite in c_sprites]
