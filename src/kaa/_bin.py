import os
import pkg_resources


SHADERC_PATH = pkg_resources.resource_filename(
    __name__, 'bin/shaderc'
)


def _initialize_shaderc():
    os.environ['SHADERC_PATH'] = SHADERC_PATH
