from libcpp cimport bool

from .exceptions cimport raise_py_error


cdef extern from "kaacore/audio.h" nogil:
    cdef cppclass CSound "kaacore::Sound":
        CSound()

        @staticmethod
        CSound load(const char* path, double volume) \
            except +raise_py_error

        void play(double volume) \
            except +raise_py_error


    cdef cppclass CMusic "kaacore::Music":
        CMusic()

        @staticmethod
        CMusic load(const char* path, double volume) \
            except +raise_py_error

        @staticmethod
        CMusic get_current() \
            except +raise_py_error

        bool is_playing() \
            except +raise_py_error
        void play() \
            except +raise_py_error
