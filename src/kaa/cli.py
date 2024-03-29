import os
import sys
import logging
import argparse
from pathlib import Path

from kaa.shader_tools import CliShaderCompiler, UnsupportedPlatform

logger = logging.getLogger(__name__)


def shaderc():
    compiler = CliShaderCompiler(raise_on_compilation_error=False)
    return compiler.compile(*sys.argv[1:])


def compile_shader():
    parser = argparse.ArgumentParser()
    parser.add_argument('source_file', type=Path, help='path to shader source file')
    parser.add_argument(
        'type', choices=CliShaderCompiler.SUPPORTED_TYPES, help='shader type'
    )
    parser.add_argument(
        '-p', '--platform', choices=CliShaderCompiler.SUPPORTED_PLATFORMS,
        nargs='+', required=True, help='target platform'
    )
    parser.add_argument(
        '-o', '--output_dir', default=None, type=Path,
        help='output directory, source file directory will be used, if not provided'
    )
    args = parser.parse_args()
    output_dir = args.output_dir or args.source_file.parent
    compiler = CliShaderCompiler(raise_on_compilation_error=False)
    try:
        compiler.compile_for_platform(
            platform=set(args.platform), source_file=args.source_file,
            shader_type=args.type, output_dir=output_dir
        )
    except UnsupportedPlatform as e:
        logger.error(str(e))
        return 1
    return 0
