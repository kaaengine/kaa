cmake_minimum_required(VERSION 3.13)

add_library(kaa_cymod SHARED "kaa_cymod.cpp")
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
