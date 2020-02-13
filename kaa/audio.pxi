from enum import IntEnum

cimport cython

from libcpp.memory cimport unique_ptr

from .kaacore.engine cimport get_c_engine
from .kaacore.audio cimport (
    CAudioManager, CSound, CSoundPlayback, CMusic, CAudioState
)

DEF SOUND_FREELIST_SIZE = 30
DEF SOUND_PLAYBACK_FREELIST_SIZE = 10
DEF MUSIC_FREELIST_SIZE = 10


class AudioState(IntEnum):
    playing = <uint8_t>CAudioState.playing
    paused = <uint8_t>CAudioState.paused
    stopped = <uint8_t>CAudioState.stopped


@cython.freelist(SOUND_FREELIST_SIZE)
@cython.final
cdef class Sound:
    cdef CSound c_sound

    cdef void _attach_c_sound(self, const CSound& c_sound):
        self.c_sound = c_sound

    def __init__(self, str sound_filepath, double volume=1.):
        self._attach_c_sound(CSound.load(sound_filepath.encode(), volume))

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
    def state(self):
        return AudioState(<uint8_t>self.c_sound_playback.get().state())

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

    @staticmethod
    def get_current():
        return get_music_wrapper(CMusic.get_current())

    @staticmethod
    def get_state():
        return AudioState(<uint8_t>CMusic.get_state())

    @property
    def volume(self):
        return self.c_music.volume()

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
    cdef CAudioManager* _get_c_audio_manager(self):
        cdef CEngine* c_engine = get_c_engine()
        assert c_engine != NULL
        cdef CAudioManager* c_audio_manager = c_engine.audio_manager.get()
        assert c_audio_manager != NULL
        return c_audio_manager

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
