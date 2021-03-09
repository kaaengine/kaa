import enum
import logging


class CoreLogLevel(enum.IntEnum):
    critical: CoreLogLevel
    debug: CoreLogLevel
    error: CoreLogLevel
    info: CoreLogLevel
    off: CoreLogLevel
    trace: CoreLogLevel
    warn: CoreLogLevel


class CoreHandler(logging.Handler):
    ...


def get_core_logging_level(core_category: str) -> CoreLogLevel:
    ...


def set_core_logging_level(core_category: str, level: CoreLogLevel) -> None:
    ...
