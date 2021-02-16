from libc.stdint cimport uint32_t
from libcpp.vector cimport vector
from libcpp.pair cimport pair
from libcpp.string cimport string

from .exceptions cimport raise_py_error

ctypedef pair[string, double] CPairStatisticLastValue
ctypedef pair[string, CStatisticAnalysis] CPairStatisticAnalysis

cdef extern from "kaacore/statistics.h" nogil:
    cdef cppclass CStatisticAnalysis "kaacore::StatisticAnalysis":
        uint32_t samples_count
        double last_value
        double mean_value
        double max_value
        double min_value
        double standard_deviation

    cdef cppclass CStatisticsManager "kaacore::StatisticsManager":
        vector[CPairStatisticLastValue] get_last_all() except +raise_py_error
        vector[CPairStatisticAnalysis] get_analysis_all() except +raise_py_error
        void push_value(const string& name, const double value) except +raise_py_error

    cdef CStatisticsManager& c_get_global_statistics_manager "kaacore::get_global_statistics_manager"()
