from .kaacore.nodes cimport CNodeType
from .kaacore.fonts cimport CFont, CTextNode


cdef class Font:
    cdef CFont c_font

    cdef void _attach_c_font(self, const CFont& c_font):
        self.c_font = c_font

    def __init__(self, str font_filepath):
        self._attach_c_font(CFont.load(font_filepath.encode()))


cdef Font get_font_wrapper(const CFont& c_font):
    cdef Font font = Font.__new__(Font)
    font._attach_c_font(c_font)
    return font


cdef class TextNode(NodeBase):
    def __init__(self, **options):
        self._init_new_node(CNodeType.text)
        super().__init__(**options)

    def setup(self, **options):
        if 'font' in options:
            self.font = options.pop('font')
        if 'content' in options:
            self.content = options.pop('content')
        if 'font_size' in options:
            self.font_size = options.pop('font_size')
        if 'line_width' in options:
            self.line_width = options.pop('line_width')
        if 'interline_spacing' in options:
            self.interline_spacing = options.pop('interline_spacing')
        if 'first_line_indent' in options:
            self.first_line_indent = options.pop('first_line_indent')

    @property
    def content(self):
        return (<bytes>self._get_c_node().text.content()).decode()

    @content.setter
    def content(self, str content_text):
        self._get_c_node().text.content(<string>content_text.encode())

    @property
    def font_size(self):
        return self._get_c_node().text.font_size()

    @font_size.setter
    def font_size(self, double new_font_size):
        self._get_c_node().text.font_size(new_font_size)

    @property
    def line_width(self):
        return self._get_c_node().text.line_width()

    @line_width.setter
    def line_width(self, double new_line_width):
        self._get_c_node().text.line_width(new_line_width)

    @property
    def interline_spacing(self):
        return self._get_c_node().text.interline_spacing()

    @interline_spacing.setter
    def interline_spacing(self, double new_interline_spacing):
        self._get_c_node().text.interline_spacing(new_interline_spacing)

    @property
    def first_line_indent(self):
        return self._get_c_node().text.first_line_indent()

    @first_line_indent.setter
    def first_line_indent(self, double new_first_line_indent):
        self._get_c_node().text.first_line_indent(new_first_line_indent)

    @property
    def font(self):
        return get_font_wrapper(self._get_c_node().text.font())

    @font.setter
    def font(self, Font new_font not None):
        self._get_c_node().text.font(new_font.c_font)
