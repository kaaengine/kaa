from enum import IntEnum

cimport cython

from .kaacore.engine cimport get_c_engine
from .kaacore.audio cimport CAudioManager, CSound, CMusic, CMusicState

DEF SOUND_FREELIST_SIZE = 30
DEF MUSIC_FREELIST_SIZE = 10


class MusicState(IntEnum):
    playing = <uint8_t>CMusicState.playing
    paused = <uint8_t>CMusicState.paused
    stopped = <uint8_t>CMusicState.stopped


@cython.freelist(SOUND_FREELIST_SIZE)
cdef class Sound:
    cdef CSound c_sound

    cdef void _attach_c_sound(self, const CSound& c_sound):
        self.c_sound = c_sound

    def __init__(self, str sound_filepath, double volume=1.):
        self._attach_c_sound(CSound.load(sound_filepath.encode(), volume))

    @property
    def volume(self):
        return self.c_sound.volume()

    @volume.setter
    def volume(self, double vol):
        self.c_sound.volume(vol)

    def play(self, double volume=1.):
        self.c_sound.play(volume)


cdef Sound get_sound_wrapper(const CSound& c_sound):
    cdef Sound sound = Sound.__new__(Sound)
    sound._attach_c_sound(c_sound)
    return sound


@cython.freelist(MUSIC_FREELIST_SIZE)
cdef class Music:
    cdef CMusic c_music

    cdef void _attach_c_music(self, const CMusic& c_music):
        self.c_music = c_music

    def __init__(self, str music_filepath, double volume=1.):
        self._attach_c_music(CMusic.load(music_filepath.encode(), volume))

    @staticmethod
    def get_current():
        return get_music_wrapper(CMusic.get_current())

    @staticmethod
    def get_state():
        return MusicState(<uint8_t>CMusic.get_state())

    @property
    def volume(self):
        return self.c_music.volume()

    @volume.setter
    def volume(self, double vol):
        self.c_music.volume(vol)

    @property
    def is_playing(self):
        return self.c_music.is_playing()

    def play(self, double volume=1.):
        self.c_music.play(volume)

    @property
    def is_paused(self):
        return self.c_music.is_paused()

    def pause(self):
        return self.c_music.pause()

    def resume(self):
        return self.c_music.resume()

    def stop(self):
        return self.c_music.stop()


cdef Music get_music_wrapper(const CMusic& c_music):
    cdef Music music = Music.__new__(Music)
    music._attach_c_music(c_music)
    return music


@cython.final
cdef class _AudioManager:
    cdef CAudioManager* _get_c_audio_manager(self) except NULL:
        return get_c_engine().audio_manager.get()

    @property
    def master_volume(self):
        return self._get_c_audio_manager().master_volume()

    @master_volume.setter
    def master_volume(self, double vol):
        self._get_c_audio_manager().master_volume(vol)

    @property
    def master_sound_volume(self):
        return self._get_c_audio_manager().master_sound_volume()

    @master_sound_volume.setter
    def master_sound_volume(self, double vol):
        self._get_c_audio_manager().master_sound_volume(vol)

    @property
    def master_music_volume(self):
        return self._get_c_audio_manager().master_music_volume()

    @master_music_volume.setter
    def master_music_volume(self, double vol):
        self._get_c_audio_manager().master_music_volume(vol)

    @property
    def mixing_channels(self):
        return self._get_c_audio_manager().mixing_channels()

    @mixing_channels.setter
    def mixing_channels(self, int ch):
        self._get_c_audio_manager().mixing_channels(ch)
