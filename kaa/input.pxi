from enum import IntEnum

import cython
from libc.stdint cimport uint32_t
from libcpp.vector cimport vector

from .kaacore.engine cimport CEngine, get_c_engine
from .kaacore.input cimport CKeycode, CMousecode, CEvent, CInputManager


DEF EVENT_FREELIST_SIZE = 10


class Keycode(IntEnum):
    unknown = <uint32_t>CKeycode.unknown
    return_ = <uint32_t>CKeycode.return_
    escape = <uint32_t>CKeycode.escape
    backspace = <uint32_t>CKeycode.backspace
    tab = <uint32_t>CKeycode.tab
    space = <uint32_t>CKeycode.space
    exclaim = <uint32_t>CKeycode.exclaim
    quotedbl = <uint32_t>CKeycode.quotedbl
    hash = <uint32_t>CKeycode.hash
    percent = <uint32_t>CKeycode.percent
    dollar = <uint32_t>CKeycode.dollar
    ampersand = <uint32_t>CKeycode.ampersand
    quote = <uint32_t>CKeycode.quote
    leftparen = <uint32_t>CKeycode.leftparen
    rightparen = <uint32_t>CKeycode.rightparen
    asterisk = <uint32_t>CKeycode.asterisk
    plus = <uint32_t>CKeycode.plus
    comma = <uint32_t>CKeycode.comma
    minus = <uint32_t>CKeycode.minus
    period = <uint32_t>CKeycode.period
    slash = <uint32_t>CKeycode.slash
    num_0 = <uint32_t>CKeycode.num_0
    num_1 = <uint32_t>CKeycode.num_1
    num_2 = <uint32_t>CKeycode.num_2
    num_3 = <uint32_t>CKeycode.num_3
    num_4 = <uint32_t>CKeycode.num_4
    num_5 = <uint32_t>CKeycode.num_5
    num_6 = <uint32_t>CKeycode.num_6
    num_7 = <uint32_t>CKeycode.num_7
    num_8 = <uint32_t>CKeycode.num_8
    num_9 = <uint32_t>CKeycode.num_9
    colon = <uint32_t>CKeycode.colon
    semicolon = <uint32_t>CKeycode.semicolon
    less = <uint32_t>CKeycode.less
    equals = <uint32_t>CKeycode.equals
    greater = <uint32_t>CKeycode.greater
    question = <uint32_t>CKeycode.question
    at = <uint32_t>CKeycode.at
    leftbracket = <uint32_t>CKeycode.leftbracket
    backslash = <uint32_t>CKeycode.backslash
    rightbracket = <uint32_t>CKeycode.rightbracket
    caret = <uint32_t>CKeycode.caret
    underscore = <uint32_t>CKeycode.underscore
    backquote = <uint32_t>CKeycode.backquote
    a = <uint32_t>CKeycode.a
    b = <uint32_t>CKeycode.b
    c = <uint32_t>CKeycode.c
    d = <uint32_t>CKeycode.d
    e = <uint32_t>CKeycode.e
    f = <uint32_t>CKeycode.f
    g = <uint32_t>CKeycode.g
    h = <uint32_t>CKeycode.h
    i = <uint32_t>CKeycode.i
    j = <uint32_t>CKeycode.j
    k = <uint32_t>CKeycode.k
    l = <uint32_t>CKeycode.l
    m = <uint32_t>CKeycode.m
    n = <uint32_t>CKeycode.n
    o = <uint32_t>CKeycode.o
    p = <uint32_t>CKeycode.p
    q = <uint32_t>CKeycode.q
    r = <uint32_t>CKeycode.r
    s = <uint32_t>CKeycode.s
    t = <uint32_t>CKeycode.t
    u = <uint32_t>CKeycode.u
    v = <uint32_t>CKeycode.v
    w = <uint32_t>CKeycode.w
    x = <uint32_t>CKeycode.x
    y = <uint32_t>CKeycode.y
    z = <uint32_t>CKeycode.z
    A = <uint32_t>CKeycode.A
    B = <uint32_t>CKeycode.B
    C = <uint32_t>CKeycode.C
    D = <uint32_t>CKeycode.D
    E = <uint32_t>CKeycode.E
    F = <uint32_t>CKeycode.F
    G = <uint32_t>CKeycode.G
    H = <uint32_t>CKeycode.H
    I = <uint32_t>CKeycode.I
    J = <uint32_t>CKeycode.J
    K = <uint32_t>CKeycode.K
    L = <uint32_t>CKeycode.L
    M = <uint32_t>CKeycode.M
    N = <uint32_t>CKeycode.N
    O = <uint32_t>CKeycode.O
    P = <uint32_t>CKeycode.P
    Q = <uint32_t>CKeycode.Q
    R = <uint32_t>CKeycode.R
    S = <uint32_t>CKeycode.S
    T = <uint32_t>CKeycode.T
    U = <uint32_t>CKeycode.U
    V = <uint32_t>CKeycode.V
    W = <uint32_t>CKeycode.W
    X = <uint32_t>CKeycode.X
    Y = <uint32_t>CKeycode.Y
    Z = <uint32_t>CKeycode.Z
    capslock = <uint32_t>CKeycode.capslock
    F1 = <uint32_t>CKeycode.F1
    F2 = <uint32_t>CKeycode.F2
    F3 = <uint32_t>CKeycode.F3
    F4 = <uint32_t>CKeycode.F4
    F5 = <uint32_t>CKeycode.F5
    F6 = <uint32_t>CKeycode.F6
    F7 = <uint32_t>CKeycode.F7
    F8 = <uint32_t>CKeycode.F8
    F9 = <uint32_t>CKeycode.F9
    F10 = <uint32_t>CKeycode.F10
    F11 = <uint32_t>CKeycode.F11
    F12 = <uint32_t>CKeycode.F12
    printscreen = <uint32_t>CKeycode.printscreen
    scrolllock = <uint32_t>CKeycode.scrolllock
    pause = <uint32_t>CKeycode.pause
    insert = <uint32_t>CKeycode.insert
    home = <uint32_t>CKeycode.home
    pageup = <uint32_t>CKeycode.pageup
    delete_ = <uint32_t>CKeycode.delete_
    end = <uint32_t>CKeycode.end
    pagedown = <uint32_t>CKeycode.pagedown
    right = <uint32_t>CKeycode.right
    left = <uint32_t>CKeycode.left
    down = <uint32_t>CKeycode.down
    up = <uint32_t>CKeycode.up
    numlockclear = <uint32_t>CKeycode.numlockclear
    kp_divide = <uint32_t>CKeycode.kp_divide
    kp_multiply = <uint32_t>CKeycode.kp_multiply
    kp_minus = <uint32_t>CKeycode.kp_minus
    kp_plus = <uint32_t>CKeycode.kp_plus
    kp_enter = <uint32_t>CKeycode.kp_enter
    kp_1 = <uint32_t>CKeycode.kp_1
    kp_2 = <uint32_t>CKeycode.kp_2
    kp_3 = <uint32_t>CKeycode.kp_3
    kp_4 = <uint32_t>CKeycode.kp_4
    kp_5 = <uint32_t>CKeycode.kp_5
    kp_6 = <uint32_t>CKeycode.kp_6
    kp_7 = <uint32_t>CKeycode.kp_7
    kp_8 = <uint32_t>CKeycode.kp_8
    kp_9 = <uint32_t>CKeycode.kp_9
    kp_0 = <uint32_t>CKeycode.kp_0
    kp_period = <uint32_t>CKeycode.kp_period
    application = <uint32_t>CKeycode.application
    power = <uint32_t>CKeycode.power
    kp_equals = <uint32_t>CKeycode.kp_equals
    F13 = <uint32_t>CKeycode.F13
    F14 = <uint32_t>CKeycode.F14
    F15 = <uint32_t>CKeycode.F15
    F16 = <uint32_t>CKeycode.F16
    F17 = <uint32_t>CKeycode.F17
    F18 = <uint32_t>CKeycode.F18
    F19 = <uint32_t>CKeycode.F19
    F20 = <uint32_t>CKeycode.F20
    F21 = <uint32_t>CKeycode.F21
    F22 = <uint32_t>CKeycode.F22
    F23 = <uint32_t>CKeycode.F23
    F24 = <uint32_t>CKeycode.F24
    execute = <uint32_t>CKeycode.execute
    help = <uint32_t>CKeycode.help
    menu = <uint32_t>CKeycode.menu
    select = <uint32_t>CKeycode.select
    stop = <uint32_t>CKeycode.stop
    again = <uint32_t>CKeycode.again
    undo = <uint32_t>CKeycode.undo
    cut = <uint32_t>CKeycode.cut
    copy = <uint32_t>CKeycode.copy
    paste = <uint32_t>CKeycode.paste
    find = <uint32_t>CKeycode.find
    mute = <uint32_t>CKeycode.mute
    volumeup = <uint32_t>CKeycode.volumeup
    volumedown = <uint32_t>CKeycode.volumedown
    kp_comma = <uint32_t>CKeycode.kp_comma
    kp_equalsas400 = <uint32_t>CKeycode.kp_equalsas400
    alterase = <uint32_t>CKeycode.alterase
    sysreq = <uint32_t>CKeycode.sysreq
    cancel = <uint32_t>CKeycode.cancel
    clear = <uint32_t>CKeycode.clear
    prior = <uint32_t>CKeycode.prior
    return2 = <uint32_t>CKeycode.return2
    separator = <uint32_t>CKeycode.separator
    out = <uint32_t>CKeycode.out
    oper = <uint32_t>CKeycode.oper
    clearagain = <uint32_t>CKeycode.clearagain
    crsel = <uint32_t>CKeycode.crsel
    exsel = <uint32_t>CKeycode.exsel
    kp_00 = <uint32_t>CKeycode.kp_00
    kp_000 = <uint32_t>CKeycode.kp_000
    thousandsseparator = <uint32_t>CKeycode.thousandsseparator
    decimalseparator = <uint32_t>CKeycode.decimalseparator
    currencyunit = <uint32_t>CKeycode.currencyunit
    currencysubunit = <uint32_t>CKeycode.currencysubunit
    kp_leftparen = <uint32_t>CKeycode.kp_leftparen
    kp_rightparen = <uint32_t>CKeycode.kp_rightparen
    kp_leftbrace = <uint32_t>CKeycode.kp_leftbrace
    kp_rightbrace = <uint32_t>CKeycode.kp_rightbrace
    kp_tab = <uint32_t>CKeycode.kp_tab
    kp_backspace = <uint32_t>CKeycode.kp_backspace
    kp_a = <uint32_t>CKeycode.kp_a
    kp_b = <uint32_t>CKeycode.kp_b
    kp_c = <uint32_t>CKeycode.kp_c
    kp_d = <uint32_t>CKeycode.kp_d
    kp_e = <uint32_t>CKeycode.kp_e
    kp_f = <uint32_t>CKeycode.kp_f
    kp_xor = <uint32_t>CKeycode.kp_xor
    kp_power = <uint32_t>CKeycode.kp_power
    kp_percent = <uint32_t>CKeycode.kp_percent
    kp_less = <uint32_t>CKeycode.kp_less
    kp_greater = <uint32_t>CKeycode.kp_greater
    kp_ampersand = <uint32_t>CKeycode.kp_ampersand
    kp_dblampersand = <uint32_t>CKeycode.kp_dblampersand
    kp_verticalbar = <uint32_t>CKeycode.kp_verticalbar
    kp_dblverticalbar = <uint32_t>CKeycode.kp_dblverticalbar
    kp_colon = <uint32_t>CKeycode.kp_colon
    kp_hash = <uint32_t>CKeycode.kp_hash
    kp_space = <uint32_t>CKeycode.kp_space
    kp_at = <uint32_t>CKeycode.kp_at
    kp_exclam = <uint32_t>CKeycode.kp_exclam
    kp_memstore = <uint32_t>CKeycode.kp_memstore
    kp_memrecall = <uint32_t>CKeycode.kp_memrecall
    kp_memclear = <uint32_t>CKeycode.kp_memclear
    kp_memadd = <uint32_t>CKeycode.kp_memadd
    kp_memsubtract = <uint32_t>CKeycode.kp_memsubtract
    kp_memmultiply = <uint32_t>CKeycode.kp_memmultiply
    kp_memdivide = <uint32_t>CKeycode.kp_memdivide
    kp_plusminus = <uint32_t>CKeycode.kp_plusminus
    kp_clear = <uint32_t>CKeycode.kp_clear
    kp_clearentry = <uint32_t>CKeycode.kp_clearentry
    kp_binary = <uint32_t>CKeycode.kp_binary
    kp_octal = <uint32_t>CKeycode.kp_octal
    kp_decimal = <uint32_t>CKeycode.kp_decimal
    kp_hexadecimal = <uint32_t>CKeycode.kp_hexadecimal
    lctrl = <uint32_t>CKeycode.lctrl
    lshift = <uint32_t>CKeycode.lshift
    lalt = <uint32_t>CKeycode.lalt
    lgui = <uint32_t>CKeycode.lgui
    rctrl = <uint32_t>CKeycode.rctrl
    rshift = <uint32_t>CKeycode.rshift
    ralt = <uint32_t>CKeycode.ralt
    rgui = <uint32_t>CKeycode.rgui
    mode = <uint32_t>CKeycode.mode
    audionext = <uint32_t>CKeycode.audionext
    audioprev = <uint32_t>CKeycode.audioprev
    audiostop = <uint32_t>CKeycode.audiostop
    audioplay = <uint32_t>CKeycode.audioplay
    audiomute = <uint32_t>CKeycode.audiomute
    mediaselect = <uint32_t>CKeycode.mediaselect
    www = <uint32_t>CKeycode.www
    mail = <uint32_t>CKeycode.mail
    calculator = <uint32_t>CKeycode.calculator
    computer = <uint32_t>CKeycode.computer
    ac_search = <uint32_t>CKeycode.ac_search
    ac_home = <uint32_t>CKeycode.ac_home
    ac_back = <uint32_t>CKeycode.ac_back
    ac_forward = <uint32_t>CKeycode.ac_forward
    ac_stop = <uint32_t>CKeycode.ac_stop
    ac_refresh = <uint32_t>CKeycode.ac_refresh
    ac_bookmarks = <uint32_t>CKeycode.ac_bookmarks
    brightnessdown = <uint32_t>CKeycode.brightnessdown
    brightnessup = <uint32_t>CKeycode.brightnessup
    displayswitch = <uint32_t>CKeycode.displayswitch
    kbdillumtoggle = <uint32_t>CKeycode.kbdillumtoggle
    kbdillumdown = <uint32_t>CKeycode.kbdillumdown
    kbdillumup = <uint32_t>CKeycode.kbdillumup
    eject = <uint32_t>CKeycode.eject
    sleep = <uint32_t>CKeycode.sleep


class Mousecode(IntEnum):
    left = <uint32_t>CMousecode.left
    right = <uint32_t>CMousecode.right


@cython.final
@cython.freelist(EVENT_FREELIST_SIZE)
cdef class Event:
    cdef CEvent c_event

    cdef _set_event(self, const CEvent c_event):
        self.c_event = c_event

    def is_quit(self):
        return self.c_event.is_quit()

    def is_keyboard_event(self):
        return self.c_event.is_keyboard_event()

    def is_mouse_event(self):
        return self.c_event.is_mouse_event()

    def is_pressing(self, code):
        if isinstance(code, Keycode):
            return self.c_event.is_pressing(<CKeycode>(<uint32_t>(code.value)))
        elif isinstance(code, Mousecode):
            return self.c_event.is_pressing(<CMousecode>(<uint32_t>(code.value)))
        else:
            raise ValueError()

    def is_releasing(self, code):
        if isinstance(code, Keycode):
            return self.c_event.is_releasing(<CKeycode>(<uint32_t>(code.value)))
        elif isinstance(code, Mousecode):
            return self.c_event.is_releasing(<CMousecode>(<uint32_t>(code.value)))
        else:
            raise ValueError()

    def get_mouse_position(self):
        return Vector.from_c_vector(self.c_event.get_mouse_position())


cdef class InputManager:
    cdef CInputManager* c_input_manager

    def __cinit__(self):
        cdef CEngine* c_engine = get_c_engine()
        self.c_input_manager = c_engine.input_manager.get()

    def events(self):
        assert self.c_input_manager != NULL
        cdef Event py_event
        cdef CEvent ev
        for ev in self.c_input_manager.events_queue:
            py_event = Event()
            py_event._set_event(ev)
            yield py_event

    def is_pressing(self, code):
        if isinstance(code, Keycode):
            return self.c_input_manager.is_pressed(<CKeycode>(<uint32_t>(code.value)))
        elif isinstance(code, Mousecode):
            return self.c_input_manager.is_pressed(<CMousecode>(<uint32_t>(code.value)))
        else:
            raise ValueError()

    def is_releasing(self, code):
        if isinstance(code, Keycode):
            return self.c_input_manager.is_released(<CKeycode>(<uint32_t>(code.value)))
        elif isinstance(code, Mousecode):
            return self.c_input_manager.is_released(<CMousecode>(<uint32_t>(code.value)))
        else:
            raise ValueError()

    def get_mouse_position(self):
        return Vector.from_c_vector(self.c_input_manager.get_mouse_position())
