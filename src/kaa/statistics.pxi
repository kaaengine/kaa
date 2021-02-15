from .kaacore.statistics cimport (
    CStatisticsManager, c_get_global_statistics_manager, CPairStatisticLastValue,
)


cdef class StatisticsManager:
    cdef CStatisticsManager* c_statistics_manager

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


cdef StatisticsManager _global_statistics_manager = StatisticsManager.create(
    &c_get_global_statistics_manager()
)


def get_global_statistics_manager():
    return _global_statistics_manager
