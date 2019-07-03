# kaa
KAA - Pythonic game engine for humans

## Building

Requirements: cython, cmake (3.13+) - those could be installed with pip in virtualenv.
Python version: 3.5+

Clone repository:
```
git clone --recursive https://github.com/kaaengine/kaa
cd kaa
```

Prepare cmake build environment (you usually need to do this only once):
```
cmake -B./build .
```

Run build process (run this when there is an update):
```
cmake --build ./build -j9
```

Create a symlink to built kaa cython module (do this just once):
```
ln -s ../build/kaa/_kaa.so kaa/_kaa.so
```

## Updating (submodules magic)

Since KAA extensively uses git submodules, pulling changes from main repository is not enough. To update kaacore submodule
to version matching with main repo do:
```
git submodule update --recursive kaacore
```
