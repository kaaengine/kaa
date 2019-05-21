from .kaacore.audio cimport CSound, CMusic


cdef class Sound:
    cdef CSound c_sound

    cdef void _attach_c_sound(self, const CSound& c_sound):
        self.c_sound = c_sound

    def __init__(self, str sound_filepath, double volume=1.):
        self._attach_c_sound(CSound.load(sound_filepath.encode(), volume))

    def play(self, double volume=1.):
        self.c_sound.play(volume)


cdef Sound get_sound_wrapper(const CSound& c_sound):
    cdef Sound sound = Sound.__new__(Sound)
    sound._attach_c_sound(c_sound)
    return sound


cdef class Music:
    cdef CMusic c_music

    cdef void _attach_c_music(self, const CMusic& c_music):
        self.c_music = c_music

    def __init__(self, str music_filepath, double volume=1.):
        self._attach_c_music(CMusic.load(music_filepath.encode(), volume))

    def play(self):
        self.c_music.play()


cdef Music get_music_wrapper(const CMusic& c_music):
    cdef Music music = Music.__new__(Music)
    music._attach_c_music(c_music)
    return music
