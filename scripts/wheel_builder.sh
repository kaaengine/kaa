#!/bin/bash

set -x -e

cd `dirname $0`/..

PLATFORM_TAG="manylinux2014_x86_64"
DOCKER_IMAGE="quay.io/pypa/${PLATFORM_TAG}"

if [ -n "$1" ]
then
    if [ "$1" = "all" ]
    then
        TARGETS="py36 py37 py38 py39 py310 py311 py312"
    else
        TARGETS="$1"
    fi
else
    TARGETS="py37"
fi

mkdir -p ./wheelhouse/

touch _build_version.py
python -c 'import versioneer; versioneer.write_to_version_file("_build_version.py", versioneer.get_versions())'

for PY_VERSION in ${TARGETS}
do
    sudo docker run --rm -it \
        -e PLATFORM_TAG="${PLATFORM_TAG}" \
        -v `pwd`:/host "${DOCKER_IMAGE}" \
        /bin/bash /host/scripts/docker_wheel_builder.sh ${PY_VERSION}
done

rm _build_version.py
