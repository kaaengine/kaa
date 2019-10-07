import os
import shutil
import setuptools

import versioneer
from skbuild import setup


KAA_SETUP_CMAKE_SOURCE = os.environ.get('KAA_SETUP_CMAKE_SOURCE', '')

setup(
    name="kaaengine",
    version=versioneer.get_version(),
    cmdclass=versioneer.get_cmdclass(),
    python_requires=">=3.4",
    description="An engine for making 2D games in python, for humans.",
    url="https://github.com/kaaengine/kaa",
    packages=setuptools.find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
    ],
    install_requires=[
        'enum34;python_version<"3.4"',
    ],
    include_package_data=False,
    cmake_source_dir=KAA_SETUP_CMAKE_SOURCE,
    cmake_args=[
        '-DKAA_INSTALL_KAACORE:BOOL=OFF',
    ],
)
