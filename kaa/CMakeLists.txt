cmake_minimum_required(VERSION 3.13)

set(CYTHON_MODULE_FILE kaa_cymod.pyx)
set(CYTHON_MODULE_FILE_OUTPUT kaa_cymod.cpp)

set(CYTHON_FILES
    ${CYTHON_MODULE_FILE}
    engine.pxi
    nodes.pxi
    scenes.pxi
    vectors.pxi
    shapes.pxi
    input.pxi

    kaacore/__init__.pxd
    kaacore/engine.pxd
    kaacore/nodes.pxd
    kaacore/scenes.pxd
    kaacore/physics.pxd
    kaacore/vectors.pxd
    kaacore/shapes.pxd
    kaacore/input.pxd
)

add_custom_command(
    COMMAND ${CYTHON} --cplus -3 --line-directives ${CYTHON_MODULE_FILE}
            -o ${CMAKE_CURRENT_BINARY_DIR}/${CYTHON_MODULE_FILE_OUTPUT}
    DEPENDS ${CYTHON_FILES}
    OUTPUT ${CYTHON_MODULE_FILE_OUTPUT}
    COMMENT "Cythonizing ${CYTHON_MODULE_FILE}"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

add_library(kaa_cymod SHARED ${CYTHON_MODULE_FILE_OUTPUT})
set_target_properties(
    kaa_cymod
    PROPERTIES
    CXX_STANDARD 17
    CXX_EXTENSIONS OFF
    OUTPUT_NAME kaa_cymod
    PREFIX ""
)

if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set_target_properties(kaa_cymod PROPERTIES SUFFIX ".pyd")
endif()

target_include_directories(kaa_cymod PUBLIC ${PYTHON_INCLUDE_DIR})
target_link_libraries(kaa_cymod ${PYTHON_LIBRARY})
target_link_libraries(kaa_cymod kaacore)
