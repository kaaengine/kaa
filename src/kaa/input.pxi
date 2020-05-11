import inspect
from enum import IntEnum
from collections import Iterable

import cython
from libcpp cimport nullptr
from cpython.ref cimport PyObject
from libc.stdint cimport int32_t, uint32_t
from libcpp.vector cimport vector
from cymove cimport cymove as cmove

from .kaacore.engine cimport CEngine, get_c_engine
from .kaacore.glue cimport CPythonicCallbackWrapper
from .kaacore.exceptions cimport CPythonException
from .kaacore.input cimport (
    CKeycode, CMouseButton, CControllerButton, CControllerAxis,
    CCompoundControllerAxis, CEventType, CSystemEvent, CWindowEvent,
    CKeyboardKeyEvent, CKeyboardTextEvent, CMouseButtonEvent, CMouseMotionEvent,
    CMouseWheelEvent, CControllerButtonEvent, CControllerAxisEvent, CMusicFinishedEvent,
    CEvent, CInputManager, CSystemManager, CKeyboardManager, CMouseManager,
    CControllerManager, CControllerID, CEventCallback, CythonEventCallback,
    bind_cython_event_callback
)


DEF EVENT_FREELIST_SIZE = 16


class Keycode(IntEnum):
    unknown = <uint32_t>CKeycode.k_unknown
    return_ = <uint32_t>CKeycode.k_return
    escape = <uint32_t>CKeycode.k_escape
    backspace = <uint32_t>CKeycode.k_backspace
    tab = <uint32_t>CKeycode.k_tab
    space = <uint32_t>CKeycode.k_space
    exclaim = <uint32_t>CKeycode.k_exclaim
    quotedbl = <uint32_t>CKeycode.k_quotedbl
    hash = <uint32_t>CKeycode.k_hash
    percent = <uint32_t>CKeycode.k_percent
    dollar = <uint32_t>CKeycode.k_dollar
    ampersand = <uint32_t>CKeycode.k_ampersand
    quote = <uint32_t>CKeycode.k_quote
    leftparen = <uint32_t>CKeycode.k_leftparen
    rightparen = <uint32_t>CKeycode.k_rightparen
    asterisk = <uint32_t>CKeycode.k_asterisk
    plus = <uint32_t>CKeycode.k_plus
    comma = <uint32_t>CKeycode.k_comma
    minus = <uint32_t>CKeycode.k_minus
    period = <uint32_t>CKeycode.k_period
    slash = <uint32_t>CKeycode.k_slash
    num_0 = <uint32_t>CKeycode.k_num_0
    num_1 = <uint32_t>CKeycode.k_num_1
    num_2 = <uint32_t>CKeycode.k_num_2
    num_3 = <uint32_t>CKeycode.k_num_3
    num_4 = <uint32_t>CKeycode.k_num_4
    num_5 = <uint32_t>CKeycode.k_num_5
    num_6 = <uint32_t>CKeycode.k_num_6
    num_7 = <uint32_t>CKeycode.k_num_7
    num_8 = <uint32_t>CKeycode.k_num_8
    num_9 = <uint32_t>CKeycode.k_num_9
    colon = <uint32_t>CKeycode.k_colon
    semicolon = <uint32_t>CKeycode.k_semicolon
    less = <uint32_t>CKeycode.k_less
    equals = <uint32_t>CKeycode.k_equals
    greater = <uint32_t>CKeycode.k_greater
    question = <uint32_t>CKeycode.k_question
    at = <uint32_t>CKeycode.k_at
    leftbracket = <uint32_t>CKeycode.k_leftbracket
    backslash = <uint32_t>CKeycode.k_backslash
    rightbracket = <uint32_t>CKeycode.k_rightbracket
    caret = <uint32_t>CKeycode.k_caret
    underscore = <uint32_t>CKeycode.k_underscore
    backquote = <uint32_t>CKeycode.k_backquote
    a = <uint32_t>CKeycode.k_a
    b = <uint32_t>CKeycode.k_b
    c = <uint32_t>CKeycode.k_c
    d = <uint32_t>CKeycode.k_d
    e = <uint32_t>CKeycode.k_e
    f = <uint32_t>CKeycode.k_f
    g = <uint32_t>CKeycode.k_g
    h = <uint32_t>CKeycode.k_h
    i = <uint32_t>CKeycode.k_i
    j = <uint32_t>CKeycode.k_j
    k = <uint32_t>CKeycode.k_k
    l = <uint32_t>CKeycode.k_l
    m = <uint32_t>CKeycode.k_m
    n = <uint32_t>CKeycode.k_n
    o = <uint32_t>CKeycode.k_o
    p = <uint32_t>CKeycode.k_p
    q = <uint32_t>CKeycode.k_q
    r = <uint32_t>CKeycode.k_r
    s = <uint32_t>CKeycode.k_s
    t = <uint32_t>CKeycode.k_t
    u = <uint32_t>CKeycode.k_u
    v = <uint32_t>CKeycode.k_v
    w = <uint32_t>CKeycode.k_w
    x = <uint32_t>CKeycode.k_x
    y = <uint32_t>CKeycode.k_y
    z = <uint32_t>CKeycode.k_z
    A = <uint32_t>CKeycode.k_A
    B = <uint32_t>CKeycode.k_B
    C = <uint32_t>CKeycode.k_C
    D = <uint32_t>CKeycode.k_D
    E = <uint32_t>CKeycode.k_E
    F = <uint32_t>CKeycode.k_F
    G = <uint32_t>CKeycode.k_G
    H = <uint32_t>CKeycode.k_H
    I = <uint32_t>CKeycode.k_I
    J = <uint32_t>CKeycode.k_J
    K = <uint32_t>CKeycode.k_K
    L = <uint32_t>CKeycode.k_L
    M = <uint32_t>CKeycode.k_M
    N = <uint32_t>CKeycode.k_N
    O = <uint32_t>CKeycode.k_O
    P = <uint32_t>CKeycode.k_P
    Q = <uint32_t>CKeycode.k_Q
    R = <uint32_t>CKeycode.k_R
    S = <uint32_t>CKeycode.k_S
    T = <uint32_t>CKeycode.k_T
    U = <uint32_t>CKeycode.k_U
    V = <uint32_t>CKeycode.k_V
    W = <uint32_t>CKeycode.k_W
    X = <uint32_t>CKeycode.k_X
    Y = <uint32_t>CKeycode.k_Y
    Z = <uint32_t>CKeycode.k_Z
    capslock = <uint32_t>CKeycode.k_capslock
    F1 = <uint32_t>CKeycode.k_F1
    F2 = <uint32_t>CKeycode.k_F2
    F3 = <uint32_t>CKeycode.k_F3
    F4 = <uint32_t>CKeycode.k_F4
    F5 = <uint32_t>CKeycode.k_F5
    F6 = <uint32_t>CKeycode.k_F6
    F7 = <uint32_t>CKeycode.k_F7
    F8 = <uint32_t>CKeycode.k_F8
    F9 = <uint32_t>CKeycode.k_F9
    F10 = <uint32_t>CKeycode.k_F10
    F11 = <uint32_t>CKeycode.k_F11
    F12 = <uint32_t>CKeycode.k_F12
    printscreen = <uint32_t>CKeycode.k_printscreen
    scrolllock = <uint32_t>CKeycode.k_scrolllock
    pause = <uint32_t>CKeycode.k_pause
    insert = <uint32_t>CKeycode.k_insert
    home = <uint32_t>CKeycode.k_home
    pageup = <uint32_t>CKeycode.k_pageup
    delete = <uint32_t>CKeycode.k_delete
    end = <uint32_t>CKeycode.k_end
    pagedown = <uint32_t>CKeycode.k_pagedown
    right = <uint32_t>CKeycode.k_right
    left = <uint32_t>CKeycode.k_left
    down = <uint32_t>CKeycode.k_down
    up = <uint32_t>CKeycode.k_up
    numlockclear = <uint32_t>CKeycode.k_numlockclear
    kp_divide = <uint32_t>CKeycode.k_kp_divide
    kp_multiply = <uint32_t>CKeycode.k_kp_multiply
    kp_minus = <uint32_t>CKeycode.k_kp_minus
    kp_plus = <uint32_t>CKeycode.k_kp_plus
    kp_enter = <uint32_t>CKeycode.k_kp_enter
    kp_1 = <uint32_t>CKeycode.k_kp_1
    kp_2 = <uint32_t>CKeycode.k_kp_2
    kp_3 = <uint32_t>CKeycode.k_kp_3
    kp_4 = <uint32_t>CKeycode.k_kp_4
    kp_5 = <uint32_t>CKeycode.k_kp_5
    kp_6 = <uint32_t>CKeycode.k_kp_6
    kp_7 = <uint32_t>CKeycode.k_kp_7
    kp_8 = <uint32_t>CKeycode.k_kp_8
    kp_9 = <uint32_t>CKeycode.k_kp_9
    kp_0 = <uint32_t>CKeycode.k_kp_0
    kp_period = <uint32_t>CKeycode.k_kp_period
    application = <uint32_t>CKeycode.k_application
    power = <uint32_t>CKeycode.k_power
    kp_equals = <uint32_t>CKeycode.k_kp_equals
    F13 = <uint32_t>CKeycode.k_F13
    F14 = <uint32_t>CKeycode.k_F14
    F15 = <uint32_t>CKeycode.k_F15
    F16 = <uint32_t>CKeycode.k_F16
    F17 = <uint32_t>CKeycode.k_F17
    F18 = <uint32_t>CKeycode.k_F18
    F19 = <uint32_t>CKeycode.k_F19
    F20 = <uint32_t>CKeycode.k_F20
    F21 = <uint32_t>CKeycode.k_F21
    F22 = <uint32_t>CKeycode.k_F22
    F23 = <uint32_t>CKeycode.k_F23
    F24 = <uint32_t>CKeycode.k_F24
    execute = <uint32_t>CKeycode.k_execute
    help = <uint32_t>CKeycode.k_help
    menu = <uint32_t>CKeycode.k_menu
    select = <uint32_t>CKeycode.k_select
    stop = <uint32_t>CKeycode.k_stop
    again = <uint32_t>CKeycode.k_again
    undo = <uint32_t>CKeycode.k_undo
    cut = <uint32_t>CKeycode.k_cut
    copy = <uint32_t>CKeycode.k_copy
    paste = <uint32_t>CKeycode.k_paste
    find = <uint32_t>CKeycode.k_find
    mute = <uint32_t>CKeycode.k_mute
    volumeup = <uint32_t>CKeycode.k_volumeup
    volumedown = <uint32_t>CKeycode.k_volumedown
    kp_comma = <uint32_t>CKeycode.k_kp_comma
    kp_equalsas400 = <uint32_t>CKeycode.k_kp_equalsas400
    alterase = <uint32_t>CKeycode.k_alterase
    sysreq = <uint32_t>CKeycode.k_sysreq
    cancel = <uint32_t>CKeycode.k_cancel
    clear = <uint32_t>CKeycode.k_clear
    prior = <uint32_t>CKeycode.k_prior
    return2 = <uint32_t>CKeycode.k_return2
    separator = <uint32_t>CKeycode.k_separator
    out = <uint32_t>CKeycode.k_out
    oper = <uint32_t>CKeycode.k_oper
    clearagain = <uint32_t>CKeycode.k_clearagain
    crsel = <uint32_t>CKeycode.k_crsel
    exsel = <uint32_t>CKeycode.k_exsel
    kp_00 = <uint32_t>CKeycode.k_kp_00
    kp_000 = <uint32_t>CKeycode.k_kp_000
    thousandsseparator = <uint32_t>CKeycode.k_thousandsseparator
    decimalseparator = <uint32_t>CKeycode.k_decimalseparator
    currencyunit = <uint32_t>CKeycode.k_currencyunit
    currencysubunit = <uint32_t>CKeycode.k_currencysubunit
    kp_leftparen = <uint32_t>CKeycode.k_kp_leftparen
    kp_rightparen = <uint32_t>CKeycode.k_kp_rightparen
    kp_leftbrace = <uint32_t>CKeycode.k_kp_leftbrace
    kp_rightbrace = <uint32_t>CKeycode.k_kp_rightbrace
    kp_tab = <uint32_t>CKeycode.k_kp_tab
    kp_backspace = <uint32_t>CKeycode.k_kp_backspace
    kp_a = <uint32_t>CKeycode.k_kp_a
    kp_b = <uint32_t>CKeycode.k_kp_b
    kp_c = <uint32_t>CKeycode.k_kp_c
    kp_d = <uint32_t>CKeycode.k_kp_d
    kp_e = <uint32_t>CKeycode.k_kp_e
    kp_f = <uint32_t>CKeycode.k_kp_f
    kp_xor = <uint32_t>CKeycode.k_kp_xor
    kp_power = <uint32_t>CKeycode.k_kp_power
    kp_percent = <uint32_t>CKeycode.k_kp_percent
    kp_less = <uint32_t>CKeycode.k_kp_less
    kp_greater = <uint32_t>CKeycode.k_kp_greater
    kp_ampersand = <uint32_t>CKeycode.k_kp_ampersand
    kp_dblampersand = <uint32_t>CKeycode.k_kp_dblampersand
    kp_verticalbar = <uint32_t>CKeycode.k_kp_verticalbar
    kp_dblverticalbar = <uint32_t>CKeycode.k_kp_dblverticalbar
    kp_colon = <uint32_t>CKeycode.k_kp_colon
    kp_hash = <uint32_t>CKeycode.k_kp_hash
    kp_space = <uint32_t>CKeycode.k_kp_space
    kp_at = <uint32_t>CKeycode.k_kp_at
    kp_exclam = <uint32_t>CKeycode.k_kp_exclam
    kp_memstore = <uint32_t>CKeycode.k_kp_memstore
    kp_memrecall = <uint32_t>CKeycode.k_kp_memrecall
    kp_memclear = <uint32_t>CKeycode.k_kp_memclear
    kp_memadd = <uint32_t>CKeycode.k_kp_memadd
    kp_memsubtract = <uint32_t>CKeycode.k_kp_memsubtract
    kp_memmultiply = <uint32_t>CKeycode.k_kp_memmultiply
    kp_memdivide = <uint32_t>CKeycode.k_kp_memdivide
    kp_plusminus = <uint32_t>CKeycode.k_kp_plusminus
    kp_clear = <uint32_t>CKeycode.k_kp_clear
    kp_clearentry = <uint32_t>CKeycode.k_kp_clearentry
    kp_binary = <uint32_t>CKeycode.k_kp_binary
    kp_octal = <uint32_t>CKeycode.k_kp_octal
    kp_decimal = <uint32_t>CKeycode.k_kp_decimal
    kp_hexadecimal = <uint32_t>CKeycode.k_kp_hexadecimal
    lctrl = <uint32_t>CKeycode.k_lctrl
    lshift = <uint32_t>CKeycode.k_lshift
    lalt = <uint32_t>CKeycode.k_lalt
    lgui = <uint32_t>CKeycode.k_lgui
    rctrl = <uint32_t>CKeycode.k_rctrl
    rshift = <uint32_t>CKeycode.k_rshift
    ralt = <uint32_t>CKeycode.k_ralt
    rgui = <uint32_t>CKeycode.k_rgui
    mode = <uint32_t>CKeycode.k_mode
    audionext = <uint32_t>CKeycode.k_audionext
    audioprev = <uint32_t>CKeycode.k_audioprev
    audiostop = <uint32_t>CKeycode.k_audiostop
    audioplay = <uint32_t>CKeycode.k_audioplay
    audiomute = <uint32_t>CKeycode.k_audiomute
    mediaselect = <uint32_t>CKeycode.k_mediaselect
    www = <uint32_t>CKeycode.k_www
    mail = <uint32_t>CKeycode.k_mail
    calculator = <uint32_t>CKeycode.k_calculator
    computer = <uint32_t>CKeycode.k_computer
    ac_search = <uint32_t>CKeycode.k_ac_search
    ac_home = <uint32_t>CKeycode.k_ac_home
    ac_back = <uint32_t>CKeycode.k_ac_back
    ac_forward = <uint32_t>CKeycode.k_ac_forward
    ac_stop = <uint32_t>CKeycode.k_ac_stop
    ac_refresh = <uint32_t>CKeycode.k_ac_refresh
    ac_bookmarks = <uint32_t>CKeycode.k_ac_bookmarks
    brightnessdown = <uint32_t>CKeycode.k_brightnessdown
    brightnessup = <uint32_t>CKeycode.k_brightnessup
    displayswitch = <uint32_t>CKeycode.k_displayswitch
    kbdillumtoggle = <uint32_t>CKeycode.k_kbdillumtoggle
    kbdillumdown = <uint32_t>CKeycode.k_kbdillumdown
    kbdillumup = <uint32_t>CKeycode.k_kbdillumup
    eject = <uint32_t>CKeycode.k_eject
    sleep = <uint32_t>CKeycode.k_sleep


class MouseButton(IntEnum):
    left = <uint32_t>CMouseButton.m_left
    middle = <uint32_t>CMouseButton.m_middle
    right = <uint32_t>CMouseButton.m_right
    x1 = <uint32_t>CMouseButton.m_x1
    x2 = <uint32_t>CMouseButton.m_x2


class ControllerButton(IntEnum):
    a = <uint32_t>CControllerButton.c_a
    b = <uint32_t>CControllerButton.c_b
    x = <uint32_t>CControllerButton.c_x
    y = <uint32_t>CControllerButton.c_y
    back = <uint32_t>CControllerButton.c_back
    guide = <uint32_t>CControllerButton.c_guide
    start = <uint32_t>CControllerButton.c_start
    left_stick = <uint32_t>CControllerButton.c_left_stick
    right_stick = <uint32_t>CControllerButton.c_right_stick
    left_shoulder = <uint32_t>CControllerButton.c_left_shoulder
    right_shoulder = <uint32_t>CControllerButton.c_right_shoulder
    dpad_up = <uint32_t>CControllerButton.c_dpad_up
    dpad_down = <uint32_t>CControllerButton.c_dpad_down
    dpad_left = <uint32_t>CControllerButton.c_dpad_left
    dpad_right = <uint32_t>CControllerButton.c_dpad_right


class ControllerAxis(IntEnum):
    left_y = <uint32_t>CControllerAxis.c_left_y
    left_x = <uint32_t>CControllerAxis.c_left_x
    right_x = <uint32_t>CControllerAxis.c_right_x
    right_y = <uint32_t>CControllerAxis.c_right_y
    trigger_left = <uint32_t>CControllerAxis.c_trigger_left
    trigger_right = <uint32_t>CControllerAxis.c_trigger_right


class EventType(IntEnum):
    quit = <uint32_t>CEventType.quit
    clipboard_updated = <uint32_t>CEventType.clipboard_updated

    window_shown = <uint32_t>CEventType.window_shown,
    window_hidden = <uint32_t>CEventType.window_hidden,
    window_exposed = <uint32_t>CEventType.window_exposed,
    window_moved = <uint32_t>CEventType.window_moved,
    window_resized = <uint32_t>CEventType.window_resized,
    window_minimized = <uint32_t>CEventType.window_minimized,
    window_maximized = <uint32_t>CEventType.window_maximized,
    window_restored = <uint32_t>CEventType.window_restored,
    window_enter = <uint32_t>CEventType.window_enter,
    window_leave = <uint32_t>CEventType.window_leave,
    window_focus_gained = <uint32_t>CEventType.window_focus_gained,
    window_focus_lost = <uint32_t>CEventType.window_focus_lost,
    window_close = <uint32_t>CEventType.window_close

    key_down = <uint32_t>CEventType.key_down
    key_up = <uint32_t>CEventType.key_up
    text_input = <uint32_t>CEventType.text_input

    mouse_motion = <uint32_t>CEventType.mouse_motion
    mouse_button_up = <uint32_t>CEventType.mouse_button_up
    mouse_button_down = <uint32_t>CEventType.mouse_button_down
    mouse_wheel = <uint32_t>CEventType.mouse_wheel

    controller_axis_motion = <uint32_t>CEventType.controller_axis_motion
    controller_button_down = <uint32_t>CEventType.controller_button_down
    controller_button_up = <uint32_t>CEventType.controller_button_up
    controller_added = <uint32_t>CEventType.controller_added
    controller_removed = <uint32_t>CEventType.controller_removed
    controller_remapped = <uint32_t>CEventType.controller_remapped

    music_finished = <uint32_t>CEventType.music_finished
    channel_finished = <uint32_t>CEventType.channel_finished


class CompoundControllerAxis(IntEnum):
    left_stick = <uint32_t>CCompoundControllerAxis.left_stick
    right_stick = <uint32_t>CCompoundControllerAxis.right_stick


cdef class _TypedReadOnlyProperty:
    cdef:
        object type_
        object getter

    def __init__(self, type_, getter):
        self.type_ = type_
        self.getter = getter

    def __get__(self, obj, klass):
        if obj is None:
            return self.type_
        return self.getter(obj)


cdef typed_property(object type_):
    def decorator(fun):
        return _TypedReadOnlyProperty(type_, fun)
    return decorator


@cython.freelist(EVENT_FREELIST_SIZE)
cdef class _BaseEvent:
    cdef CEvent c_event

    def __repr__(self):
        return f'<{self.__class__.__name__}@{self.type.name}>'

    @property
    def type(self):
        return EventType(<uint32_t>self.c_event.type())

    @property
    def timestamp(self):
        return self.c_event.timestamp()


@cython.final
cdef class SystemEvent(_BaseEvent):
    @staticmethod
    cdef SystemEvent create(CEvent c_event):
        cdef SystemEvent instance = SystemEvent.__new__(
            SystemEvent
        )
        instance.c_event = c_event
        return instance

    @typed_property(EventType.quit)
    def quit(self):
        return self.c_event.system().is_quit()
    
    @typed_property(EventType.clipboard_updated)
    def clipboard_updated(self):
        return self.c_event.system().is_clipboard_updated()


@cython.final
cdef class WindowEvent(_BaseEvent):
    @staticmethod
    cdef WindowEvent create(CEvent c_event):
        cdef WindowEvent instance = WindowEvent.__new__(
            WindowEvent
        )
        instance.c_event = c_event
        return instance

    @typed_property(EventType.window_shown)
    def is_shown(self):
        return self.c_event.window().is_shown()
    
    @typed_property(EventType.window_exposed)
    def is_exposed(self):
        return self.c_event.window().is_exposed()
    
    @typed_property(EventType.window_moved)
    def is_moved(self):
        return self.c_event.window().is_moved()
    
    @typed_property(EventType.window_resized)
    def is_resized(self):
        return self.c_event.window().is_resized()

    @typed_property(EventType.window_minimized)
    def is_minimized(self):
        return self.c_event.window().is_minimized()

    @typed_property(EventType.window_maximized)
    def is_maximized(self):
        return self.c_event.window().is_maximized()

    @typed_property(EventType.window_restored)
    def is_restored(self):
        return self.c_event.window().is_restored()
    
    @typed_property(EventType.window_enter)
    def is_enter(self):
        return self.c_event.window().is_enter()

    @typed_property(EventType.window_leave)
    def is_leave(self):
        return self.c_event.window().is_leave()

    @typed_property(EventType.window_focus_gained)
    def is_focus_gained(self):
        return self.c_event.window().is_focus_gained()

    @typed_property(EventType.window_focus_lost)
    def is_focus_lost(self):
        return self.c_event.window().is_focus_lost()

    @typed_property(EventType.window_close)
    def is_close(self):
        return self.c_event.window().is_close()


@cython.final
cdef class KeyboardKeyEvent(_BaseEvent):
    @staticmethod
    cdef KeyboardKeyEvent create(CEvent c_event):
        cdef KeyboardKeyEvent instance = KeyboardKeyEvent.__new__(
            KeyboardKeyEvent
        )
        instance.c_event = c_event
        return instance

    @property
    def key(self):
        return Keycode(<uint32_t>(self.c_event.keyboard_key().key()))
    
    @property
    def repeat(self):
        return self.c_event.keyboard_key().repeat()

    @typed_property(EventType.key_up)
    def is_key_up(self):
        return self.c_event.keyboard_key().is_key_up()

    @typed_property(EventType.key_down)
    def is_key_down(self):
        return self.c_event.keyboard_key().is_key_down()

    @property
    def key_down(self):
        if self.is_key_down:
            return self.key


@cython.final
cdef class KeyboardTextEvent(_BaseEvent):
    @staticmethod
    cdef KeyboardTextEvent create(CEvent c_event):
        cdef KeyboardTextEvent instance = KeyboardTextEvent.__new__(
            KeyboardTextEvent
        )
        instance.c_event = c_event
        return instance

    @property
    def text(self):
        return self.c_event.keyboard_text().text().decode('utf-8')


@cython.final
cdef class MouseButtonEvent(_BaseEvent):
    @staticmethod
    cdef MouseButtonEvent create(CEvent c_event):
        cdef MouseButtonEvent instance = MouseButtonEvent.__new__(
            MouseButtonEvent
        )
        instance.c_event = c_event
        return instance
    
    @typed_property((
        EventType.mouse_button_down, EventType.mouse_button_up
    ))
    def button(self):
        return MouseButton(<uint32_t>(self.c_event.mouse_button().button()))

    @property
    def position(self):
        return Vector.from_c_vector(self.c_event.mouse_button().position())

    @typed_property(EventType.mouse_button_down)
    def is_button_down(self):
        return self.c_event.mouse_button().is_button_down()

    @typed_property(EventType.mouse_button_up)
    def is_button_up(self):
        return self.c_event.mouse_button().is_button_up()


@cython.final
cdef class MouseMotionEvent(_BaseEvent):
    @staticmethod
    cdef MouseMotionEvent create(CEvent c_event):
        cdef MouseMotionEvent instance = MouseMotionEvent.__new__(
            MouseMotionEvent
        )
        instance.c_event = c_event
        return instance

    @property
    def position(self):
        return Vector.from_c_vector(
            self.c_event.mouse_motion().position()
        )


@cython.final
cdef class MouseWheelEvent(_BaseEvent):
    @staticmethod
    cdef MouseWheelEvent create(CEvent c_event):
        cdef MouseWheelEvent instance = MouseWheelEvent.__new__(
            MouseWheelEvent
        )
        instance.c_event = c_event
        return instance

    @property
    def scroll(self):
        return Vector.from_c_vector(
            self.c_event.mouse_wheel().scroll()
        )


@cython.final
cdef class ControllerButtonEvent(_BaseEvent):
    @staticmethod
    cdef ControllerButtonEvent create(CEvent c_event):
        cdef ControllerButtonEvent instance = ControllerButtonEvent.__new__(
            ControllerButtonEvent
        )
        instance.c_event = c_event
        return instance

    @property
    def id(self):
        return self.c_event.controller_button().id()

    @typed_property((
        EventType.controller_button_down, EventType.controller_button_up
    ))
    def button(self):
        return ControllerButton(
            <uint32_t>(self.c_event.controller_button().button())
        )
    
    @typed_property(EventType.controller_button_down)
    def is_button_down(self):
        return self.c_event.controller_button().is_button_down()

    @typed_property(EventType.controller_button_up)
    def is_button_up(self):
        return self.c_event.controller_button().is_button_up()


@cython.final
cdef class ControllerAxisEvent(_BaseEvent):
    @staticmethod
    cdef ControllerAxisEvent create(CEvent c_event):
        cdef ControllerAxisEvent instance = ControllerAxisEvent.__new__(
            ControllerAxisEvent
        )
        instance.c_event = c_event
        return instance

    @property
    def id(self):
        return self.c_event.controller_axis().id()

    @property
    def axis(self):
        return ControllerAxis(
            <uint32_t>(self.c_event.controller_axis().axis())
        )

    @property
    def motion(self):
        return self.c_event.controller_axis().motion()


@cython.final
cdef class ControllerDeviceEvent(_BaseEvent):
    @staticmethod
    cdef ControllerDeviceEvent create(CEvent c_event):
        cdef ControllerDeviceEvent instance = ControllerDeviceEvent.__new__(
            ControllerDeviceEvent
        )
        instance.c_event = c_event
        return instance

    @property
    def id(self):
        return self.c_event.controller_device().id()

    @typed_property(EventType.controller_added)
    def is_added(self):
        return self.c_event.controller_device().is_added()

    @typed_property(EventType.controller_removed)
    def is_removed(self):
        return self.c_event.controller_device().is_removed()


@cython.final
cdef class MusicFinishedEvent(_BaseEvent):
    @staticmethod
    cdef MusicFinishedEvent create(CEvent c_event):
        cdef MusicFinishedEvent instance = MusicFinishedEvent.__new__(MusicFinishedEvent)
        instance.c_event = c_event
        return instance


@cython.final
cdef class Event(_BaseEvent):
    @staticmethod
    cdef Event create(CEvent c_event):
        cdef Event instance = Event.__new__(Event)
        instance.c_event = c_event
        return instance
    
    @typed_property((
        EventType.quit,
        EventType.clipboard_updated
    ))
    def system(self):
        if self.c_event.system():
            return SystemEvent.create(self.c_event)
    
    @typed_property((
        EventType.window_shown,
        EventType.window_hidden,
        EventType.window_exposed,
        EventType.window_moved,
        EventType.window_resized,
        EventType.window_minimized,
        EventType.window_maximized,
        EventType.window_restored,
        EventType.window_enter,
        EventType.window_leave,
        EventType.window_focus_gained,
        EventType.window_focus_lost,
        EventType.window_close
    ))
    def window(self):
        if self.c_event.window():
            return WindowEvent.create(self.c_event)

    @typed_property((
        EventType.key_down,
        EventType.key_up
    ))
    def keyboard_key(self):
        if self.c_event.keyboard_key():
            return KeyboardKeyEvent.create(self.c_event)

    @typed_property(EventType.text_input)
    def keyboard_text(self):
        if self.c_event.keyboard_text():
            return KeyboardTextEvent.create(self.c_event)

    @typed_property((
        EventType.mouse_button_down,
        EventType.mouse_button_up
    ))
    def mouse_button(self):
        if self.c_event.mouse_button():
            return MouseButtonEvent.create(self.c_event)

    @typed_property(EventType.mouse_motion)
    def mouse_motion(self):
        if self.c_event.mouse_motion():
            return MouseMotionEvent.create(self.c_event)

    @typed_property(EventType.mouse_wheel)
    def mouse_wheel(self):
        if self.c_event.mouse_wheel():
            return MouseWheelEvent.create(self.c_event)

    @typed_property((
        EventType.controller_button_down,
        EventType.controller_button_up
    ))
    def controller_button(self):
        if self.c_event.controller_button():
            return ControllerButtonEvent.create(self.c_event)

    @typed_property(EventType.controller_axis_motion)
    def controller_axis(self):
        if self.c_event.controller_axis():
            return ControllerAxisEvent.create(self.c_event)

    @typed_property((
        EventType.controller_added,
        EventType.controller_removed
    ))
    def controller_device(self):
        if self.c_event.controller_device():
            return ControllerDeviceEvent.create(self.c_event)

    @typed_property(EventType.music_finished)
    def music_finished(self):
        if self.c_event.music_finished():
            return MusicFinishedEvent.create(self.c_event)
    

cdef class _BaseInputManager:
    cdef CInputManager* _get_c_input_manager(self) except NULL:
        return get_c_engine().input_manager.get()


@cython.final
cdef class SystemManager(_BaseInputManager):
    def get_clipboard_text(self):
        self._get_c_input_manager().system.get_clipboard_text().c_str()
    
    def set_clipboard_text(self, str text not None):
        self._get_c_input_manager().system.set_clipboard_text(text)


@cython.final
cdef class KeyboardManager(_BaseInputManager):
    def is_pressed(self, kc not None):
        return self._get_c_input_manager().keyboard.is_pressed(
            <CKeycode>(<uint32_t>(kc.value))
        )
    
    def is_released(self, kc not None):
        return self._get_c_input_manager().keyboard.is_released(
            <CKeycode>(<uint32_t>(kc.value))
        )


@cython.final
cdef class MouseManager(_BaseInputManager):
    def is_pressed(self, mc not None):
        return self._get_c_input_manager().mouse.is_pressed(
            <CMouseButton>(<uint32_t>(mc.value))
        )
    
    def is_released(self, mc not None):
        return self._get_c_input_manager().mouse.is_released(
            <CMouseButton>(<uint32_t>(mc.value))
        )
    
    def get_position(self):
        return Vector.from_c_vector(
            self._get_c_input_manager().mouse.get_position()
        )


@cython.final
cdef class ControllerManager(_BaseInputManager):
    def is_connected(self, CControllerID controller_id):
        return self._get_c_input_manager().controller.is_connected(
            controller_id
        )
    
    def is_pressed(self, cb not None, CControllerID controller_id):
        return self._get_c_input_manager().controller.is_pressed(
            <CControllerButton>(<uint32_t>(cb.value)), controller_id
        )
    
    def is_released(self, cb not None, CControllerID controller_id):
        return self._get_c_input_manager().controller.is_released(
            <CControllerButton>(<uint32_t>(cb.value)), controller_id
        )
    
    def is_axis_pressed(self, axis not None, CControllerID controller_id):
        return self._get_c_input_manager().controller.is_pressed(
            <CControllerAxis>(<uint32_t>(axis.value)), controller_id
        )

    def is_axis_released(self, axis not None, CControllerID controller_id):
        return self._get_c_input_manager().controller.is_released(
            <CControllerAxis>(<uint32_t>(axis.value)), controller_id
        )
    
    def get_axis_motion(self, axis not None, CControllerID controller_id):
        return self._get_c_input_manager().controller.get_axis_motion(
            <CControllerAxis>(<uint32_t>(axis.value)), controller_id
        )
    
    def get_name(self, CControllerID controller_id):
        return self._get_c_input_manager().controller.get_name(controller_id).c_str()
    
    def get_triggers(self, CControllerID controller_id):
        return Vector.from_c_vector(
            self._get_c_input_manager().controller.get_triggers(controller_id)
        )
    
    def get_sticks(self, compound_axis not None, CControllerID controller_id):
        return Vector.from_c_vector(
            self._get_c_input_manager().controller.get_sticks(
                <CCompoundControllerAxis>(<uint32_t>(compound_axis.value)),
                controller_id
            )
        )


cdef int32_t c_event_handler(
    CPythonException& c_python_exception,
    const CPythonicCallbackWrapper& c_wrapper,
    const CEvent& c_event
) with gil:

    cdef:
        Event event = Event.create(c_event)
        object callback = <object>c_wrapper.py_callback
    try:
        return 1 if callback(event) is True else 0
    except Exception as py_exc:
        c_python_exception.setup(<PyObject*>py_exc)
        return 0


@cython.final
cdef class InputManager(_BaseInputManager):
    cdef:
        readonly SystemManager system
        readonly KeyboardManager keyboard
        readonly MouseManager mouse
        readonly ControllerManager controller

    def __cinit__(self):
        self.system = SystemManager()
        self.keyboard = KeyboardManager()
        self.mouse = MouseManager()
        self.controller = ControllerManager()
    
    def events(self):
        cdef CEvent c_event
        for c_event in self._get_c_input_manager().events_queue:
            yield Event.create(c_event)

    def register_callback(self, object event_type not None, object callback):
        if isinstance(event_type, Iterable):
            return self._register_callback_from_iter(
                event_type, callback
            )
        elif isinstance(event_type, EventType):
            return self._register_callback_from_obj(
                event_type, callback
            )
        raise TypeError(f'Unsupported argument: {event_type}.')

    def _register_callback_from_iter(self, object iterable not None, object callback):
        for element in iterable:
            self.register_callback(element, callback)

    def _register_callback_from_obj(self, object event_type not None, object callback):
        assert isinstance(event_type, EventType)

        cdef CEventType c_event_type = <CEventType>(<uint32_t>(event_type.value))

        if callback is None:
            return self._get_c_input_manager().register_callback(
                c_event_type, <CEventCallback>nullptr
            )

        cdef CEventCallback bound_callback = bind_cython_event_callback(
            c_event_handler,
            CPythonicCallbackWrapper(<PyObject*>callback)
        )
        self._get_c_input_manager().register_callback(
            c_event_type, cmove(bound_callback)
        )
