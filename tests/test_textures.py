from kaa.images import Texture


def test_texture_resource(image_path):
    assert Texture(image_path) == Texture(image_path)
