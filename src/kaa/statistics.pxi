from .kaacore.statistics cimport (
    CStatisticsManager, c_get_global_statistics_manager, CPairStatisticLastValue,
    CStatisticAnalysis, CPairStatisticAnalysis,
)


cdef class StatisticAnalysis:
    cdef CStatisticAnalysis c_statistic_analysis

    def __init__(self):
        raise RuntimeError(f'{self.__class__} must not be instantiated manually!')

    @staticmethod
    cdef create(CStatisticAnalysis c_statistic_analysis):
        cdef StatisticAnalysis statistic_analysis = \
            StatisticAnalysis.__new__(StatisticAnalysis)
        statistic_analysis.c_statistic_analysis = c_statistic_analysis
        return statistic_analysis

    def __repr__(self):
        return ("<StatisticAnalysis: samples_count:{}, last_value:{},"
                " mean_value:{}, max_value:{}, min_value:{},"
                " standard_deviation:{}").format(
                    self.samples_count, self.last_value, self.mean_value,
                    self.max_value, self.min_value, self.standard_deviation
                )

    @property
    def samples_count(self):
        return self.c_statistic_analysis.samples_count

    @property
    def last_value(self):
        return self.c_statistic_analysis.last_value

    @property
    def mean_value(self):
        return self.c_statistic_analysis.mean_value

    @property
    def max_value(self):
        return self.c_statistic_analysis.max_value

    @property
    def min_value(self):
        return self.c_statistic_analysis.min_value

    @property
    def standard_deviation(self):
        return self.c_statistic_analysis.standard_deviation


cdef class StatisticsManager:
    cdef CStatisticsManager* c_statistics_manager

    def __init__(self):
        raise RuntimeError(f'{self.__class__} must not be instantiated manually!')

    @staticmethod
    cdef create(CStatisticsManager* c_statistics_manager):
        assert c_statistics_manager
        cdef StatisticsManager statistics_manager = \
                StatisticsManager.__new__(StatisticsManager)
        statistics_manager.c_statistics_manager = c_statistics_manager
        return statistics_manager

    def get_last_all(self):
        cdef list results = []
        cdef CPairStatisticLastValue pair

        for pair in self.c_statistics_manager.get_last_all():
            results.append((pair.first.decode(), pair.second))
        return results

    def get_analysis_all(self):
        cdef list results = []
        cdef CPairStatisticAnalysis pair

        for pair in self.c_statistics_manager.get_analysis_all():
            results.append((pair.first.decode(),
                            StatisticAnalysis.create(pair.second)))
        return results

    def push_value(self, str stat_name, double value):
        self.c_statistics_manager.push_value(stat_name.encode(), value)


cdef StatisticsManager _global_statistics_manager = StatisticsManager.create(
    &c_get_global_statistics_manager()
)


def get_global_statistics_manager():
    return _global_statistics_manager
