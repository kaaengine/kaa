:mod:`log` --- kaaengine logging settings
=========================================
.. module:: log
    :synopsis: kaaengine logging settings

By default kaa logs everything to stderr.

:meth:`get_core_logging_level` reference
-----------------------------------------

.. function:: get_core_logging_level(core_catgory)

    Gets logging level for given category. The :code:`core_category` param must be a :class:`CoreLogCategory` enum
    value.


:meth:`set_core_logging_level` reference
----------------------------------------

.. function:: set_core_logging_level(core_catgory, level)

    Sets a logging level for given category.

    The :code:`core_category` param must be a string with kaa module name.

    List of available kaa module names: "nodes", "node_ptr", "engine", "files", "log", "renderer",
    "images", "input", "audio", "scenes", "shapes", "physics",
    "resources", "resources_manager", "sprites", "window", "geometry",
    "fonts", "timers", "transitions", "node_transitions", "camera",
    "views", "spatial_index", "threading", "utils", "embedded_data",
    "easings", "shaders", "other", "app", "wrapper"

    The :code:`level` parameter must be a :class:`CoreLogLevel` enum value.

    .. note::

        By default kaa logs everything to stderr.

    .. code-block:: python

        from kaa.log import set_core_logging_level, CoreLogCategory, CoreLogLevel

        set_core_logging_level("audio", CoreLogLevel.verbose)


:class:`CoreLogLevel` reference
-------------------------------

.. class:: CoreLogLevel

    Enum type used to reference log levels. Available values are:

    * :code:`CoreLogLevel.verbose`
    * :code:`CoreLogLevel.debug`
    * :code:`CoreLogLevel.info`
    * :code:`CoreLogLevel.warn`
    * :code:`CoreLogLevel.error`
    * :code:`CoreLogLevel.critical`
