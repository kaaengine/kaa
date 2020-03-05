from libc.stdint cimport uint16_t, uint32_t, uint64_t
from libcpp cimport bool
from libcpp.vector cimport vector

from .vectors cimport CVector
from .exceptions cimport raise_py_error


cdef extern from "kaacore/sprites.h" nogil:
    cdef cppclass CSprite "kaacore::Sprite":
        CVector origin
        CVector dimensions

        CSprite()

        @staticmethod
        CSprite load(const char* path, uint64_t flags) \
            except +raise_py_error

        bool operator==(const CSprite&)

        CSprite crop(CVector new_origin, CVector new_dimensions) \
            except +raise_py_error
        bint has_texture() \
            except +raise_py_error
        CVector get_size() \
            except +raise_py_error

    vector[CSprite] c_split_spritesheet "kaacore::split_spritesheet"(
        const CSprite& spritesheet, const CVector frame_dimensions,
        const size_t frames_offset, const size_t frames_count,
        const CVector frame_padding
    ) except +raise_py_error
