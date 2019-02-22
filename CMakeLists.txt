cmake_minimum_required(VERSION 3.13)

project(kaa)

find_package(PythonLibs REQUIRED)
find_program(CYTHON cython)

if (NOT CYTHON)
    message(FATAL_ERROR "cython executable not found")
endif()

add_subdirectory(kaacore)

add_subdirectory(kaa)
