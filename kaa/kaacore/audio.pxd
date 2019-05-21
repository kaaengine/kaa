from libcpp cimport bool


cdef extern from "kaacore/audio.h" nogil:
    cdef cppclass CSound "kaacore::Sound":
        CSound()

        @staticmethod
        CSound load(const char* path, double volume)

        void play(double volume)


    cdef cppclass CMusic "kaacore::Music":
        CMusic()

        @staticmethod
        CMusic load(const char* path, double volume)

        @staticmethod
        CMusic get_current();

        bool is_playing()
        void play()
