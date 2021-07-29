import platform
from pathlib import Path

import pytest

from kaa.shaders import ShaderType, VertexShader, FragmentShader, Program
from kaa.shader_tools import parse_shader, Varying, TypeConstructor, Float


@pytest.mark.usefixtures('test_engine', 'shader_cache_directory')
def test_shader_resources(vertex_shader_path: str, fragment_shader_path: str):
    vs = VertexShader(vertex_shader_path)
    fs = FragmentShader(fragment_shader_path)

    assert vs.type == ShaderType.vertex
    assert fs.type == ShaderType.fragment

    assert vs == VertexShader(vertex_shader_path)
    assert fs == FragmentShader(fragment_shader_path)


def test_auto_compilation(
    shader_cache_directory: Path,
    vertex_shader_path: str,
    fragment_shader_path: str
):
    VertexShader(vertex_shader_path)
    FragmentShader(fragment_shader_path)

    shader_bin_directory = shader_cache_directory / 'bin'
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

    assert len(list(shader_cache_directory.glob('varying-*.def.sc'))) == 2

    VertexShader(vertex_shader_path)
    FragmentShader(fragment_shader_path)

    assert compiled_shaders_num == len(list(shader_bin_directory.iterdir()))


def test_shader_parsing():
    expected_result = sorted(
        [
            Varying(
                'vec2', 'vec', 'TEXCOORD0',
                TypeConstructor('vec2', [Float('0'), Float('0')])
            ),
            Varying('float', 'f', 'TEXCOORD1', TypeConstructor('float', [Float('1')])),
            Varying('float', 'f2', 'TEXCOORD2')
        ],
        key=lambda v: str(v)
    )

    # standard formatting
    source = """@input {
        vec2 vec : TEXCOORD0 = vec2(0, 0);
        float f : TEXCOORD1 = float(1);
        float f2 : TEXCOORD2;
    }"""
    varying_def, _ = parse_shader('input', source)
    assert varying_def == expected_result

    # extra whitespaces
    source = """

    @input {

            vec2     vec     :   TEXCOORD0  =    vec2(  0   ,   0   )   ;

        float  f  :  TEXCOORD1  =  float( 1 ) ;

        float f2 :
            TEXCOORD2;

    }

    """
    varying_def, _ = parse_shader('input', source)
    assert varying_def == expected_result

    # no whitespaces
    source = "@input{vec2 vec:TEXCOORD0=vec2(0,0);float f:TEXCOORD1=float(1);" \
        "float f2:TEXCOORD2;}"
    varying_def, _ = parse_shader('input', source)
    assert varying_def == expected_result

    # comments
    source = """@input { // comment
        vec2 vec : TEXCOORD0 /* comment */ = vec2(0, 0);
        float f : TEXCOORD1 = float(1); //
        float f2 : TEXCOORD2 /**/;
    }"""
    varying_def, _ = parse_shader('input', source)
    assert varying_def == expected_result

    source = "@input {}"
    varying_def, _ = parse_shader('input', source)
    assert varying_def == []


@pytest.mark.usefixtures('test_engine')
def test_program_resource(
    vertex_shader_path: str,
    fragment_shader_path: str,
    vertex_shader: VertexShader,
    fragment_shader: FragmentShader
):
    from_objects = Program(vertex_shader, fragment_shader)

    assert from_objects.vertex_shader == vertex_shader
    assert from_objects.fragment_shader == fragment_shader

    from_files = Program.from_files(vertex_shader_path, fragment_shader_path)

    assert from_files == from_objects
    assert from_files.vertex_shader == vertex_shader
    assert from_files.fragment_shader == fragment_shader
