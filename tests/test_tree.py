import pytest

from kaa.nodes import Node

from tests.utils import TestScene


class ChildNode(Node):
    def on_attach(self):
        assert self.parent

    def on_detach(self):
        # parent is already deleted
        assert not self.parent


@pytest.mark.usefixtures('test_engine')
def test_on_callbacks():
    parent = Node()
    parent.add_child(ChildNode())
    scene = TestScene(lambda scene, dt: parent.delete())
    scene.root.add_child(parent)
    scene.run_on_engine(1)
