cmake_minimum_required(VERSION 3.13)

project(kaa)

option(KAA_INSTALL_KAACORE "Install kaacore and third_party deps" ON)
option(KAA_BUNDLE_SDL "Bundle dynamic SDL2 lib with kaa python-package" ON)

find_package(PythonExtensions REQUIRED)
find_package(Cython REQUIRED)

if (KAA_INSTALL_KAACORE)
    add_subdirectory(kaacore)
else()
    add_subdirectory(kaacore EXCLUDE_FROM_ALL)
endif()

# modify SDL2 linker options since it interferes with weak linking
# of cython module
get_target_property(SDL2_LINK_LIBRARIES SDL2 LINK_LIBRARIES)
list(REMOVE_ITEM SDL2_LINK_LIBRARIES "-Wl,--no-undefined")  # ld linker
list(REMOVE_ITEM SDL2_LINK_LIBRARIES "-Wl,-undefined,error")  # gold linker
set_target_properties(
    SDL2 PROPERTIES
    LINK_LIBRARIES "${SDL2_LINK_LIBRARIES}"
    INTERFACE_LINK_LIBRARIES "${SDL2_LINK_LIBRARIES}"
)

# apply stripping to shaderc binary to reduce it's size
if (
    CMAKE_CXX_COMPILER_ID MATCHES "Clang"
    OR CMAKE_CXX_COMPILER_ID MATCHES "GNU"
)
    target_link_options(shaderc PRIVATE -s)
endif()

add_subdirectory(src/kaa)

install(TARGETS shaderc RUNTIME DESTINATION src/kaa/shaderc)
install(FILES
    kaacore/shaders/include/kaa.sh
    kaacore/third_party/bgfx/bgfx/src/bgfx_shader.sh
    kaacore/third_party/bgfx/bgfx/src/bgfx_compute.sh
DESTINATION src/kaa/shaderc/include)
