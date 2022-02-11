# distutils: language=c++

# This line enables support for non-python threads,
# it's required by kaacore multithreaded rendering.
cimport cython.parallel

include "exceptions.pxi"
include "log.pxi"
include "vectors.pxi"
include "easings.pxi"
include "colors.pxi"
include "geometry.pxi"
include "input.pxi"
include "shapes.pxi"
include "textures.pxi"
include "sprites.pxi"
include "views.pxi"
include "spatial_index.pxi"
include "scenes.pxi"
include "transitions.pxi"
include "nodes.pxi"
include "fonts.pxi"
include "custom_transitions.pxi"
include "physics.pxi"
include "display.pxi"
include "window.pxi"
include "audio.pxi"
include "timers.pxi"
include "statistics.pxi"
include "capture.pxi"
include "engine.pxi"
include "shaders.pxi"
include "materials.pxi"
