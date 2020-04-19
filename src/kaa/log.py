import logging.config

from ._kaa import (
    get_core_logging_level, set_core_logging_level, CoreLogLevel,
    CoreLogCategory, CoreHandler,
)


LOGGING_CONFIG = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'core': {
            'class': 'kaa.log.CoreHandler',
            'level': 'NOTSET',
        },
    },
    'loggers': {
        'kaa': {
            'handlers': ['core'],
            'level': 'DEBUG',
            'propagate': False,
        },
    },
}


def _initialize_kaa_logging_config():
    logging.config.dictConfig(LOGGING_CONFIG)
