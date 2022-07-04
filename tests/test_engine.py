import os

import pytest

from kaa.engine import get_persistent_path


def test_persistent_path():
    path = os.path.join(get_persistent_path('test_dir'), 'test_file')
    with open(path, 'w') as f:
        f.write('test_data')

    with open(path, 'r') as f:
        f.read() == 'test_data'

    path = os.path.join(get_persistent_path('test_dir', 'organization'), 'test_file2')
    with open(path, 'w') as f:
        f.write('test_data')

    with open(path, 'r') as f:
        f.read() == 'test_data'


def test_persistent_path_invalid():
    with pytest.raises(Exception) as e:
        os.path.join(get_persistent_path('@:/'), 'test_file')

    assert str(e.value) == '@, :, / characters are not allowed.'
