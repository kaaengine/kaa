import logging
from enum import IntEnum

from .kaacore.log cimport (
    c_emit_log_dynamic, CLogLevel, c_get_logging_level,
    c_set_logging_level, c_initialize_logging, _log_category_app, _log_category_tools
)


class CoreLogLevel(IntEnum):
    trace = <uint32_t>CLogLevel.trace
    debug = <uint32_t>CLogLevel.debug
    info = <uint32_t>CLogLevel.info
    warn = <uint32_t>CLogLevel.warn
    error = <uint32_t>CLogLevel.error
    critical = <uint32_t>CLogLevel.critical
    off = <uint32_t>CLogLevel.off


cdef CLogLevel _python_to_core_level(level):
    if level < 10:
        return CLogLevel.trace
    elif 10 <= level < 20:
        return CLogLevel.debug
    elif 20 <= level < 30:
        return CLogLevel.info
    elif 30 <= level < 40:
        return CLogLevel.warn
    elif 40 <= level < 50:
        return CLogLevel.error
    else:
        return CLogLevel.critical


class CoreLogCategory(IntEnum):
    app = <uint32_t>_log_category_app
    tools = <uint32_t>_log_category_tools


class CoreHandler(logging.Handler):
    def __init__(self, level=logging.NOTSET, category=CoreLogCategory.app):
        super().__init__(level)
        self.category = category

    def handle(self, record):
        # simplified handle (no I/O locks)
        cdef int rv = self.filter(record)
        if rv:
            self.emit(record)
        return rv

    def emit(self, record):
        cdef bytes msg_enc
        try:
            msg_enc = self.format(record).encode('utf-8')
        except Exception:
            self.handleError(record)
        else:
            c_emit_log_dynamic(
                _python_to_core_level(record.levelno),
                self.category, msg_enc
            )


def get_core_logging_level(str core_category):
    return CoreLogLevel(<uint32_t>c_get_logging_level(
        core_category.encode('ascii')
    ))


def set_core_logging_level(str core_category, level):
    cdef CLogLevel core_level
    if isinstance(level, CoreLogLevel):
        core_level = <CLogLevel>(<uint32_t>level.value)
    else:
        core_level = _python_to_core_level(logging._checkLevel(level))
    c_set_logging_level(
        core_category.encode('ascii'), core_level
    )

c_initialize_logging()
