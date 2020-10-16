from .exceptions cimport raise_py_error


cdef extern from "kaacore/log.h" nogil:
    size_t _log_category_app "kaacore::_log_category_app"
    size_t _log_category_wrapper "kaacore::_log_category_wrapper"

    cdef enum CLogLevel "spdlog::level::level_enum":
        trace "spdlog::level::level_enum::trace",
        debug "spdlog::level::level_enum::debug",
        info "spdlog::level::level_enum::info",
        warn "spdlog::level::level_enum::warn",
        error "spdlog::level::level_enum::err",
        critical "spdlog::level::level_enum::critical",
        off "spdlog::level::level_enum::off",

    void c_emit_log_dynamic "emit_log_dynamic"(const CLogLevel level, const size_t logger_index, const char* msg)

    CLogLevel c_get_logging_level "get_logging_level"(const char* category) \
         except +raise_py_error
    void c_set_logging_level "set_logging_level"(const char* category, const CLogLevel level) \
         except +raise_py_error

    void c_initialize_logging "initialize_logging"() except +raise_py_error
