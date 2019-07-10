from libc.stdint cimport uint16_t, uint32_t, uint64_t
from libcpp cimport bool

from .vectors cimport CVector
from .exceptions cimport raise_py_error


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
        CSprite load(const char* path, uint64_t flags) \
            except +raise_py_error


        CSprite crop(CVector new_origin, CVector new_dimensions) \
            except +raise_py_error
        bint has_texture() \
            except +raise_py_error
        CVector get_size() \
            except +raise_py_error
