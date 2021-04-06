from __future__ import annotations

from typing import final

import enum


class AudioStatus(enum.IntEnum):
    paused: AudioStatus
    playing: AudioStatus
    stopped: AudioStatus


@final
class Sound:
    def __init__(self, sound_filepath: str, volume: float = ...) -> None:
        ...

    @property
    def volume(self) -> float:
        ...

    def play(self, volume: float = 1.) -> None:
        ...

    def __eq__(self, other) -> bool:
        ...

    def __hash__(self) -> int:
        ...


@final
class SoundPlayback:
    def __init__(self, sound: Sound, volume: float = ...) -> None:
        ...

    @property
    def is_paused(self) -> bool:
        ...

    @property
    def is_playing(self) -> bool:
        ...

    @property
    def sound(self) -> Sound:
        ...

    @property
    def status(self) -> AudioStatus:
        ...

    @property
    def volume(self) -> float:
        ...

    @volume.setter
    def volume(self, value: float) -> None:
        ...

    def pause(self) -> None:
        ...

    def play(self, loops: int = 1) -> None:
        ...

    def resume(self) -> None:
        ...

    def stop(self) -> None:
        ...


@final
class Music:
    def __init__(self, music_filepath: str, volume: float = ...) -> None:
        ...

    @staticmethod
    def get_current() -> Music:
        ...

    @property
    def is_paused(self) -> bool:
        ...

    @property
    def is_playing(self) -> bool:
        ...

    @property
    def status(self) -> AudioStatus:
        ...

    @property
    def volume(self) -> float:
        ...

    def pause(self) -> None:
        ...

    def play(self, volume: float = 1.) -> None:
        ...

    def resume(self) -> None:
        ...

    def stop(self) -> None:
        ...

    def __eq__(self, other) -> bool:
        ...

    def __hash__(self) -> int:
        ...
