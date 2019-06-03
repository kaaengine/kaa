from libc.stdint cimport uint16_t, uint32_t, uint64_t
from libcpp cimport bool

from .vectors cimport CVector


cdef extern from "kaacore/sprites.h" nogil:
    cdef cppclass CSprite "kaacore::Sprite":
        CVector origin
        CVector dimensions
        CVector frame_dimensions

        uint16_t frame_offset
        uint16_t frame_count
        uint16_t frame_current

        uint16_t animation_frame_duration
        uint32_t animation_time_acc
        bool animation_loop
        bool auto_animate

        CSprite()

        @staticmethod
        CSprite load(const char* path, uint64_t flags)


        CSprite crop(CVector new_origin, CVector new_dimensions)
        bint has_texture()
        CVector get_size()
