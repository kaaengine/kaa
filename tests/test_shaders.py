import platform
from pathlib import Path

import pytest

from kaa.exceptions import KaacoreError
from kaa.shaders import (
    ShaderType, VertexShader, FragmentShader, AttributeLocation, Varying, VaryingType,
    Program, ShaderCompilationError
)


@pytest.mark.usefixtures('test_engine', 'shader_bin_directory')
def test_shader_resources(
    vertex_shader_path: str,
    fragment_shader_path: str,
    in_out_layout: dict
):
    vs = VertexShader(vertex_shader_path, in_out_layout)
    fs = FragmentShader(fragment_shader_path, in_out_layout)

    assert vs.type == ShaderType.vertex
    assert fs.type == ShaderType.fragment

    assert vs == VertexShader(vertex_shader_path, in_out_layout)
    assert fs == FragmentShader(fragment_shader_path, in_out_layout)


def test_auto_compilation(
    shader_bin_directory: Path,
    vertex_shader_path: str,
    fragment_shader_path: str,
    in_out_layout: dict
):
    VertexShader(vertex_shader_path, in_out_layout)
    FragmentShader(fragment_shader_path, in_out_layout)

    compiled_shaders_num = len(list(shader_bin_directory.iterdir()))

    system = platform.system()
    if system == 'Linux':
        assert len(list(shader_bin_directory.glob('vs-glsl-*.bin'))) == 1
        assert len(list(shader_bin_directory.glob('vs-spirv-*.bin'))) == 1
        assert len(list(shader_bin_directory.glob('fs-glsl-*.bin'))) == 1
        assert len(list(shader_bin_directory.glob('fs-spirv-*.bin'))) == 1
    elif system == 'Darwin':
        assert len(list(shader_bin_directory.glob('vs-metal-*.bin'))) == 1
        assert len(list(shader_bin_directory.glob('fs-metal-*.bin'))) == 1
        assert len(list(shader_bin_directory.glob('vs-glsl-*.bin'))) == 1
        assert len(list(shader_bin_directory.glob('vs-spirv-*.bin'))) == 1
        assert len(list(shader_bin_directory.glob('fs-glsl-*.bin'))) == 1
        assert len(list(shader_bin_directory.glob('fs-spirv-*.bin'))) == 1
    else:
        assert len(list(shader_bin_directory.glob('vs-hlsl_dx9-*.bin'))) == 1
        assert len(list(shader_bin_directory.glob('fs-hlsl_dx9-*.bin'))) == 1
        assert len(list(shader_bin_directory.glob('vs-hlsl_dx11-*.bin'))) == 1
        assert len(list(shader_bin_directory.glob('fs-hlsl_dx11-*.bin'))) == 1
        assert len(list(shader_bin_directory.glob('vs-glsl-*.bin'))) == 1
        assert len(list(shader_bin_directory.glob('vs-spirv-*.bin'))) == 1
        assert len(list(shader_bin_directory.glob('fs-glsl-*.bin'))) == 1
        assert len(list(shader_bin_directory.glob('fs-spirv-*.bin'))) == 1

    assert len(list(shader_bin_directory.glob('varying-*.def.sc'))) == 1

    VertexShader(vertex_shader_path, in_out_layout)
    FragmentShader(fragment_shader_path, in_out_layout)

    assert compiled_shaders_num == len(list(shader_bin_directory.iterdir()))


@pytest.mark.usefixtures('shader_bin_directory')
def test_shaders_invalid_usage(
    vertex_shader_path: str,
    in_out_layout: dict
):
    with pytest.raises(FileNotFoundError):
        VertexShader('non_existing_path', in_out_layout)

    invalid_layout = {
        AttributeLocation.texcoord0: Varying('v_texcoord0', VaryingType.vec2)
    }
    with pytest.raises(ShaderCompilationError):
        # v_color0 is missing
        VertexShader(vertex_shader_path, invalid_layout)

    with pytest.raises(KaacoreError):
        # access to uninitialized resource
        VertexShader(vertex_shader_path, in_out_layout).type


@pytest.mark.usefixtures('test_engine')
def test_program_resource(
    vertex_shader_path: str,
    fragment_shader_path: str,
    vertex_shader: VertexShader,
    fragment_shader: FragmentShader,
    in_out_layout: dict
):
    from_objects = Program(vertex_shader, fragment_shader)

    assert from_objects.vertex_shader == vertex_shader
    assert from_objects.fragment_shader == fragment_shader

    from_files = Program.from_files(
        vertex_shader_path, fragment_shader_path, in_out_layout
    )

    assert from_files == from_objects
    assert from_files.vertex_shader == vertex_shader
    assert from_files.fragment_shader == fragment_shader


@pytest.mark.usefixtures('shader_bin_directory')
def test_program_invalid_usage(
    vertex_shader_path: str,
    fragment_shader_path: str,
    in_out_layout: dict
):

    with pytest.raises(FileNotFoundError):
        Program.from_files('non_existing_path', fragment_shader_path, in_out_layout)

    invalid_layout = {
        AttributeLocation.texcoord0: Varying('v_texcoord0', VaryingType.vec2)
    }
    with pytest.raises(ShaderCompilationError):
        # v_color0 is missing
        Program.from_files(vertex_shader_path, fragment_shader_path, invalid_layout)

    program = Program.from_files(vertex_shader_path, fragment_shader_path, in_out_layout)
    with pytest.raises(KaacoreError):
        # access to uninitialized resource
        program.vertex_shader
