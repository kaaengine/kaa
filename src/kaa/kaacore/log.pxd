from .exceptions cimport raise_py_error


cdef extern from "kaacore/log.h" namespace "kaacore" nogil:
    size_t _log_category_app
    size_t _log_category_wrapper
    size_t _log_category_tools

    cdef enum CLogLevel "spdlog::level::level_enum":
        trace "spdlog::level::level_enum::trace",
        debug "spdlog::level::level_enum::debug",
        info "spdlog::level::level_enum::info",
        warn "spdlog::level::level_enum::warn",
        error "spdlog::level::level_enum::err",
        critical "spdlog::level::level_enum::critical",
        off "spdlog::level::level_enum::off",

    void c_emit_log_dynamic "kaacore::emit_log_dynamic"(
         const CLogLevel level, const size_t logger_index, const char* msg
    ) except +raise_py_error
    CLogLevel c_get_logging_level "kaacore::get_logging_level"(const char* category) \
         except +raise_py_error
    void c_set_logging_level "kaacore::set_logging_level"(const char* category, const CLogLevel level) \
         except +raise_py_error
    void c_initialize_logging "kaacore::initialize_logging"() except +raise_py_error
