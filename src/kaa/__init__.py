# Various package-level initializations goes here.
# Any non-essential variables should be del-ed,
# so we don't clutter kaa.* namespace.


# Version data from `versioneer` script.
from ._version import get_versions
__version__ = get_versions()['version']
del get_versions


# We initialize logging outside _kaa module,
# since the module itself is used in logging configuration
# dict, causing import issues.
from .log import _initialize_kaa_logging_config
_initialize_kaa_logging_config()
del _initialize_kaa_logging_config
