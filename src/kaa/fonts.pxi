from cpython.unicode cimport (
    PyUnicode_FromKindAndData, PyUnicode_KIND, PyUnicode_DATA,
    PyUnicode_GET_LENGTH,
)

from .kaacore.nodes cimport CNodeType
from .kaacore.fonts cimport CFont, CTextNode
from .kaacore.hashing cimport c_calculate_hash
from .kaacore.unicode_buffer cimport CUnicodeRepresentationSize, CUnicodeView


cdef object unicode_view_to_str(CUnicodeView view):
    return PyUnicode_FromKindAndData(
        <uint8_t>view.representation_size(),
        view.data(),
        view.length(),
    )


cdef CUnicodeView str_to_unicode_view(str text):
    return CUnicodeView(
        <uint8_t*>PyUnicode_DATA(text),
        PyUnicode_GET_LENGTH(text),
        <CUnicodeRepresentationSize>(<uint8_t>PyUnicode_KIND(text)),
    )


cdef class Font:
    cdef CFont c_font

    cdef void attach_c_font(self, const CFont& c_font):
        self.c_font = c_font

    def __init__(self, str font_filepath, str additional_codepoints=None):
        if additional_codepoints is None:
            self.attach_c_font(CFont.load(font_filepath.encode()))
        else:
            self.attach_c_font(CFont.load(font_filepath.encode(), str_to_unicode_view(additional_codepoints)))

    def __eq__(self, Font other):
        return self.c_font == other.c_font

    def __hash__(self):
        return c_calculate_hash[CFont](self.c_font)


cdef Font get_font_wrapper(const CFont& c_font):
    cdef Font font = Font.__new__(Font)
    font.attach_c_font(c_font)
    return font


cdef class TextNode(NodeBase):
    def __init__(self, **options):
        self.make_c_node(CNodeType.text)
        super().__init__(**options)

    def setup(self, **options):
        if 'font' in options:
            self.font = options.pop('font')
        if 'content' in options:
            self.content = options.pop('content')
        if 'text' in options:
            self.text = options.pop('text')
        if 'font_size' in options:
            self.font_size = options.pop('font_size')
        if 'line_width' in options:
            self.line_width = options.pop('line_width')
        if 'interline_spacing' in options:
            self.interline_spacing = options.pop('interline_spacing')
        if 'first_line_indent' in options:
            self.first_line_indent = options.pop('first_line_indent')

        return super().setup(**options)

    @property
    def content(self):
        return unicode_view_to_str(self.get_c_node().text.content())

    @content.setter
    def content(self, str content_text):
        self.get_c_node().text.content(str_to_unicode_view(content_text))

    @property
    def text(self):
        return unicode_view_to_str(self.get_c_node().text.content())

    @text.setter
    def text(self, str content_text):
        self.get_c_node().text.content(str_to_unicode_view(content_text))

    @property
    def font_size(self):
        return self.get_c_node().text.font_size()

    @font_size.setter
    def font_size(self, double new_font_size):
        self.get_c_node().text.font_size(new_font_size)

    @property
    def line_width(self):
        return self.get_c_node().text.line_width()

    @line_width.setter
    def line_width(self, double new_line_width):
        self.get_c_node().text.line_width(new_line_width)

    @property
    def interline_spacing(self):
        return self.get_c_node().text.interline_spacing()

    @interline_spacing.setter
    def interline_spacing(self, double new_interline_spacing):
        self.get_c_node().text.interline_spacing(new_interline_spacing)

    @property
    def first_line_indent(self):
        return self.get_c_node().text.first_line_indent()

    @first_line_indent.setter
    def first_line_indent(self, double new_first_line_indent):
        self.get_c_node().text.first_line_indent(new_first_line_indent)

    @property
    def font(self):
        return get_font_wrapper(self.get_c_node().text.font())

    @font.setter
    def font(self, Font new_font not None):
        self.get_c_node().text.font(new_font.c_font)
