from __future__ import annotations

import enum
from typing import type_check_only, Optional, Iterable, List, TypeVar

from .colors import Color
from .geometry import Vector, BoundingBox
from .input import InputManager
from .nodes import Node


class VirtualResolutionMode(enum.IntEnum):
    adaptive_stretch: VirtualResolutionMode
    aggresive_stretch: VirtualResolutionMode
    no_stretch: VirtualResolutionMode


@type_check_only
class EngineInstance:
    @property
    def audio(self) -> AudioManager:
        ...

    @property
    def current_scene(self) -> Scene:
        ...

    @property
    def virtual_resolution(self) -> Vector:
        ...

    @virtual_resolution.setter
    def virtual_resolution(self, new_resolution: Vector) -> None:
        ...

    @property
    def virtual_resolution_mode(self) -> VirtualResolutionMode:
        ...

    @virtual_resolution_mode.setter
    def virtual_resolution_mode(self, new_mode: VirtualResolutionMode) -> None:
        ...

    @property
    def window(self) -> Window:
        ...

    def change_scene(self, scene: Scene) -> None:
        ...

    def get_displays(self) -> List[Display]:
        ...

    def get_fps(self) -> float:
        ...

    def quit(self) -> None:
        ...

    def run(self, scene: Scene) -> None:
        ...

    def stop(self) -> None:
        ...

    def __enter__(self) -> EngineInstance:
        ...

    def __exit__(self, exc_type, exc_value, traceback) -> None:
        ...


def Engine(
    virtual_resolution: Vector,
    virtual_resolution_mode: Optional[VirtualResolutionMode]
    = VirtualResolutionMode.adaptive_stretch,
) -> EngineInstance:
    ...


def get_engine() -> Optional[EngineInstance]:
    ...


@type_check_only
class Display:
    @property
    def index(self) -> int:
        ...

    @property
    def name(self) -> str:
        ...

    @property
    def position(self) -> Vector:
        ...

    @property
    def size(self) -> Vector:
        ...


@type_check_only
class Window:
    @property
    def fullscreen(self) -> bool:
        ...

    @fullscreen.setter
    def fullscreen(self, fullscreen_state: bool) -> None:
        ...

    @property
    def position(self) -> Vector:
        ...

    @position.setter
    def position(self, new_position: Vector) -> None:
        ...

    @property
    def size(self) -> Vector:
        ...

    @size.setter
    def size(self, new_size: Vector) -> None:
        ...

    @property
    def title(self) -> str:
        ...

    @title.setter
    def title(self, new_title: str) -> None:
        ...

    def center(self) -> None:
        ...

    def hide(self) -> None:
        ...

    def maximize(self) -> None:
        ...

    def minimize(self) -> None:
        ...

    def restore(self) -> None:
        ...

    def show(self) -> None:
        ...


class Scene:
    @property
    def camera(self) -> Camera:
        ...

    @property
    def clear_color(self) -> Color:
        ...

    @clear_color.setter
    def clear_color(self, color: Color) -> None:
        ...

    @property
    def engine(self) -> Optional[EngineInstance]:
        ...

    @property
    def input(self) -> InputManager:
        ...

    @property
    def root(self) -> Node:
        ...

    @property
    def spatial_index(self) -> SpatialIndexManager:
        ...

    @property
    def time_scale(self) -> float:
        ...

    @time_scale.setter
    def time_scale(self, scale: float) -> None:
        ...

    @property
    def total_time(self) -> float:
        ...

    @property
    def views(self) -> ViewsManager:
        ...

    def __init__(self) -> None:
        ...

    def on_enter(self) -> None:
        ...

    def on_exit(self) -> None:
        ...

    def update(self, dt: float) -> None:
        ...


AnyScene = TypeVar('AnyScene', bound=Scene)


@type_check_only
class Camera:
    @property
    def position(self) -> Vector:
        ...

    @position.setter
    def position(self, vector: Vector) -> None:
        ...

    @property
    def rotation(self) -> float:
        ...

    @rotation.setter
    def rotation(self, value: float) -> None:
        ...

    @property
    def rotation_degrees(self) -> float:
        ...

    @rotation_degrees.setter
    def rotation_degrees(self, value: float) -> None:
        ...

    @property
    def scale(self) -> Vector:
        ...

    @scale.setter
    def scale(self, vector: Vector) -> None:
        ...

    @property
    def visible_area_bounding_box(self) -> BoundingBox:
        ...

    def unproject_position(self, position: Vector) -> Vector:
        ...


@type_check_only
class View:
    @property
    def camera(self) -> Camera:
        ...

    @property
    def clear_color(self) -> Color:
        ...

    @clear_color.setter
    def clear_color(self, color: Color) -> None:
        ...

    @property
    def dimensions(self) -> Vector:
        ...

    @dimensions.setter
    def dimensions(self, dimensions: Vector) -> None:
        ...

    @property
    def origin(self) -> Vector:
        ...

    @origin.setter
    def origin(self, origin: Vector) -> None:
        ...

    @property
    def z_index(self) -> int:
        ...


@type_check_only
class ViewsManager:
    def __getitem__(self, index: int) -> View:
        ...

    def __iter__(self) -> Iterable[View]:
        ...

    def __len__(self) -> int:
        ...


@type_check_only
class SpatialIndexManager:
    def query_bounding_box(
        self, bbox: BoundingBox, include_shapeless: bool = True
    ) -> List[Node]:
        ...

    def query_point(self, point: Vector) -> List[Node]:
        ...


@type_check_only
class AudioManager:
    @property
    def master_music_volume(self) -> float:
        ...

    @master_music_volume.setter
    def master_music_volume(self, vol: float) -> None:
        ...

    @property
    def master_sound_volume(self) -> float:
        ...

    @master_sound_volume.setter
    def master_sound_volume(self, vol: float) -> None:
        ...

    @property
    def master_volume(self) -> float:
        ...

    @master_volume.setter
    def master_volume(self, vol: float) -> None:
        ...

    @property
    def mixing_channels(self) -> int:
        ...

    @mixing_channels.setter
    def mixing_channels(self, ch: int) -> None:
        ...
