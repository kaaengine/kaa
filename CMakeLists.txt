cmake_minimum_required(VERSION 3.13)

project(kaa)

find_package(PythonLibs REQUIRED)
if (NOT CYTHON)
    find_program(CYTHON cython)
endif()

if (NOT CYTHON)
    message(FATAL_ERROR "cython executable not found")
endif()

add_subdirectory(kaacore)

add_subdirectory(kaa)
