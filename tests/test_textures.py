from kaa.images import Image


def test_texture_resource(image_path):
    assert Image(image_path) == Image(image_path)
