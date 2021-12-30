import pytest

from kaa.render_passes import RenderTarget


@pytest.mark.usefixtures('test_engine')
def test_render_target(image_path):
    RenderTarget()  # noqa
