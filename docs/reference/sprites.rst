:mod:`sprites` --- Using image assets
=====================================
.. module:: sprites
    :synopsis: Using image assets


:class:`Sprite` reference
-------------------------

.. class:: Sprite(image_filepath)

    Sprite instance represents an image. The constructor accepts a path to a file. Supported formats are png and jpg.

    Sprites instances are immutable.

    If you want to load just a fragment of the image from a file, use the :meth:`Sprite.crop()` method.

    If the file contains a spritesheet with multiple frames, use a helper function :meth:`split_spritesheet()` to
    automatically create a Sprite for each frame.

    If the file includes multiple spritesheets, use the combination of :meth:`Sprite.crop()` and
    :meth:`split_spritesheet()` to 'cut' all frames from their respective areas.

    For information how to draw a Sprite on the screen or how to create animations, :ref:`see here <Node.sprite>`.

    A full example:

    .. code-block:: python

        import os
        from kaa.sprites import Sprite
        from kaa.engine import Engine, Scene
        from kaa.geometry import Vector
        from kaa.nodes import Node

        class MyScene(Scene):

            def __init__(self):
                self.root.add_child(Node(position=Vector(100,100),
                                         sprite=Sprite(os.path.join('demos', 'assets', 'python_small.png'))))

            def update(self, dt):

                for event in self.input.events():
                    if event.system and event.system.quit:
                        self.engine.quit()

        with Engine(virtual_resolution=Vector(400, 200)) as engine:
            scene = MyScene()
            engine.window.size = Vector(400, 200)
            engine.window.center()

            engine.run(scene)

Instance Properties

.. attribute:: Sprite.size

    Returns Sprite size (width and height), as :class:`geometry.Vector`

.. attribute:: Sprite.origin

    If the sprite was a result of a crop, it will return crop's origin point. Otherwise it'll return Vector(0,0)

Instance methods

.. method:: Sprite.crop(origin, dimensions)

    Returns a new Sprite, by cropping the original sprite.

    The :code:`origin` parameter is the start position of the crop - pass :class:`geometry.Vector` indicating the
    (x,y) coordinates of the start position

    The :code:`dimensions` determines is the width and height of the crop - pass :class:`geometry.Vector` where
    x and y are desired width and height respectively.

    .. code-block:: python

        from kaa.sprites import Sprite
        from kaa.geometry import Vector

        # inside a Scene's __init__:
        sprite = Sprite('path/to/sprite.png')  # sprite.png being a 1000x1000 px file.
        print(sprite.size) # V[1000x1000]
        new_sprite = sprite.crop(Vector(150,200), Vector(20,30))  # crop a new (20x30) sprite, starting at (150,200)
        print(new_sprite.size) # V[20,30]

.. method:: split_spritesheet(spritesheet, frame_dimensions, frames_offset=0, frames_count=None, frame_padding=None)

    When an image file is a spritesheet you need to 'cut' it into individual Sprites (individual frames), which
    you can then use for making an animation using :class:`transitions.NodeSpriteTransition`. This utility function
    does the cutting for you. It takes the following params:

    * :code:`spritesheet` - a :class:`Sprite` instance holding your spritesheet
    * :code:`frame_dimensions` - dimensions of a single frame, expects :class:`geometry.Vector` where x is frame width and y is frame height
    * :code:`frames_offset` - if you're interested in getting a subset of the frames, pass the start frame index. Default offset is zero (start from the first frame)
    * :code:`frames_count` - if you're interested in getting just a subset of the frames, pass the number of frames. By default the function will 'cut' as many frames as geometrically possible.
    * :code:`frame_padding` - some spritesheet tools can add a padding to each frame, if your spritesheet is using that feature pass a :class:`geometry.Vector` where x is left+right padding and y is top+bottom padding. Example: if using 1-pixel padding on all sides, pass Vector(2,2)

    The function will process the spritesheet going from left to right and from top to bottom, cutting out the
    individual frames, returning a list of Sprites.

    .. code-block:: python

        # suppose a spritesheet.png is a 1000x1000 file with a hundred frames of 100x100 size
        spritesheet = Sprite('path/to/spritesheet.png')
        # cut all frames:
        all_frames = split_spritesheet(spritesheet, Vector(100, 100))
        # cut 10 frames, from 20 to 29
        subset_of_frames = split_spritesheet(spritesheet, Vector(100, 100), frames_offset=20, frames_count=10)
        # crop a 40x40 area starting from (20,20), and cut five frames starting from frame 3
        another_subset_of_frames = split_spritesheet(spritesheet.crop(Vector(20,20), Vector(40,40)),
            frame_offset=3, frames_count=5)

