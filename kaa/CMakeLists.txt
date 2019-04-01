cmake_minimum_required(VERSION 3.13)

set(CYTHON_MODULE_FILE _kaa.pyx)
set(CYTHON_MODULE_FILE_OUTPUT _kaa.cpp)

set(CYTHON_FILES
    ${CYTHON_MODULE_FILE}
    engine.pxi
    nodes.pxi
    physics.pxi
    scenes.pxi
    vectors.pxi
    colors.pxi
    shapes.pxi
    sprites.pxi
    assets.pxi
    input.pxi
    window.pxi

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

    kaacore_glue/pythonic_callback.h
)

add_custom_command(
    COMMAND ${CYTHON} --cplus -3 --line-directives ${CYTHON_MODULE_FILE}
            -o ${CMAKE_CURRENT_BINARY_DIR}/${CYTHON_MODULE_FILE_OUTPUT}
    DEPENDS ${CYTHON_FILES}
    OUTPUT ${CYTHON_MODULE_FILE_OUTPUT}
    COMMENT "Cythonizing ${CYTHON_MODULE_FILE}"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

add_library(_kaa SHARED ${CYTHON_MODULE_FILE_OUTPUT})
set_target_properties(
    _kaa
    PROPERTIES
    CXX_STANDARD 17
    CXX_EXTENSIONS OFF
    OUTPUT_NAME _kaa
    PREFIX ""
)

if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set_target_properties(_kaa PROPERTIES SUFFIX ".pyd")
endif()

target_include_directories(
    _kaa
    PUBLIC ${PYTHON_INCLUDE_DIR}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}
)
target_link_libraries(_kaa ${PYTHON_LIBRARY})
target_link_libraries(_kaa kaacore)
