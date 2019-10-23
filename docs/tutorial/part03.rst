Part 3: Handling input
======================

In this chapter we'll start working on our fully functional game. But before we do that we need to clean up the code
we wrote before.

Refactoring the code
~~~~~~~~~~~~~~~~~~~~

We wrote a lot of code inside Scene's :code:`__init__` that adds some arrows and explosions to the scene. Let's clean
it up and organize our game project better.

First, let's move loading Sprites to a separate class. It's a good practice to load all assets (sprites, sounds,
music, fonts, etc.) just once, when the game starts, and store them in a global object which should be easily accessible
from anywhere in the code.