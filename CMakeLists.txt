cmake_minimum_required(VERSION 3.13)

project(kaa)

find_package(PythonLibs REQUIRED)

add_subdirectory(kaacore)

add_subdirectory(kaa)
