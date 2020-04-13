:mod:`log` --- kaaengine logging settings
=========================================
.. module:: log
    :synopsis: kaaengine logging settings


:meth:`get_core_logging_level` reference
-----------------------------------------

.. function:: get_core_logging_level(core_catgory)

    Gets logging level for given category. The :code:`core_category` param must be a :class:`CoreLogCategory` enum
    value.


:meth:`set_core_logging_level` reference
----------------------------------------

.. function:: set_core_logging_level(core_catgory, level)

    Sets a logging level for given category.

    The :code:`core_category` param must be a :class:`CoreLogCategory` enum value. The :code:`level` parameter
    must be a :class:`CoreLogLevel` enum value.

    .. code-block:: python

        from kaa.log import set_core_logging_level, CoreLogCategory, CoreLogLevel

        set_core_logging_level(CoreLogCategory.audio, CoreLogLevel.verbose)

:class:`CoreLogCategory` reference
----------------------------------

.. class:: CoreLogCategory

    Enum type used to reference log categories. Available values are:

    * :code:`CoreLogCategory.engine`
    * :code:`CoreLogCategory.renderer`
    * :code:`CoreLogCategory.input`
    * :code:`CoreLogCategory.audio`
    * :code:`CoreLogCategory.nodes`
    * :code:`CoreLogCategory.physics`
    * :code:`CoreLogCategory.misc`
    * :code:`CoreLogCategory.application`

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
