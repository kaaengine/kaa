from libcpp cimport bool

from .kaacore.sprites cimport CSprite


cdef class Sprite:
    cdef CSprite _c_sprite_stack
    cdef CSprite* c_sprite_ptr

    def __cinit__(self):
        self.c_sprite_ptr = NULL

    cdef void _set_stack_c_sprite(self):
        assert self.c_sprite_ptr == NULL
        self.c_sprite_ptr = &self._c_sprite_stack

    cdef void _set_ext_c_sprite(self, CSprite* c_new_sprite):
        assert self.c_sprite_ptr == NULL
        self.c_sprite_ptr = c_new_sprite

    def __init__(self, str path, Vector origin=Vector(0., 0.),
                 Vector dimensions=Vector(0., 0.), **options):
        self._set_stack_c_sprite()
        cdef CSprite c_sprite_full = CSprite.load(path.encode(), 0)
        if origin.is_zero() and dimensions.is_zero():
            self.c_sprite_ptr[0] = c_sprite_full
        else:
            self.c_sprite_ptr[0] = c_sprite_full.crop(
                origin.c_vector, dimensions.c_vector
            )
        self.setup(**options)

    def crop(self, Vector origin, Vector dimensions):
        assert self.c_sprite_ptr != NULL
        cdef Sprite new_sprite = Sprite.__new__(Sprite)
        new_sprite._set_stack_c_sprite()
        new_sprite.c_sprite_ptr[0] = self.c_sprite_ptr.crop(
                origin.c_vector, dimensions.c_vector
        )
        return new_sprite

    def setup(self, **options):
        if 'frame_dimensions' in options:
            self.frame_dimensions = options.pop('frame_dimensions')
        if 'frame_offset' in options:
            self.frame_offset = options.pop('frame_offset')
        if 'frame_count' in options:
            self.frame_count = options.pop('frame_count')
        if 'frame_current' in options:
            self.frame_current = options.pop('frame_current')
        if 'animation_frame_duration' in options:
            self.animation_frame_duration = options.pop('animation_frame_duration')
        if 'animation_loop' in options:
            self.animation_loop = options.pop('animation_loop')

        if options:
            raise ValueError('Passed unknown options to {}: {}'.format(
                self.__class__.__name__, options.keys()
            ))

    @property
    def origin(self):
        return Vector.from_c_vector(self.c_sprite_ptr.origin)

    @property
    def dimensions(self):
        return Vector.from_c_vector(self.c_sprite_ptr.dimensions)

    @property
    def frame_dimensions(self):
        return Vector.from_c_vector(self.c_sprite_ptr.frame_dimensions)

    @frame_dimensions.setter
    def frame_dimensions(self, Vector dimensions):
        self.c_sprite_ptr.frame_dimensions = dimensions.c_vector

    @property
    def frame_offset(self):
        return self.c_sprite_ptr.frame_offset

    @frame_offset.setter
    def frame_offset(self, int value):
        self.c_sprite_ptr.frame_offset = value

    @property
    def frame_count(self):
        return self.c_sprite_ptr.frame_count

    @frame_count.setter
    def frame_count(self, int value):
        self.c_sprite_ptr.frame_count = value

    @property
    def frame_current(self):
        return self.c_sprite_ptr.frame_current

    @frame_current.setter
    def frame_current(self, int value):
        self.c_sprite_ptr.frame_current = value

    @property
    def animation_frame_duration(self):
        return self.c_sprite_ptr.animation_frame_duration

    @animation_frame_duration.setter
    def animation_frame_duration(self, int value):
        self.c_sprite_ptr.animation_frame_duration = value

    @property
    def animation_loop(self):
        return self.c_sprite_ptr.animation_loop

    @animation_loop.setter
    def animation_loop(self, bool value):
        self.c_sprite_ptr.animation_loop = value

    @property
    def size(self):
        return Vector.from_c_vector(self.c_sprite_ptr.get_size())


cdef Sprite get_sprite_wrapper(CSprite* c_sprite):
    cdef Sprite sprite = Sprite.__new__(Sprite)
    sprite._set_ext_c_sprite(c_sprite)
    return sprite
