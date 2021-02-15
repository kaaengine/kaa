from libcpp.vector cimport vector
from libcpp.pair cimport pair
from libcpp.string cimport string

from .exceptions cimport raise_py_error


ctypedef pair[string, double] CPairStatisticLastValue


cdef extern from "kaacore/statistics.h" nogil:
    cdef cppclass CStatisticsManager "kaacore::StatisticsManager":
        vector[CPairStatisticLastValue] get_last_all() except +raise_py_error

    cdef CStatisticsManager& c_get_global_statistics_manager "kaacore::get_global_statistics_manager"()
