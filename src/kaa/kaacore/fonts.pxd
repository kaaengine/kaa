from libcpp.string cimport string
from libcpp cimport bool

from .exceptions cimport raise_py_error
from .unicode_buffer cimport CUnicodeView


cdef extern from "kaacore/fonts.h" namespace "kaacore" nogil:
    cdef cppclass CFont "kaacore::Font":
        @staticmethod
        CFont load(const string& font_filepath) \
            except +raise_py_error
        @staticmethod
        CFont load(const string& font_filepath, const CUnicodeView additional_codepoints) \
            except +raise_py_error

        bool operator==(const CFont&)

    cdef cppclass CTextNode "kaacore::TextNode":
        CUnicodeView content() \
            except +raise_py_error
        void content(const CUnicodeView content) \
            except +raise_py_error

        double font_size() \
            except +raise_py_error
        void font_size(const double font_size) \
            except +raise_py_error

        double line_width() \
            except +raise_py_error
        void line_width(const double line_width) \
            except +raise_py_error

        double interline_spacing() \
            except +raise_py_error
        void interline_spacing(const double interline_spacing) \
            except +raise_py_error

        double first_line_indent() \
            except +raise_py_error
        void first_line_indent(const double first_line_indent) \
            except +raise_py_error

        CFont font() \
            except +raise_py_error
        void font(const CFont& font) \
            except +raise_py_error
