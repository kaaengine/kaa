import sys
import logging
import argparse
from pathlib import Path

from kaa.shaders import ShaderCompiler

logger = logging.getLogger(__name__)


def shaderc():
    compiler = ShaderCompiler()
    return compiler.compile(*sys.argv[1:])


def compile_shader():
    parser = argparse.ArgumentParser()
    parser.add_argument('source_file', help='Path to shader source file.')
    parser.add_argument(
        'type', choices=ShaderCompiler.SUPPORTED_TYPES, help='Shader type.'
    )
    parser.add_argument('varyingdef_path', help='Path to varying.def.sc file.')
    parser.add_argument(
        '-p', '--platform', choices=ShaderCompiler.SUPPORTED_PLATFORMS,
        nargs='+', default=None, help='Target platform.'
    )
    parser.add_argument(
        '-o', '--output_dir', default=None,
        help='Output directory. Source file directory will be used, If not provided'
    )
    args = parser.parse_args()
    compiler = ShaderCompiler()

    try:
        result = compiler.compile_for_platforms(
            platforms=args.platform, source_path=Path(args.source_file),
            type_=args.type, varyingdef_path=Path(args.varyingdef_path),
            output_dir=Path(args.output_dir) if args.output_dir is not None else None,
        )
    except RuntimeError as e:
        logger.error(str(e))
        return 1

    for shader_model, path in result.items():
        logger.info('Compiled %s shader: %s', shader_model, path)
    return 0
