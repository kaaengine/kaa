:mod:`statistics` --- Statistics module
=======================================
.. module:: statistics
    :synopsis: Statistics module

:class:`StatisticsManager` reference
------------------------------------

    Statistics manager is a reporting tool, surfacing basic metrics of kaa engine. To get the statistics manager
    instance use the :meth:`get_global_statistics_manager` method.

.. code-block:: python

    class MyScene(Scene):

        def __init__(self):

            self.stats_manager = get_global_statistics_manager()


        def update(self, dt):

            self.stats_manager.push_value('custom statistic', random.gauss(10, 2))

            print(self.stats_manager.get_last_all())
            print(self.stats_manager.get_analysis_all())


.. class:: StatisticsManager

Instance methods:

.. method:: StatisticsManager.get_last_all()

    Returns the last value of each metric. Returned is a list of tuples in form of ('statistic name', value)

.. method:: StatisticsManager.get_analysis_all()

    Returns aggregated metric data. Returned is a list of tuples in form of
    ('statistic name', <StatisticAnalysis instance>). Check out :class:`StatisticAnalysis` for more information.

.. method:: StatisticsManager.push_value(stat_name, value)

    Allows to push your own custom statistic. :code:`stat_name` must be a string, and :code:`value` must be a double.
    Your custom statistic will be reported by :meth:`get_last_all` and :meth:`get_analysis_all` methods.




:class:`StatisticAnalysis` reference
------------------------------------

.. class:: StatisticAnalysis

    The :code:`StatisticAnalysis` object wraps statistical properties of a larger sample of measurmenets.

Instance properties:

.. attribute:: StatisticAnalysis.samples_count

    Size of a sample.

.. attribute:: StatisticAnalysis.last_value

    The most recent value.

.. attribute:: StatisticAnalysis.mean_value

    The mean value.

.. attribute:: StatisticAnalysis.standard_deviation

    The standard deviation.

.. attribute:: StatisticAnalysis.max_value

    The maximum value.

.. attribute:: StatisticAnalysis.min_value

    The minimum value.



:meth:`get_global_statistics_manager` reference
-----------------------------------------------

.. function:: get_global_statistics_manager

    A method to get the :class:`StatisticsManager` instance.

