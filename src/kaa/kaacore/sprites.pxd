from libcpp cimport bool
from libcpp.vector cimport vector
from libcpp.string cimport string

from .vectors cimport CDVec2, CColor
from .textures cimport CTexture
from .exceptions cimport raise_py_error
from .resources cimport CResourceReference



cdef extern from "kaacore/sprites.h" namespace "kaacore" nogil:
    cdef cppclass CSprite "kaacore::Sprite":
        CDVec2 origin
        CDVec2 dimensions
        CResourceReference[CTexture] texture

        CSprite()
        CSprite(CResourceReference[CTexture]& texture)
        bool operator==(const CSprite&)

        @staticmethod
        CSprite load(const string& path) except +raise_py_error
        CSprite crop(CDVec2 new_origin, CDVec2 new_dimensions) \
            except +raise_py_error
        bint has_texture() \
            except +raise_py_error
        CDVec2 get_size() \
            except +raise_py_error
        bool can_query() except +raise_py_error
        CColor query_pixel(CDVec2 position) except +raise_py_error

    vector[CSprite] c_split_spritesheet "kaacore::split_spritesheet"(
        const CSprite& spritesheet, const CDVec2 frame_dimensions,
        const size_t frames_offset, const size_t frames_count,
        const CDVec2 frame_padding
    ) except +raise_py_error
