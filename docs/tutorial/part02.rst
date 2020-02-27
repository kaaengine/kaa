Part 2: Sprites and nodes
=========================

In a previous chapter we have covered some properties of engine, window and renderer and were able to run a game
showing empty screen. Let's start drawing some actual objects in our game!

Loading images from files
~~~~~~~~~~~~~~~~~~~~~~~~~

In order to draw anything, we need to load an image file first. For this demo we will use a prepared package of
assets, :download:`available here </files/assets.zip>` which includes full set of images, sounds and fonts for the
tutorial. Download the file and unpack it inside the folder with main.py. You should get the following folder structure:

.. code-block:: none

    my_game/
        assets/
            gfx/
                arrow.png
                ..... other image files ....
            sfx/
                .... sound effect files ....
            music/
                .... music files ....
            fonts/
                .... font files ....
        main.py

Let's now load the first image (arrow.png). Add the following imports at the top of the main.py

.. code-block:: python

    from kaa.sprites import Sprite
    import os

Then add :code:`__init__()` method to :code:`MyScene` and load our image there:

.. code-block:: python

    def __init__(self):
        super().__init__()
        arrow_sprite = Sprite(os.path.join('assets', 'gfx', 'arrow.png'))

Kaa engine loads images to objects called Sprites. With the image loaded, we can create the first few in-game objects
(which will use the same Sprite).

.. note::

    Do not try to create Sprites (or any other kaa objects) outside engine context. To illustrate this,
    create the new file, named :code:`bad_main.py`:

    .. code-block:: python

        from kaa.engine import Engine, Scene
        from kaa.geometry import Vector
        from kaa.sprites import Sprite
        import os

        # creating objects outside engine's 'with' context like this will throw an exception
        loose_sprite = Sprite(os.path.join('assets', 'gfx', 'arrow.png'))


        # everything else below is good!
        class MyScene(Scene):

            def update(self, dt):
                for event in self.input.events():
                    if event.system and event.system.quit:
                        self.engine.quit()


        with Engine(virtual_resolution=Vector(800, 600)) as engine:
            my_scene = MyScene()
            engine.run(my_scene)

    Try running it. Kaaengine will thrown an exception because of that Sprite creation outside the engine context.

Drawing objects on the screen
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Object instances are called Nodes. Let's create three arrow objects (three Nodes) using arrow_sprite.

.. code-block:: python

    from kaa.nodes import Node

.. code-block:: python

    def __init__(self):
        super().__init__()
        self.arrow_sprite = Sprite(os.path.join('assets', 'gfx', 'arrow.png'))
        self.arrow1 = Node(sprite=self.arrow_sprite, position=Vector(200, 200))  # default position is Vector(0,0)
        self.arrow2 = Node(sprite=self.arrow_sprite, position=Vector(400, 300))
        self.arrow3 = Node(sprite=self.arrow_sprite, position=Vector(600, 500))

Run the game and... No nodes are visible! It's because we created them but did not add them to the scene. A
shameful display! Let's fix it. The Scene holds a tree-like structure of Nodes, and always has the "root" Node.
Let's add our objects as children of the root node:

.. code-block:: python

    def __init__(self):
        super().__init__()
        self.arrow_sprite = Sprite(os.path.join('assets', 'gfx', 'arrow.png'))
        self.arrow1 = Node(sprite=self.arrow_sprite, position=Vector(200, 200))
        self.arrow2 = Node(sprite=self.arrow_sprite, position=Vector(400, 300))
        self.arrow3 = Node(sprite=self.arrow_sprite, position=Vector(600, 500))
        self.root.add_child(self.arrow1)
        self.root.add_child(self.arrow2)
        self.root.add_child(self.arrow3)

Run the game again. Looks much better doesn't it? The arrows appear exactly where we put them.

**Note**: Sprites are immutable. Think of them as wrapper objects for image files.

Moving objects around
~~~~~~~~~~~~~~~~~~~~~

To move an object to a different position, simply set a new position:

.. code-block:: python

    def __init__(self):
        # ... previous code...
        self.arrow1.position = Vector(360, 285)

Run the game and check out the results!

.. note::

    position's x and y can be floats, e.g. :code:`arrow1.position = Vector(360.45, 285.998)` they can also
    be negative e.g. :code:`arrow1.position = Vector(-50, -10)`

Using z-index
~~~~~~~~~~~~~

Hmm, arrow1 now overlaps arrow2, but what decides which one is displayed on top? Long story short: nothing decides, it is
unpredictable. Let's take control by assigning objects a z-index. Object with a bigger z-index will always be rendered
on top of the objects with smaller z-index.

.. code-block:: python

    def __init__(self):
        # ... previous code...
        self.arrow1.z_index = 1  # note: default z_index is 0

Run the game and see that arrow1 is always drawn on top of arrow2.

Rotating objects
~~~~~~~~~~~~~~~~

To rotate an object, simply set the rotation_degrees property.

.. code-block:: python

    def __init__(self):
        # ... previous code...
        self.arrow1.rotation_degrees = 45  # note: default rotation_degrees is 0

Notice that you can set rotation_degrees to more than 360 degrees or to negative values.

Those more mathematically inclined can use radians. 45 degrees should be pi/ 4, right? Use :code:`rotation`
property on a node:

.. code-block:: python

    import math
    self.arrow1.rotation = math.pi / 4

Run the game and check for yourself - arrow1 rotated 45 degrees!

Scaling objects
~~~~~~~~~~~~~~~

To scale an object in X or Y axis (or both), use the :code:`scale` property. Pass a Vector object, where vector's x,y
values are scaling factors for x and y axis respectively. 1 is the default scale, 2 will enlarge it twice, passing 0.5
will shrink it 50%, etc.

.. code-block:: python

    import math
    self.arrow1.scale = Vector(0.5, 1)  # note: default is Vector(1,1)

Re-run the game and see how X axis of the arrow was scaled down.

Aligning object's 'origin' (the anchor point)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Let's ask a curious question. Our 'arrow' object has spatial dimentions: 100px width and 50px height. We tell the game
to draw it at some specific position e.g. (300, 200). But what does this actually mean? Which pixel of the arrow will
really be drawn at position (300, 200)? The top-left pixel? Or the central pixel? Or maybe some other pixel?

By default it's the central pixel. That anchor point of a node is called 'origin'. Let's visualize the idea by drawing
a 'pixel marker' image in position of arrow2 and arrow3

.. code-block:: python

    def __init__(self):
        ... previous code...
        # create pixel marker sprite
        self.pixel_marker_sprite = Sprite(os.path.join('assets', 'gfx', 'pixel-marker.png'))
        # create pixel_marker 1 in the same spot as arrow2 (but with bigger z-index so we can see it)
        self.pixel_marker1 = Node(sprite=self.pixel_marker_sprite, position=Vector(400, 300), z_index=100)
        # create pixel_marker 2 in the same spot as arrow3
        self.pixel_marker2 = Node(sprite=self.pixel_marker_sprite, position=Vector(600, 500), z_index=100)
        # add pixel markers to the scene
        self.root.add_child(self.pixel_marker1)
        self.root.add_child(self.pixel_marker2)

Run the game and see the markers appear on top of arrows in the central position.

Now, let's change just one thing: origin_alignment of arrow 3

.. code-block:: python

    from kaa.geometry import Alignment

.. code-block:: python

    def __init__(self):
        # ... previous code...
        self.arrow3.origin_alignment = Alignment.right  # default is Alignment.center

Re-run the game and see how arrow3 is now drawn in a different place! We did not change its position, just the
origin alignment. Not surprisingly, we can see that origin marker is to the right of the node's rectangle.

You can re-set the origin to be in one of the 9 standard positions: top-left, top, top-right, left, central (default), right,
bottom-left, bottom and bottom-right. The node's rectangular shape will be drawn according to origin position.

All transformations such as positioning, scaling or rotating are applied in relation to the origin. We'll see that in
practice in the next section.

.. note::

    What if you need a non-standard position for node's origin? You can achieve that by using two nodes in a
    parent - child relation. It's described in more detail in one of the next sections.


Updating state of objects
~~~~~~~~~~~~~~~~~~~~~~~~~

So far, we've been writing our code in the Scene's :code:`__init__` method. This is a standard practice to create an
initial state of the scene. Let's now try to update our objects in real-time, as the game is running!

Every scene has :code:`update(dt)` function which will be called by the engine in a loop (with maximum frequency of
60 times per second). The :code:`dt` parameter is an integer value how many milliseconds had  passed since the last
update call. You will implement most of your game logic inside the :code:`update` function.

Let's get to it. Modify the :code:`update` function in :code:`MyScene` class:

.. code-block:: python

    def update(self, dt):
        #  .... previous code ....
        self.arrow2.rotation_degrees += 1  # rotating 1 degree PER FRAME (not the best design)
        self.arrow3.rotation_degrees += 90 * dt / 1000  # rotating 90 degrees PER SECOND (good design!)

Run the game and notice how the arrows rotate **around their respective origin points**. It's also worth noting that
it's generally better to include dt in all formulas which transform game objects. Rotating, moving, or generally applying
any other transformation by a fixed value per frame can lead to problems because it is not guaranteed
that frame time (dt) will always be identical. Some frames may take longer to process than others and the visible
transformations would suddenly speed up or slow down, confusing the player. Thus it's usually better to apply
transformations **per second**.

Objects can have child objects
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

So far we've been adding objects (Nodes) to the root Node of the scene. But each node we create can have its own
child nodes, those child nodes can have their own children and so on.

All transformations applied to a node are automatically applied to all its child nodes. Let's check this out in
practice. Add the following code to the :code:`__init__` function of the Scene.

.. code-block:: python

    def __init__(self):
        # .... previous code .....
        self.green_arrow_sprite = Sprite(os.path.join('assets', 'gfx', 'arrow-green.png'))
        self.child_arrow1 = Node(sprite=self.green_arrow_sprite, position=Vector(0,0), rotation_degrees=90, z_index=1)
        self.arrow3.add_child(self.child_arrow1)

Run the game and check out the result. First thing you have probably noticed is that we set child_arrow1's position to
(0,0) yet the green arrow is being shown at (600, 500)! This is because **child node's position value is not absolute
but relative to the parent**. Since parent's position is (600, 500) and child's offset is (0, 0) therefore
calculated child position is (600, 500). As you have noticed the child arrow is rotating together with the parent,
rotated (again, relatively) by +90 degrees.

It is very important to remember that position, scale and rotation of each node are always relative to their parent node.
There is a way to get an **absolute** position, scale or rotation of a Node:

.. code-block:: python

    print(self.arrow3.absolute_position)
    print(self.arrow3.absolute_rotation)
    print(self.arrow3.absolute_rotation_degrees)
    print(self.arrow3.absolute_scale)

Take some time to experiment with the parent-child system. Try changing child and parent node's properties such as position,
origin_alignment, rotation, scaling etc., try updating both nodes properties inside update() function and observe
the results.

.. note::

    You can add an empty Node (without image, just :code:`Node(position=Vector(x, y)`) just to hold a position and
    then add a child with any desired position offset. This simple trick allows for a node to have a custom origin
    alignment, not limited to the 9 standard origin_alignment values.

Showing and hiding objects
~~~~~~~~~~~~~~~~~~~~~~~~~~

If you need to hide or show a node, use :code:`visible` property:

.. code-block:: python

    my_node.visible = False #  default is True

Hiding a node will automatically hide all its child nodes.

Using animated sprites
~~~~~~~~~~~~~~~~~~~~~~

So far we've been using single-frame images. Kaa engine supports frame-by-frame sprite animations. Take a look at
:code:`assets/gfx/explosion.png` file. It is a frame by frame animation of an explosion, frame size is 100x100
and there are 75 actual frames in the file.

Creating animation is a two step process:

First, we need to 'cut' each frame from the :code:`explosion.png` spritesheet file and make it a separate :code:`Sprite`.
In other words we need to have 75 Sprites, one for each frame. Fortunately we don't need to do that manually,
there's a helper function for slicing spritesheets: :code:`split_spritesheet`. Let's use it.

.. code-block:: python

    from kaa.sprites import Sprite, split_spritesheet

    def __init__(self):
        # .... previous code .....
        self.explosion_spritesheet = Sprite(os.path.join('assets', 'gfx', 'explosion.png')) # laod the whole spritesheet
        self.explosion_frames = split_spritesheet(self.explosion_spritesheet, frame_dimensions=Vector(100,100),
            frames_count=75)  # create 75 separate <Sprite> objects

The function is rather self-explanatory, it takes a sprite, goes through it left to right and top to bottom, cutting out
frames using specified frame dimensions. It stops after :code:`frames_count` frames.

The second step is to create an animation, and assign it to a node. We then add the Node to the scene:

.. code-block:: python

    from kaa.transitions import NodeSpriteTransition

    def __init__(self):
        # .... previous code .....
        explosion_animation = NodeSpriteTransition(self.explosion_frames, duration=1000, loops=0)  # create animation
        self.explosion = Node(position=Vector(600, 150), transition=explosion_animation)  # create node
        self.root.add_child(self.explosion)  # add node to scene

Few things demand explanation here. First, you may the weird name of the animation object. Why is it called
:code:`NodeSpriteTransition`, not just :code:`SpriteAnimation` or something similar? Why is it imported from
:code:`kaa.transitions` namespace ? The reason is because it's a part of much more general mechanism called...
transitions! Transitions are recipes how node's property should evolve over time. In this case the evolving property
is a sprite, but as you will see in the :doc:`Part 9 of the tutorial </tutorial/part09>` there are also transitions
for properties such as position, rotation, scale, color and others. The mechanism allows to 'change' those properties
over time just like we change the sprite over time. That also explains why node property is called :code:`transition`.

Let's look at the :code:`NodeSpriteTransition` parameters. First one is obviously a list of frames, the :code:`duration`
tells how long the animation should take (in miliseconds). The :code:`loops` parameter tells how many times the
animation should repeat. 0 means infinite number of repetitions.

Run the game and behold the animated explosion, if you haven't yet!

**Note**: All transitions, including :code:`NodeSpriteTransition` are immutable which means if you need to create a
transition with different parameters, you need to create a new transition object. You can re-use the same transition
on multiple nodes though.

Let's illustrate this on example. Let's use the same set of frames to create a new animation: longer duration,
with 3 loops instead of the infinite loop, and running back and forth. Then let's add two explosion Nodes
using that animation

.. code-block:: python

    def __init__(self):
        # .... previous code .....
        explosion_animation_long =  NodeSpriteTransition(self.explosion_frames, duration=4000, loops=3,
                                                         back_and_forth=True)  # create animation
        self.explosion2 = Node(position=Vector(100, 400), transition=explosion_animation_long)
        self.explosion3 = Node(position=Vector(200, 500), transition=explosion_animation_long)
        self.root.add_child(self.explosion2)
        self.root.add_child(self.explosion3)

Run the game and check out the new explosions. We've also learned about :code:`back_and_forth` flag on the
:code:`NodeSpriteTransition`!


How to crop a Sprite
~~~~~~~~~~~~~~~~~~~~

What if you want to crop the Sprite manually? Use :code:`crop()` method on Sprite object, getting a new Sprite:

Controlling animations manually
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you want to take full control of the animation you need to set each frame manually (set the :code:`sprite` on
given Node manually). It's entirely up to you how you do that, let's just say that there's something like custom
transitions. We'll learn more about transitions in :doc:`Chapter 10 of the tutorual </tutorial/part10>`

Setting a lifetime of an object
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For every Node you create you can set a :code:`lifetime` property. It is a number of miliseconds after which the node
will be automatically removed from the scene. Just remember that the timer starts ticking from the moment of adding node to the
scene, not from the moment of creating the Node object. If a node is already added to the Scene, the timer starts immediately.

Let's set lifetime property on one of the nodes:

.. code-block:: python

    self.explosion3.lifetime = 5000

Run the game, and observe that the node gets removed after 5 seconds.

Deleting objects from the scene
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You will of course need to remove Nodes from the scene programmatically as well. It is very easy, just use the
:code:`delete()` method on the Node you wish to remove.

.. code-block:: python

    some_node.delete()

The node will get removed from the scene immediately. If it has child nodes, they will be removed as well, together
with their child nodes and so on, recursively.

**IMPORTANT**: after deleting a node you should not call any of its method or access any of its properties, even
the read-only properties. It will cause non deterministic efects as the game runs, eventually leading to a
segmentation fault and a crash to desktop.


End of Part 2 - full code
~~~~~~~~~~~~~~~~~~~~~~~~~

We end this part of tutorial with a lot of code inside Scene's :code:`__init__`. It starts looking messy but don't
worry, we'll start the :doc:`Part 3 </tutorial/part03>` with a cleanup, and then we'll get to writing the actual game!

Anyway, here's the full listing of main.py after Part 2:

.. code-block:: python

    from kaa.engine import Engine, Scene
    from kaa.geometry import Vector
    from kaa.sprites import Sprite, split_spritesheet
    from kaa.nodes import Node
    from kaa.geometry import Alignment
    from kaa.transitions import NodeSpriteTransition
    import os

    class MyScene(Scene):

        def __init__(self):
            super().__init__()
            self.arrow_sprite = Sprite(os.path.join('assets', 'gfx', 'arrow.png'))
            self.arrow1 = Node(sprite=self.arrow_sprite, position=Vector(200, 200))
            self.arrow2 = Node(sprite=self.arrow_sprite, position=Vector(400, 300))
            self.arrow3 = Node(sprite=self.arrow_sprite, position=Vector(600, 500))
            self.root.add_child(self.arrow1)
            self.root.add_child(self.arrow2)
            self.root.add_child(self.arrow3)
            self.arrow1.position = Vector(360, 285)
            self.arrow1.z_index = 1  # note: default z_index is 0
            self.arrow1.rotation_degrees = 45
            self.arrow1.scale = Vector(0.5, 1)  # note: default is Vector(1,1)
            # create pixel marker sprite
            self.pixel_marker_sprite = Sprite(os.path.join('assets', 'gfx', 'pixel-marker.png'))
            # create pixel_marker 1 in the same spot as arrow2 (but with bigger z-index so we can see it)
            self.pixel_marker1 = Node(sprite=self.pixel_marker_sprite, position=Vector(400, 300), z_index=100)
            # create pixel_marker 2 in the same spot as arrow3
            self.pixel_marker2 = Node(sprite=self.pixel_marker_sprite, position=Vector(600, 500), z_index=100)
            # add pixel markers to the scene
            self.root.add_child(self.pixel_marker1)
            self.root.add_child(self.pixel_marker2)
            self.arrow3.origin_alignment = Alignment.right  # default is Alignment.center
            self.green_arrow_sprite = Sprite(os.path.join('assets', 'gfx', 'arrow-green.png'))
            self.child_arrow1 = Node(sprite=self.green_arrow_sprite, position=Vector(0,0), rotation_degrees=90, z_index=1)
            self.arrow3.add_child(self.child_arrow1)
            self.explosion_spritesheet = Sprite(os.path.join('assets', 'gfx', 'explosion.png')) # laod the whole spritesheet
            self.explosion_frames = split_spritesheet(self.explosion_spritesheet, frame_dimensions=Vector(100,100),
                frames_count=75)  # create 75 separate <Sprite> objects
            explosion_animation = NodeSpriteTransition(self.explosion_frames, duration=1000, loops=0)  # create animation
            self.explosion = Node(position=Vector(600, 150), transition=explosion_animation)  # create node with animation
            self.root.add_child(self.explosion)  # add node to scene

            explosion_animation_long =  NodeSpriteTransition(self.explosion_frames, duration=4000, loops=3,
                                                             back_and_forth=True)  # create animation
            self.explosion2 = Node(position=Vector(100, 400), transition=explosion_animation_long)
            self.explosion3 = Node(position=Vector(200, 500), transition=explosion_animation_long)
            self.root.add_child(self.explosion2)
            self.root.add_child(self.explosion3)
            self.explosion3.lifetime = 5000


        def update(self, dt):
            #  .... previous code ....
            self.arrow2.rotation_degrees += 1  # rotating 1 degree PER FRAME (not the best design)
            self.arrow3.rotation_degrees += 90 * dt / 1000  # rotating 90 degrees PER SECOND (good design!)


    with Engine(virtual_resolution=Vector(800, 600)) as engine:
        # set  window properties
        engine.window.size = Vector(800, 600)
        engine.window.title = "My first kaa game!"
        # initialize and run the scene
        my_scene = MyScene()
        engine.run(my_scene)
