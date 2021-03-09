from typing import type_check_only, List, Tuple


class StatisticAnalysis:
    @property
    def last_value(self) -> float:
        ...

    @property
    def max_value(self) -> float:
        ...

    @property
    def mean_value(self) -> float:
        ...

    @property
    def min_value(self) -> float:
        ...

    @property
    def samples_count(self) -> int:
        ...

    @property
    def standard_deviation(self) -> float:
        ...


@type_check_only
class StatisticsManager:
    def get_analysis_all(self) -> List[Tuple[str, StatisticAnalysis]]:
        ...

    def get_last_all(self) -> List[Tuple[str, float]]:
        ...

    def push_value(self, stat_name: str, value: float) -> None:
        ...


def get_global_statistics_manager() -> StatisticsManager:
    ...
