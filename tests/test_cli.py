import subprocess


def test_shaderc():
    assert subprocess.call(['shaderc', '-v']) == 0
