from pathlib import Path

import pytest

from kaa.images import Texture


STATIC_IMAGES_DIR = Path(__file__).parent / 'static' / 'images'


@pytest.fixture
def image_path():
    return str(STATIC_IMAGES_DIR / 'image.png')


@pytest.fixture
def texture(image_path):
    return Texture(image_path)
