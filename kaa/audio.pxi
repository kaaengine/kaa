from enum import IntEnum

cimport cython

from libcpp.memory cimport unique_ptr

from .kaacore.engine cimport get_c_engine
from .kaacore.audio cimport (
    CAudioManager, CSound, CSoundPlayback, CMusic, CAudioStatus
)
from .kaacore.hashing cimport c_calculate_hash

DEF SOUND_FREELIST_SIZE = 30
DEF SOUND_PLAYBACK_FREELIST_SIZE = 10
DEF MUSIC_FREELIST_SIZE = 10


class AudioStatus(IntEnum):
    playing = <uint8_t>CAudioStatus.playing
    paused = <uint8_t>CAudioStatus.paused
    stopped = <uint8_t>CAudioStatus.stopped


@cython.freelist(SOUND_FREELIST_SIZE)
@cython.final
cdef class Sound:
    cdef CSound c_sound

    cdef void _attach_c_sound(self, const CSound& c_sound):
        self.c_sound = c_sound

    def __init__(self, str sound_filepath, double volume=1.):
        self._attach_c_sound(CSound.load(sound_filepath.encode(), volume))

    def __richcmp__(self, Sound other, op):
        if op == 2:
            return self.c_sound == other.c_sound
        elif op == 3:
            return not self.c_sound == other.c_sound
        else:
            return NotImplemented

    def __hash__(self):
        return c_calculate_hash[CSound](self.c_sound)

    @property
    def volume(self):
        return self.c_sound.volume()

    def play(self, double volume=1.):
        self.c_sound.play(volume)


cdef Sound get_sound_wrapper(const CSound& c_sound):
    cdef Sound sound = Sound.__new__(Sound)
    sound._attach_c_sound(c_sound)
    return sound


@cython.freelist(SOUND_PLAYBACK_FREELIST_SIZE)
@cython.final
cdef class SoundPlayback:
    cdef unique_ptr[CSoundPlayback] c_sound_playback

    def __cinit__(self, Sound sound not None, double volume=1.):
        self.c_sound_playback = unique_ptr[CSoundPlayback](
            new CSoundPlayback(sound.c_sound, volume)
        )

    @property
    def sound(self):
        return get_sound_wrapper(self.c_sound_playback.get().sound())

    @property
    def status(self):
        return AudioStatus(<uint8_t>self.c_sound_playback.get().status())

    @property
    def volume(self):
        return self.c_sound_playback.get().volume()

    @volume.setter
    def volume(self, double vol):
        self.c_sound_playback.get().volume(vol)

    @property
    def is_playing(self):
        return self.c_sound_playback.get().is_playing()

    def play(self, *, int loops=1):
        self.c_sound_playback.get().play(loops)

    @property
    def is_paused(self):
        return self.c_sound_playback.get().is_paused()

    def pause(self):
        return self.c_sound_playback.get().pause()

    def resume(self):
        return self.c_sound_playback.get().resume()

    def stop(self):
        return self.c_sound_playback.get().stop()


@cython.freelist(MUSIC_FREELIST_SIZE)
@cython.final
cdef class Music:
    cdef CMusic c_music

    cdef void _attach_c_music(self, const CMusic& c_music):
        self.c_music = c_music

    def __init__(self, str music_filepath, double volume=1.):
        self._attach_c_music(CMusic.load(music_filepath.encode(), volume))

    def __richcmp__(self, Music other, op):
        if op == 2:
            return self.c_music == other.c_music
        elif op == 3:
            return not self.c_music == other.c_music
        else:
            return NotImplemented

    def __hash__(self):
        return c_calculate_hash[CMusic](self.c_music)

    @staticmethod
    def get_current():
        return get_music_wrapper(CMusic.get_current())

    @property
    def volume(self):
        return self.c_music.volume()

    @property
    def status(self):
        return AudioStatus(<uint8_t>self.c_music.status())

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
