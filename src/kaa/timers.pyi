from __future__ import annotations

from typing import Callable, Optional, type_check_only

from .engine import Scene


@type_check_only
class TimerContext:
    @property
    def interval(self) -> float:
        ...

    @property
    def scene(self) -> Optional[Scene]:
        ...


class Timer:
    @property
    def is_running(self) -> bool:
        ...

    def __init__(self, callback: Callable[[TimerContext], Optional[float]]) -> None:
        ...

    def start(self, interval: float, scene: Scene) -> None:
        ...

    def start_global(self, interval: float) -> None:
        ...

    def stop(self) -> None:
        ...
