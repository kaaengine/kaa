import logging
from enum import IntEnum

from .kaacore.log cimport (
    c_log_dynamic, CLogLevel, CLogCategory, c_get_logging_level,
    c_set_logging_level, c_initialize_logging
)


class CoreLogLevel(IntEnum):
    verbose = <uint32_t>CLogLevel.verbose
    debug = <uint32_t>CLogLevel.debug
    info = <uint32_t>CLogLevel.info
    warn = <uint32_t>CLogLevel.warn
    error = <uint32_t>CLogLevel.error
    critical = <uint32_t>CLogLevel.critical


class CoreLogCategory(IntEnum):
    engine = <uint32_t>CLogCategory.engine
    renderer = <uint32_t>CLogCategory.renderer
    input = <uint32_t>CLogCategory.input
    audio = <uint32_t>CLogCategory.audio
    nodes = <uint32_t>CLogCategory.nodes
    physics = <uint32_t>CLogCategory.physics
    misc = <uint32_t>CLogCategory.misc
    application = <uint32_t>CLogCategory.application


cdef CLogLevel _python_to_core_level(level):
    if level < 10:
        return CLogLevel.verbose
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


cdef int _core_to_python_level(CLogLevel level):
    if level == CLogLevel.verbose:
        return logging.NOTSET
    elif level == CLogLevel.debug:
        return logging.DEBUG
    elif level == CLogLevel.info:
        return logging.INFO
    elif level == CLogLevel.warn:
        return logging.WARN
    elif level == CLogLevel.error:
        return logging.ERROR
    else:
        return logging.CRITICAL


class CoreHandler(logging.Handler):
    def __init__(self, core_category=CoreLogCategory.application):
        assert isinstance(core_category, CoreLogCategory)
        super().__init__()
        self._core_category = core_category

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
            c_log_dynamic(
                _python_to_core_level(record.levelno),
                <CLogCategory>(<uint32_t>self._core_category),
                msg_enc
            )


def get_core_logging_level(core_category):
    return CoreLogLevel(<uint32_t>c_get_logging_level(
        <CLogCategory>(<uint32_t>core_category.value)
    ))


def set_core_logging_level(core_category, level):
    cdef CLogLevel core_level
    if isinstance(level, CoreLogLevel):
        core_level = <CLogLevel>(<uint32_t>level.value)
    else:
        core_level = _python_to_core_level(logging._checkLevel(level))
    c_set_logging_level(
        <CLogCategory>(<uint32_t>core_category.value),
        core_level
    )

c_initialize_logging()
