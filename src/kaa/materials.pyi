from __future__ import annotations

import enum
from typing import final, type_check_only, Optional, Dict, Tuple

from .shaders import Program
from .textures import Texture


class UniformType(enum.IntEnum):
    sampler: UniformType
    vec4: UniformType
    mat3: UniformType
    mat4: UniformType


@final
class Uniform:
    def __init__(self, type_: UniformType, number_of_elements: int = ...):
        ...

    @property
    def type(self) -> UniformType:
        ...

    @property
    def number_of_elements(self) -> int:
        ...


@final
class SamplerValue:
    @property
    def stage(self) -> int:
        ...

    @property
    def flags(self) -> int:
        ...

    @property
    def texture(self) -> Texture:
        ...


@type_check_only
class ReadonlyBaseMaterial:
    def __init__(program: Program, uniforms: Optional[Dict[str, Uniform]]):
        ...

    @property
    def uniforms(self) -> Optional[Dict[str, Uniform]]:
        ...

    def get_uniform_texture(self, name: str) -> SamplerValue:
        ...

    def get_uniform_value(self, name: str) -> tuple:
        ...


@type_check_only
class BaseMaterial:
    def set_uniform_texture(
        self,
        name: str,
        texture: Texture,
        stage: int,
        flags: int = ...
    ):
        ...

    def set_uniform_value(self, name: str, value: Tuple[float, ...]):
        ...


@final
class Material(BaseMaterial):
    def clone(self) -> Material:
        ...


@final
class MaterialView(ReadonlyBaseMaterial):

    @property
    def source(self) -> Material:
        ...
