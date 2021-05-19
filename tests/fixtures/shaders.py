import tempfile
from pathlib import Path
from unittest import mock

import pytest

from kaa._kaa import _AutoShaderCompiler
from kaa.shaders import (
    VertexShader, FragmentShader, AttributeLocation, Varying, VaryingType, Program
)

STATIC_SHADERS_DIR = Path(__file__).parent / 'static' / 'shaders'


@pytest.fixture
def shader_bin_directory():
    with tempfile.TemporaryDirectory() as f:
        bin_dir = Path(f)
        with mock.patch.object(_AutoShaderCompiler, 'BIN_DIR', bin_dir):
            yield bin_dir


@pytest.fixture
def vertex_shader_path():
    return str(STATIC_SHADERS_DIR / 'vs.sc')


@pytest.fixture
def fragment_shader_path():
    return str(STATIC_SHADERS_DIR / 'fs.sc')


@pytest.fixture
def in_out_layout():
    return {
        AttributeLocation.color0: Varying('v_color0', VaryingType.vec4),
        AttributeLocation.texcoord0: Varying('v_texcoord0', VaryingType.vec2)
    }


@pytest.fixture
@pytest.mark.usefixtures('shader_bin_directory')
def vertex_shader(vertex_shader_path: str, in_out_layout: dict):
    return VertexShader(vertex_shader_path, in_out_layout)


@pytest.fixture
@pytest.mark.usefixtures('shader_bin_directory')
def fragment_shader(fragment_shader_path: str, in_out_layout: dict):
    return FragmentShader(fragment_shader_path, in_out_layout)


@pytest.fixture
def program(vertex_shader: VertexShader, fragment_shader: FragmentShader):
    return Program(vertex_shader, fragment_shader)
