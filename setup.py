import os
import shutil
import setuptools
from setuptools.extension import Extension
from setuptools.command.build_ext import build_ext


class ExternalExtension(Extension):
    def __init__(self, name, path, dep_lib_paths=[]):
        super().__init__(name, sources=[])
        self.path = path
        self.dep_lib_paths = dep_lib_paths


class ExternalExtensionInstaller(build_ext):
    def run(self):
        for ext in self.extensions:
            self.copy_extension(ext)

    def copy_extension(self, extension):
        target_directory = os.path.dirname(self.get_ext_fullpath(extension.name))
        self.announce("Ensuring directory exists: {}".format(target_directory),
                      level=2)
        os.makedirs(target_directory, exist_ok=True)
        self.announce("Copying extension from {} to {}"
                      .format(extension.path, self.get_ext_fullpath(extension.name)),
                      level=2)
        shutil.copy(extension.path, self.get_ext_fullpath(extension.name))
        for dep in extension.dep_lib_paths:
            self.announce("Copying extension dependency {} to {}"
                          .format(dep, target_directory),
                          level=2)
            shutil.copy(dep, target_directory)


setuptools.setup(
    name="kaa",
    version="0.0.1",
    python_requires=">=3.4",
    author="Pawel Roman",
    author_email="romapawel@gmail.com",
    description="An engine for making 2D games in python, for humans.",
    long_description= "This engine kicks ass.",
    url="https://github.com/kaaengine/kaa",
    packages=setuptools.find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
    ],
    install_requires=[
        'enum34;python_version<"3.4"',
    ],
    zip_safe=False,
    ext_modules=[ExternalExtension(
        'kaa._kaa',
        'cmake_install/lib/python_modules/kaa/_kaa.so',
        # dep_lib_paths=['cmake_install/lib/libSDL2-2.0.so.0']
    )],
    cmdclass={
        'build_ext': ExternalExtensionInstaller,
    },
)
