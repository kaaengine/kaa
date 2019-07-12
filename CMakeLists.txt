cmake_minimum_required(VERSION 3.13)

project(kaa)

option(KAA_DYNAMIC_LINK "Link kaa module weakly" OFF)

find_package(PythonLibs)
if (NOT CYTHON)
    find_program(CYTHON cython)
endif()

if (NOT CYTHON)
    message(FATAL_ERROR "cython executable not found")
endif()

add_subdirectory(kaacore)

add_subdirectory(kaa)
