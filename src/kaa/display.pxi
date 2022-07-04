from .kaacore.display cimport CDisplay


cdef class Display:
    cdef CDisplay c_display

    @staticmethod
    cdef Display wrap_c_display(const CDisplay& c_display):
        cdef Display display = Display.__new__(Display)
        display.c_display = c_display
        return display

    def __repr__(self):
        return "<Display #{} '{}' {}x{} @{}x{}>".format(
            self.c_display.index, self.c_display.name.decode(),
            self.c_display.size.x, self.c_display.size.y,
            self.c_display.position.x, self.c_display.position.y,
        )

    @property
    def index(self):
        return self.c_display.index

    @property
    def name(self):
        return self.c_display.name.decode()

    @property
    def position(self):
        return Vector(self.c_display.position.x,
                      self.c_display.position.y)

    @property
    def size(self):
        return Vector(self.c_display.size.x,
                      self.c_display.size.y)
