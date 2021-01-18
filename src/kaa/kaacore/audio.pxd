from libcpp cimport bool
from libc.stdint cimport uint16_t

from .exceptions cimport raise_py_error


cdef extern from "kaacore/audio.h" namespace "kaacore" nogil:
    cdef enum CAudioStatus "kaacore::AudioStatus":
        playing "kaacore::AudioStatus::playing",
        paused "kaacore::AudioStatus::paused",
        stopped "kaacore::AudioStatus::stopped",


    cdef cppclass CSound "kaacore::Sound":
        CSound()

        @staticmethod
        CSound load(const char* path, double volume) \
            except +raise_py_error

        bool operator==(const CSound&)

        void play(double volume) \
            except +raise_py_error

        double volume() except +raise_py_error


    cdef cppclass CSoundPlayback "kaacore::SoundPlayback":
        CSoundPlayback(const CSound& sound, double volume) \
            except +raise_py_error

        CSound sound() except +raise_py_error

        double volume() except +raise_py_error
        void volume(const double) except +raise_py_error

        CAudioStatus status() except +raise_py_error
        bool is_playing() except +raise_py_error
        void play(int loops) except +raise_py_error

        bool is_paused() except +raise_py_error
        bool pause() except +raise_py_error
        bool resume() except +raise_py_error
        bool stop() except +raise_py_error


    cdef cppclass CMusic "kaacore::Music":
        CMusic()

        @staticmethod
        CMusic load(const char* path, double volume) \
            except +raise_py_error

        @staticmethod
        CMusic get_current() \
            except +raise_py_error

        bool operator==(const CMusic&)

        double volume() except +raise_py_error

        CAudioStatus status() except +raise_py_error
        bool is_playing() \
            except +raise_py_error
        void play(double volume) \
            except +raise_py_error

        bool is_paused() except +raise_py_error
        bool pause() except +raise_py_error
        bool resume() except +raise_py_error
        bool stop() except +raise_py_error

    cdef cppclass CAudioManager "kaacore::AudioManager":
        double master_volume() except +raise_py_error
        void master_volume(const double vol) except +raise_py_error

        double master_sound_volume() except +raise_py_error
        void master_sound_volume(const double vol) except +raise_py_error

        double master_music_volume() except +raise_py_error
        void master_music_volume(const double vol) except +raise_py_error

        uint16_t mixing_channels() except +raise_py_error
        void mixing_channels(const uint16_t channels) except +raise_py_error
