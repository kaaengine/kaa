import sys
import subprocess

from ._bin import SHADERC_PATH


def shaderc():
    return subprocess.call([SHADERC_PATH] + sys.argv[1:])
