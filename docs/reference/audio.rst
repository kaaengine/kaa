:mod:`audio` --- Sound effects and music
========================================
.. module:: audio
    :synopsis: Sound effects and music

:class:`Sound` reference
------------------------

.. class:: Sound(sound_filepath, volume=1.0)

   A :class:`Sound` object represents a sound effect. Multiple sound effects can be played simultaneously.

   sound_filepath argument must point to a sound file in a compatible format. Currently supported formats are:

   * wav
   * ogg

   volume paramter must be a value between 0 and 1

Instance properties:

.. attribute:: Sound.volume

    Gets or sets a default volume of the sound effect.

Instance methods:

.. method:: Sound.play(volume=1.0)

    Plays the sound effect.

    Volume is a value between 0 and 1. The volume is modified by the master sound volume level setting.

    Refer to :class:`engine.AudioManager` documentation on how to set the master volume for sounds.

    Multiple sound effects can be played simultaneously, up to a limit set on the
    :ref:`AudioManager.mixing_channels <AudioManager.mixing_channels>` property.

    The play() method is a simple "fire and forget" mechanism. It does not allow you to stop, pause or resume the
    sound. If you need more control on how the sound effects playback, use the :class:`SoundPlayback` wrapper.


:class:`SoundPlayback` reference
--------------------------------

.. class:: SoundPlayback(sound, volume=1.0)

    A wrapper class for :class:`Sound` objects, offering more control over sound effects playback.

    The :code:`sound` parameter must be a :class:`Sound` instance.

    Volume must be a value between 0 and 1.

Instance properties:

.. attribute:: SoundPlayback.sound

    Read only. Returns the wrapped :class:`Sound` instance

.. attribute:: SoundPlayback.status

    Read only. Returns the sound status, as :class:`AudioStatus` enum value.

.. attribute:: SoundPlayback.is_playing

    Read only. Returns :code:`True` if the sound is playing.

.. attribute:: SoundPlayback.is_paused

    Read only. Returns :code:`True` if the sound is paused.

.. attribute:: SoundPlayback.volume

    Gets or sets the volume. Must be a number between 0 and 1.

Instance methods:

.. method:: SoundPlayback.play(loops=1)

    Plays the sound effect.

    The :code:`loops` parameter is how many times the sound should play. Set to 0 to play the sound in the infinite
    loop.

    Multiple sound effects can be played simultaneously, up to a limit set on the
    :ref:`AudioManager.mixing_channels <AudioManager.mixing_channels>` property.

    Use :meth:`stop()`, :meth:`pause()` and :meth:`resume()` methods to control the sound playback.

.. method:: SoundPlayback.stop()

    Stops the sound playback if it's playing or paused.

.. method:: SoundPlayback.pause()

    Pauses the sound playback if it's playing.

.. method:: SoundPlayback.resume()

    Resumes the sound playback if it's paused.


:class:`Music` reference
------------------------

.. class:: Music(music_filepath, volume=1.0)

    A :class:`Music` object represents a single music track. There's more control over playing Music tracks than Sounds
    as you can pause, resume or stop them on demand. Only one music track can be played at a time.

    music_filepath argument must point to a soundtrack file in a compatible format. Currently supported formats are:

    * wav
    * ogg

Instance properties:

.. attribute:: Music.is_paused

    Read only. Returns bool value indicating if the music track is paused.

.. attribute:: Music.is_playing

    Read only. Returns bool value indicating if the music track is playing. To find out when a music track stopped playing
    use

.. attribute:: Music.volume

    Gets or sets a default volume of the music track.

Class methods

.. classmethod:: Music.get_current()

    Returns :class:`Music` instance currently being played

Instance properties

.. attribute:: Music.status

    Read only. Returns the status of the Music track, as :class:`AudioStatus` enum value.

.. attribute:: Music.is_playing

    Read only. Returns :code:`True` if the music is playing.

.. attribute:: Music.is_paused

    Read only. Returns :code:`True` if the music is paused.

Instance methods

.. method:: Music.play(volume=1.0)

    Starts playing the music track. If another music track is playing it is automatically stopped.

    Volume is a value between 0 and 1. The volume is modified by the master music volume level setting.

    Refer to :class:`engine.AudioManager` documentation on how to set the master volume for music.

.. method:: Music.pause()

    Pauses the music track currently being played. Can be resumed with :meth:`Music.resume()` method

.. method:: Music.resume()

    Resumes music track paused by :meth:`Music.pause()`. If the track is not paused, it does nothing.

.. method:: Music.stop()

    Stops the music track.


:class:`AudioStatus` reference
------------------------------

.. class:: AudioStatus

    Enum type used for referencing sound or music status when working with :class:`Music`, :class:`Sound` and
    :class:`SoundPlayback` objects. It has the following values:

    * :code:`AudioStatus.playing`
    * :code:`AudioStatus.paused`
    * :code:`AudioStatus.stopped`