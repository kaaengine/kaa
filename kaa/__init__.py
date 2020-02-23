from ._version import get_versions
__version__ = get_versions()['version']
del get_versions


from .log import _initialize_kaa_logging_config

_initialize_kaa_logging_config()
del _initialize_kaa_logging_config
