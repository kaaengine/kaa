from .exceptions cimport raise_py_error


cdef extern from "kaacore/log.h" nogil:
    cdef enum CLogLevel "kaacore::LogLevel":
        verbose "kaacore::LogLevel::verbose",
        debug "kaacore::LogLevel::debug",
        info "kaacore::LogLevel::info",
        warn "kaacore::LogLevel::warn",
        error "kaacore::LogLevel::error",
        critical "kaacore::LogLevel::critical",

    cdef enum CLogCategory "kaacore::LogCategory":
        engine "kaacore::LogCategory::engine",
        renderer "kaacore::LogCategory::renderer",
        input "kaacore::LogCategory::input",
        audio "kaacore::LogCategory::audio",
        nodes "kaacore::LogCategory::nodes",
        physics "kaacore::LogCategory::physics",
        misc "kaacore::LogCategory::misc",
        application "kaacore::LogCategory::application",

    void log_dynamic(const CLogLevel level, const CLogCategory category, const char* msg)

    CLogLevel get_logging_level(const CLogCategory category)
    void set_logging_level(const CLogCategory category, const CLogLevel level)
