import logging.config

from ._kaa import (
    get_core_logging_level, set_core_logging_level, CoreLogLevel, CoreHandler, CoreLogCategory
)


__all__ = (
    'get_core_logging_level', 'set_core_logging_level', 'CoreLogLevel', 'CoreHandler'
)


LOGGING_CONFIG = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'python': {
            'format': '%(message)s [%(filename)s:%(lineno)d]'
        }
    },
    'handlers': {
        'core': {
            'class': 'kaa.log.CoreHandler',
            'level': 'NOTSET',
        },
        'tools': {
            'class': 'kaa.log.CoreHandler',
            'category': CoreLogCategory.tools,
            'formatter': 'python',
        },
    },
    'loggers': {
        'kaa': {
            'handlers': ['core'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'kaa.shader_tools': {
            'handlers': ['tools'],
            'level': 'INFO',
            'propagate': False,
        },
    },
}


def _initialize_kaa_logging_config():
    logging.config.dictConfig(LOGGING_CONFIG)
