from libcpp.string cimport string


cdef extern from "kaacore/fonts.h" nogil:
    cdef cppclass CFont "kaacore::Font":
        @staticmethod
        CFont load(const string& font_filepath)

    cdef cppclass CTextNode "kaacore::TextNode":
        string content()
        void content(const string& content)

        double font_size()
        void font_size(const double font_size)

        double line_width()
        void line_width(const double line_width)

        double interline_spacing()
        void interline_spacing(const double interline_spacing)

        double first_line_indent()
        void first_line_indent(const double first_line_indent)

        CFont font()
        void font(const CFont& font)
