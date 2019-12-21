Part 6: Sound effects and music
===============================

In this chapter we'll add sound effects and music to the game.

Loading sound effects from files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Loading sound effect from file is easy:

.. code-block:: python

    from kaa.audio import Sound
    my_sound = Sound('/path/to/sound.wav')

Currently supported sound formats are:

* wav
* ogg

Playing sound effect
~~~~~~~~~~~~~~~~~~~~

To play the sound effect:

.. code-block:: python

    my_sound.play(volume=0.9) # volume parameter ranging from 0 to 1, default is 1

You can play many sound effects simultaneously. There is a max limit of simultaneous sound, default is .... TODO. To
change the limit: .... TODO

.. note::

    Setting max limit to a very large number and playing very large number of sounds simultaneously
    may degrate performace of your game.

Stopping sound effect being played
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When you call :code:`play()` on a :code:`Sound`, kaa will play the whole sound. If you want to stop playing
the sound effect manually, you need to wait until next version of kaa because stopping sound effects is not
yet implemented.

Loading music files from files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Loading music tracks is very similar to loading sound effects:

.. code-block:: python

    from kaa.audio import Music
    my_music_track = Music('/path/to/music_track.wav')

Currently supported music formats are:

* wav
* ogg

Playing music track
~~~~~~~~~~~~~~~~~~~

To play the music track call :code:`play` on your :code:`Music` object:

.. code-block:: python

    my_music_track.play()  # no volume?


You can play only one music track at a time. Playing new music track automatically stops the current track being played.

Stopping music track
~~~~~~~~~~~~~~~~~~~~

If you want to just stop the current track being played without replacing it with a new track:

.. code-block:: python

    from kaa.audio import Music
    Music.get_current().stop()

Knowing when music track has ended
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Typically you will like to know when the current music track has ended so you can select a new one. To do
this look for the audio events in the Scene's :code:`events()` list:

.. code-block:: python

    class MyScene(Scene):

        def update(dt)

            for event in self.input.events():
                if event.audio: # check if this is audio event
                    if event.music_finished():
                        # do something when the track has finished playing ...

Full example
~~~~~~~~~~~~

Let's use the sound and music in our tutorial game.

First, let's load all assets from files first, in our :code:`AssetsController`

.. code-block:: python
    :caption: controllers/assets_controller.py

    from kaa.audio import Sound, Music

    class AssetsController:

        def __init__(self):

            # ..... rest of the function .....

            # Load all sounds
            self.mg_shot_sound = Sound(os.path.join('assets', 'sfx', 'mg-shot.wav'))
            self.force_gun_shot_sound = Sound(os.path.join('assets', 'sfx', 'force-gun-shot.wav'))
            self.grenade_launcher_shot_sound = Sound(os.path.join('assets', 'sfx', 'grenade-launcher-shot.wav'))
            self.explosion_sound = Sound(os.path.join('assets', 'sfx', 'explosion.wav'))

            # Load all music tracks
            self.music_track_1 = Music(os.path.join('assets', 'music', 'track_1.wav'))


Let's play music when the game starts.

.. code-block:: python
    :caption: main.py

    with Engine(virtual_resolution=Vector(settings.VIEWPORT_WIDTH, settings.VIEWPORT_HEIGHT)) as engine:
        # initialize global controllers and remember them in the registry
        registry.global_controllers.assets_controller = AssetsController()
        # play music
        registry.global_controllers.assets_controller.music_track_1.play()

        # .... rest of the code ....

.. note::

    main.py isn't the best place to put this code. The music will stop playing after the track ends.
    To make it more usable maybe we should have a :code:`MusicController` to manage
    tracks, and take care of starting new track when the previous ends? We'll leave this task to you :)


Let's play shooting sounds for the guns we have in the game:

.. code-block:: python
    :caption: objects/weapons/force_gun.py

    class ForceGun(WeaponBase):

        def shoot_bullet(self):
            # .... rest of the function ....

            # play shooting sound
            registry.global_controllers.assets_controller.force_gun_shot_sound.play()


.. code-block:: python
    :caption: objects/weapons/grenade_launcher.py


    class GrenadeLauncher(WeaponBase):

        def shoot_bullet(self):
            # .... rest of the function ....

            # play shooting sound
            registry.global_controllers.assets_controller.grenade_launcher_shot_sound.play()


.. code-block:: python
    :caption: objects/weapons/machine_gun.py

    class MachineGun(WeaponBase):

        def shoot_bullet(self):
            # .... rest of the function ....

            # play shooting sound
            registry.global_controllers.assets_controller.mg_shot_sound.play()


And the explosion sound:

.. code-block:: python
    :caption: controllers/enemies_controller.py

    class EnemiesController:

        def apply_explosion_effects(self, explosion_center, damage_at_center=40, blast_radius=150,
                                    pushback_force_at_center=500, pushback_radius=300):
            # play explosion sound
            registry.global_controllers.assets_controller.explosion_sound.play()
            # .... rest of the function ....


Run the game and enjoy the experience with sounds and music. When you're ready, move on to the
:doc:`part 7 of the tutorial </tutorial/part07>` where we'll learn how to draw text.