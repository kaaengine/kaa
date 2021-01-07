#!/bin/bash

set -x -e

if [ -n $1 ]
then
    case $1 in
        "py34")
            PY_VERSION="python3.4m"
            PY_VERSION_ABI="cp34-cp34m"
            ;;
        "py35")
            PY_VERSION="python3.5m"
            PY_VERSION_ABI="cp35-cp35m"
            ;;
        "py36")
            PY_VERSION="python3.6m"
            PY_VERSION_ABI="cp36-cp36m"
            ;;
        "py37")
            PY_VERSION="python3.7m"
            PY_VERSION_ABI="cp37-cp37m"
            ;;
        "py38")
            PY_VERSION="python3.8"
            PY_VERSION_ABI="cp38-cp38"
            ;;
        "py39")
            PY_VERSION="python3.9"
            PY_VERSION_ABI="cp39-cp39"
            ;;
        *)
            echo "ERROR: Unknown py version specified: $1"
            exit 1
            ;;
    esac
else
    PY_VERSION="python3.7m"
    PY_VERSION_ABI="cp37-cp37m"
fi

echo "Building for: ${PY_VERSION} (${PY_VERSION_ABI})"

PATH="/opt/python/${PY_VERSION_ABI}/bin:$PATH"
python --version

yum install -y alsa-lib-devel pulseaudio-libs-devel  # SDL audio dependencies
yum install -y libXrandr-devel libXcursor-devel  # SDL video dependencies
pip install -r /host/requirements/build.txt -r /host/requirements/dev.txt

# simulate out-of-source build
cp -r /host/src -v .
cp /host/setup.py /host/setup.cfg /host/versioneer.py /host/README.md .

# use pregenerated version file
cp /host/_build_version.py ./src/kaa/_version.py

KAA_SETUP_CMAKE_SOURCE='/host/' python setup.py --force-cmake \
    bdist_wheel -d /wheels/ \
    -- -DKAA_BUNDLE_SDL:BOOL=OFF

LD_LIBRARY_PATH=/usr/local/lib/:$(echo /_skbuild/linux-*/cmake-build/kaacore/third_party/sdl2/)
for WHEEL in /wheels/*.whl
do
    auditwheel repair -w /host/wheelhouse/ --lib-sdir ./ \
        --plat manylinux2010_x86_64 "${WHEEL}"
done
