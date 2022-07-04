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
include "scenes.pxi"
include "spatial_index.pxi"
include "viewports.pxi"
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
include "shaders.pxi"
include "materials.pxi"
include "render_targets.pxi"
include "render_passes.pxi"
include "engine.pxi"
