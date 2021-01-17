import os
import subprocess

from kaa._bin import SHADERC_PATH


def test_shaderc():
    assert os.path.isfile(SHADERC_PATH)
    assert subprocess.call([SHADERC_PATH, '-v']) == 0
