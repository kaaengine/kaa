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

    Current kaa version does not support stopping sound effect currently being played. It does not publish an event
    when the sound stops playing either. This is to be implemented in the future, currently playing sounds is a
    "fire and forget" mode.


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

.. classmethod:: Music.get_state()

    TODO. This is not working, guys need to surface the enum type to return the Music state (playing, paused, stopped)

Instance methods

.. method:: Music.play(volume=1.0)

    Starts playing the music track. If another music track is playing it is automatically stopped.

    Volume is a value between 0 and 1. The volume is modified by the master music volume level setting.

    Refer to :class:`engine.AudioManager` documentation on how to set the master volume for music.

.. method:: Music.pause()

    Pauses the music track currently being played. Can be resumed with :meth:`Music.resume` method

.. method:: Music.resume()

    Resumes music track paused by :meth:`Music.pause`. If the track is not paused, it does nothing.

.. method:: Music.stop()

    Stops the music track.