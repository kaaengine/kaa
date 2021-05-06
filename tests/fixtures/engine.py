import pytest

from kaa.engine import Engine
from kaa.geometry import Vector


@pytest.fixture
def test_engine():
    with Engine(Vector.xy(1)) as engine:
        yield engine
