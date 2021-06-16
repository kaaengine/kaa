cmake_minimum_required(VERSION 3.13)

set(CYTHON_MODULE_FILE _kaa.pyx)
set(CYTHON_MODULE_FILE_OUTPUT _kaa.cpp)

set(CYTHON_FILES
    ${CYTHON_MODULE_FILE}
    engine.pxi
    nodes.pxi
    physics.pxi
    scenes.pxi
    views.pxi
    vectors.pxi
    colors.pxi
    shapes.pxi
    sprites.pxi
    input.pxi
    window.pxi
    display.pxi
    audio.pxi
    fonts.pxi
    geometry.pxi
    exceptions.pxi
    timers.pxi
    transitions.pxi
    custom_transitions.pxi
    log.pxi
    easings.pxi
    spatial_index.pxi
    textures.pxi
    shaders.pxi
    materials.pxi
    statistics.pxi

    kaacore/__init__.pxd
    kaacore/engine.pxd
    kaacore/nodes.pxd
    kaacore/scenes.pxd
    kaacore/physics.pxd
    kaacore/vectors.pxd
    kaacore/math.pxd
    kaacore/shapes.pxd
    kaacore/sprites.pxd
    kaacore/input.pxd
    kaacore/glue.pxd
    kaacore/window.pxd
    kaacore/display.pxd
    kaacore/audio.pxd
    kaacore/fonts.pxd
    kaacore/geometry.pxd
    kaacore/exceptions.pxd
    kaacore/timers.pxd
    kaacore/transitions.pxd
    kaacore/custom_transitions.pxd
    kaacore/log.pxd
    kaacore/hashing.pxd
    kaacore/easings.pxd
    kaacore/spatial_index.pxd
    kaacore/clock.pxd
    kaacore/shaders.pxd
    kaacore/materials.pxd
    kaacore/resources.pxd
    kaacore/textures.pxd
    kaacore/statistics.pxd

    extra/include/pythonic_callback.h
    extra/include/python_exceptions_wrapper.h
    extra/include/hashing.h
)

add_custom_command(
    COMMAND ${CYTHON_EXECUTABLE} --cplus -3 --line-directives ${CYTHON_MODULE_FILE}
            -o ${CMAKE_CURRENT_BINARY_DIR}/${CYTHON_MODULE_FILE_OUTPUT}
    DEPENDS ${CYTHON_FILES}
    OUTPUT ${CYTHON_MODULE_FILE_OUTPUT}
    COMMENT "Cythonizing ${CYTHON_MODULE_FILE}"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

add_library(_kaa MODULE ${CYTHON_MODULE_FILE_OUTPUT})
python_extension_module(_kaa)

set_target_properties(
    _kaa
    PROPERTIES
    CXX_STANDARD 17
    CXX_EXTENSIONS OFF
)

target_include_directories(
    _kaa
    PUBLIC ${PYTHON_INCLUDE_DIR}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(_kaa kaacore)
add_dependencies(_kaa shaderc)

target_compile_definitions(_kaa PUBLIC GLM_ENABLE_EXPERIMENTAL)

set_target_properties(_kaa PROPERTIES INSTALL_RPATH "$ORIGIN")

install(TARGETS _kaa LIBRARY DESTINATION src/kaa)

if (KAA_BUNDLE_SDL)
    install(TARGETS SDL2 LIBRARY DESTINATION src/kaa
                         RUNTIME DESTINATION src/kaa)
endif()
