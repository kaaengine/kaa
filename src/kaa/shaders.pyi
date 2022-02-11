from __future__ import annotations

import enum
from typing import type_check_only, final


class ShaderType(enum.IntEnum):
    vertex: ShaderType
    fragment: ShaderType


@type_check_only
class ShaderBase:

    @property
    def type(self) -> ShaderType:
        ...


@final
class VertexShader(ShaderBase):
    ...


@final
class FragmentShader(ShaderBase):
    ...


@final
class Program:
    def __init__(vertex_shader: VertexShader, fragment_shader: FragmentShader):
        ...

    @property
    def vertex_shader(self) -> VertexShader:
        ...

    @property
    def fragment_shader(self) -> FragmentShader:
        ...

    @classmethod
    def from_files(cls, vertex_shader_path: str, fragment_shader_path: str):
        ...
