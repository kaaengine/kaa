import os
import setuptools

import versioneer
from skbuild import setup


readme_path = os.path.join(os.path.dirname(__file__), 'README.md')
with open(readme_path, 'rb') as fh:
    readme_content = fh.read().decode('utf-8')


KAA_SETUP_CMAKE_SOURCE = os.environ.get('KAA_SETUP_CMAKE_SOURCE', '')

setup(
    name="kaaengine",
    author="labuzm, maniek2332",
    author_email="labuzm@gmail.com, maniek2332@gmail.com",
    version=versioneer.get_version(),
    cmdclass=versioneer.get_cmdclass(),
    python_requires=">=3.4",
    description="Pythonic game engine for humans.",
    long_description=readme_content,
    long_description_content_type='text/markdown',
    url="https://github.com/kaaengine/kaa",
    packages=setuptools.find_packages(),
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        # TODO license
        "Operating System :: Microsoft :: Windows",
        "Operating System :: POSIX :: Linux",
        "Programming Language :: C++",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3 :: Only",
        "Topic :: Games/Entertainment",
        "Topic :: Software Development",
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
