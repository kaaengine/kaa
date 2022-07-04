import tempfile
from pathlib import Path
from unittest import mock

import pytest

from kaa.shader_tools import ShaderCompiler, AutoShaderCompiler
from kaa.shaders import VertexShader, FragmentShader, Program

STATIC_SHADERS_DIR = Path(__file__).parent / 'static' / 'shaders'


@pytest.fixture
def shader_cache_directory():
    with tempfile.TemporaryDirectory() as f:
        cache_dir = Path(f)
        bin_dir = cache_dir / 'bin'
        bin_dir.mkdir()
        mocked_cache_dir = mock.patch.object(ShaderCompiler, 'CACHE_DIR', cache_dir)
        mocked_bin_dir = mock.patch.object(AutoShaderCompiler, 'BIN_DIR', bin_dir)
        with mocked_cache_dir, mocked_bin_dir:
            yield cache_dir


@pytest.fixture
def vertex_shader_path():
    return str(STATIC_SHADERS_DIR / 'vs.sc')


@pytest.fixture
def fragment_shader_path():
    return str(STATIC_SHADERS_DIR / 'fs.sc')


@pytest.fixture
def fragment_shader_effect_path():
    return str(STATIC_SHADERS_DIR / 'effect.sc')


@pytest.fixture
@pytest.mark.usefixtures('shader_cache_directory')
def vertex_shader(vertex_shader_path: str):
    return VertexShader(vertex_shader_path)


@pytest.fixture
@pytest.mark.usefixtures('shader_cache_directory')
def fragment_shader(fragment_shader_path: str):
    return FragmentShader(fragment_shader_path)


@pytest.fixture
@pytest.mark.usefixtures('shader_cache_directory')
def fragment_shader_effect(fragment_shader_effect_path: str):
    return FragmentShader(fragment_shader_effect_path)


@pytest.fixture
def program(vertex_shader: VertexShader, fragment_shader: FragmentShader):
    return Program(vertex_shader, fragment_shader)
