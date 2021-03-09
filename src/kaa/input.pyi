import enum
from typing import Callable, Iterable, Optional, overload, type_check_only

from .geometry import Vector


class ControllerAxis(enum.IntEnum):
    left_x: ControllerAxis
    left_y: ControllerAxis
    right_x: ControllerAxis
    right_y: ControllerAxis
    trigger_left: ControllerAxis
    trigger_right: ControllerAxis


class CompoundControllerAxis(enum.IntEnum):
    left_stick: CompoundControllerAxis
    right_stick: CompoundControllerAxis


class ControllerButton(enum.IntEnum):
    a: ControllerButton
    b: ControllerButton
    back: ControllerButton
    dpad_down: ControllerButton
    dpad_left: ControllerButton
    dpad_right: ControllerButton
    dpad_up: ControllerButton
    guide: ControllerButton
    left_shoulder: ControllerButton
    left_stick: ControllerButton
    right_shoulder: ControllerButton
    right_stick: ControllerButton
    start: ControllerButton
    x: ControllerButton
    y: ControllerButton


class Keycode(enum.IntEnum):
    A: Keycode
    B: Keycode
    C: Keycode
    D: Keycode
    E: Keycode
    F: Keycode
    F1: Keycode
    F10: Keycode
    F11: Keycode
    F12: Keycode
    F13: Keycode
    F14: Keycode
    F15: Keycode
    F16: Keycode
    F17: Keycode
    F18: Keycode
    F19: Keycode
    F2: Keycode
    F20: Keycode
    F21: Keycode
    F22: Keycode
    F23: Keycode
    F24: Keycode
    F3: Keycode
    F4: Keycode
    F5: Keycode
    F6: Keycode
    F7: Keycode
    F8: Keycode
    F9: Keycode
    G: Keycode
    H: Keycode
    I: Keycode
    J: Keycode
    K: Keycode
    L: Keycode
    M: Keycode
    N: Keycode
    O: Keycode
    P: Keycode
    Q: Keycode
    R: Keycode
    S: Keycode
    T: Keycode
    U: Keycode
    V: Keycode
    W: Keycode
    X: Keycode
    Y: Keycode
    Z: Keycode
    a: Keycode
    ac_back: Keycode
    ac_bookmarks: Keycode
    ac_forward: Keycode
    ac_home: Keycode
    ac_refresh: Keycode
    ac_search: Keycode
    ac_stop: Keycode
    again: Keycode
    alterase: Keycode
    ampersand: Keycode
    application: Keycode
    asterisk: Keycode
    at: Keycode
    audiomute: Keycode
    audionext: Keycode
    audioplay: Keycode
    audioprev: Keycode
    audiostop: Keycode
    b: Keycode
    backquote: Keycode
    backslash: Keycode
    backspace: Keycode
    brightnessdown: Keycode
    brightnessup: Keycode
    c: Keycode
    calculator: Keycode
    cancel: Keycode
    capslock: Keycode
    caret: Keycode
    clear: Keycode
    clearagain: Keycode
    colon: Keycode
    comma: Keycode
    computer: Keycode
    copy: Keycode
    crsel: Keycode
    currencysubunit: Keycode
    currencyunit: Keycode
    cut: Keycode
    d: Keycode
    decimalseparator: Keycode
    delete: Keycode
    displayswitch: Keycode
    dollar: Keycode
    down: Keycode
    e: Keycode
    eject: Keycode
    end: Keycode
    equals: Keycode
    escape: Keycode
    exclaim: Keycode
    execute: Keycode
    exsel: Keycode
    f: Keycode
    find: Keycode
    g: Keycode
    greater: Keycode
    h: Keycode
    hash: Keycode
    help: Keycode
    home: Keycode
    i: Keycode
    insert: Keycode
    j: Keycode
    k: Keycode
    kbdillumdown: Keycode
    kbdillumtoggle: Keycode
    kbdillumup: Keycode
    kp_0: Keycode
    kp_00: Keycode
    kp_000: Keycode
    kp_1: Keycode
    kp_2: Keycode
    kp_3: Keycode
    kp_4: Keycode
    kp_5: Keycode
    kp_6: Keycode
    kp_7: Keycode
    kp_8: Keycode
    kp_9: Keycode
    kp_a: Keycode
    kp_ampersand: Keycode
    kp_at: Keycode
    kp_b: Keycode
    kp_backspace: Keycode
    kp_binary: Keycode
    kp_c: Keycode
    kp_clear: Keycode
    kp_clearentry: Keycode
    kp_colon: Keycode
    kp_comma: Keycode
    kp_d: Keycode
    kp_dblampersand: Keycode
    kp_dblverticalbar: Keycode
    kp_decimal: Keycode
    kp_divide: Keycode
    kp_e: Keycode
    kp_enter: Keycode
    kp_equals: Keycode
    kp_equalsas400: Keycode
    kp_exclam: Keycode
    kp_f: Keycode
    kp_greater: Keycode
    kp_hash: Keycode
    kp_hexadecimal: Keycode
    kp_leftbrace: Keycode
    kp_leftparen: Keycode
    kp_less: Keycode
    kp_memadd: Keycode
    kp_memclear: Keycode
    kp_memdivide: Keycode
    kp_memmultiply: Keycode
    kp_memrecall: Keycode
    kp_memstore: Keycode
    kp_memsubtract: Keycode
    kp_minus: Keycode
    kp_multiply: Keycode
    kp_octal: Keycode
    kp_percent: Keycode
    kp_period: Keycode
    kp_plus: Keycode
    kp_plusminus: Keycode
    kp_power: Keycode
    kp_rightbrace: Keycode
    kp_rightparen: Keycode
    kp_space: Keycode
    kp_tab: Keycode
    kp_verticalbar: Keycode
    kp_xor: Keycode
    l: Keycode
    lalt: Keycode
    lctrl: Keycode
    left: Keycode
    leftbracket: Keycode
    leftparen: Keycode
    less: Keycode
    lgui: Keycode
    lshift: Keycode
    m: Keycode
    mail: Keycode
    mediaselect: Keycode
    menu: Keycode
    minus: Keycode
    mode: Keycode
    mute: Keycode
    n: Keycode
    num_0: Keycode
    num_1: Keycode
    num_2: Keycode
    num_3: Keycode
    num_4: Keycode
    num_5: Keycode
    num_6: Keycode
    num_7: Keycode
    num_8: Keycode
    num_9: Keycode
    numlockclear: Keycode
    o: Keycode
    oper: Keycode
    out: Keycode
    p: Keycode
    pagedown: Keycode
    pageup: Keycode
    paste: Keycode
    pause: Keycode
    percent: Keycode
    period: Keycode
    plus: Keycode
    power: Keycode
    printscreen: Keycode
    prior: Keycode
    q: Keycode
    question: Keycode
    quote: Keycode
    quotedbl: Keycode
    r: Keycode
    ralt: Keycode
    rctrl: Keycode
    return2: Keycode
    return_: Keycode
    rgui: Keycode
    right: Keycode
    rightbracket: Keycode
    rightparen: Keycode
    rshift: Keycode
    s: Keycode
    scrolllock: Keycode
    select: Keycode
    semicolon: Keycode
    separator: Keycode
    slash: Keycode
    sleep: Keycode
    space: Keycode
    stop: Keycode
    sysreq: Keycode
    t: Keycode
    tab: Keycode
    thousandsseparator: Keycode
    u: Keycode
    underscore: Keycode
    undo: Keycode
    unknown: Keycode
    up: Keycode
    v: Keycode
    volumedown: Keycode
    volumeup: Keycode
    w: Keycode
    www: Keycode
    x: Keycode
    y: Keycode
    z: Keycode


class MouseButton(enum.IntEnum):
    left: MouseButton
    middle: MouseButton
    right: MouseButton
    x1: MouseButton
    x2: MouseButton


class EventType(enum.IntEnum):
    channel_finished: EventType
    clipboard_updated: EventType
    controller_added: EventType
    controller_axis_motion: EventType
    controller_button_down: EventType
    controller_button_up: EventType
    controller_remapped: EventType
    controller_removed: EventType
    key_down: EventType
    key_up: EventType
    mouse_button_down: EventType
    mouse_button_up: EventType
    mouse_motion: EventType
    mouse_wheel: EventType
    music_finished: EventType
    quit: EventType
    text_input: EventType
    window_close: EventType
    window_enter: EventType
    window_exposed: EventType
    window_focus_gained: EventType
    window_focus_lost: EventType
    window_hidden: EventType
    window_leave: EventType
    window_maximized: EventType
    window_minimized: EventType
    window_moved: EventType
    window_resized: EventType
    window_restored: EventType
    window_shown: EventType


@type_check_only
class _BaseEvent:
    @property
    def timestamp(self) -> int:
        ...


class ControllerAxisEvent(_BaseEvent):
    @property
    def axis(self) -> ControllerAxis:
        ...

    @property
    def id(self) -> int:
        ...

    @property
    def motion(self) -> float:
        ...


class ControllerButtonEvent(_BaseEvent):
    @property
    def id(self) -> int:
        ...

    @property
    def button(self) -> ControllerButton:
        ...

    @property
    def is_button_down(self) -> bool:
        ...

    @property
    def is_button_up(self) -> bool:
        ...


class ControllerDeviceEvent(_BaseEvent):
    @property
    def id(self) -> int:
        ...

    @property
    def is_added(self) -> bool:
        ...

    @property
    def is_removed(self) -> bool:
        ...


class KeyboardKeyEvent(_BaseEvent):
    @property
    def key(self) -> Keycode:
        ...

    @property
    def key_down(self) -> Optional[Keycode]:
        ...

    @property
    def repeat(self) -> bool:
        ...

    @property
    def is_key_down(self) -> bool:
        ...

    @property
    def is_key_up(self) -> bool:
        ...


class KeyboardTextEvent(_BaseEvent):
    @property
    def text(self) -> str:
        ...


class MouseButtonEvent(_BaseEvent):
    @property
    def position(self) -> Vector:
        ...

    @property
    def button(self) -> MouseButton: ...

    @property
    def is_button_down(self) -> bool: ...

    @property
    def is_button_up(self) -> bool:
        ...


class MouseMotionEvent(_BaseEvent):
    @property
    def motion(self) -> Vector:
        ...

    @property
    def position(self) -> Vector:
        ...


class MouseWheelEvent(_BaseEvent):
    @property
    def scroll(self) -> Vector:
        ...


class MusicFinishedEvent(_BaseEvent):
    ...


class SystemEvent(_BaseEvent):
    @property
    def clipboard_updated(self) -> bool:
        ...

    @property
    def quit(self) -> bool:
        ...


class WindowEvent(_BaseEvent):
    @property
    def is_close(self) -> bool:
        ...

    @property
    def is_enter(self) -> bool:
        ...

    @property
    def is_exposed(self) -> bool:
        ...

    @property
    def is_focus_gained(self) -> bool:
        ...

    @property
    def is_focus_lost(self) -> bool:
        ...

    @property
    def is_leave(self) -> bool:
        ...

    @property
    def is_maximized(self) -> bool:
        ...

    @property
    def is_minimized(self) -> bool:
        ...

    @property
    def is_moved(self) -> bool:
        ...

    @property
    def is_resized(self) -> bool:
        ...

    @property
    def is_restored(self) -> bool:
        ...

    @property
    def is_shown(self) -> bool:
        ...


class Event(_BaseEvent):
    @property
    def controller_axis(self) -> Optional[ControllerAxisEvent]:
        ...

    @property
    def controller_button(self) -> Optional[ControllerButtonEvent]:
        ...

    @property
    def controller_device(self) -> Optional[ControllerDeviceEvent]:
        ...

    @property
    def keyboard_key(self) -> Optional[KeyboardKeyEvent]:
        ...

    @property
    def keyboard_text(self) -> Optional[KeyboardTextEvent]:
        ...

    @property
    def mouse_button(self) -> Optional[MouseButtonEvent]:
        ...

    @property
    def mouse_motion(self) -> Optional[MouseMotionEvent]:
        ...

    @property
    def mouse_wheel(self) -> Optional[MouseWheelEvent]:
        ...

    @property
    def music_finished(self) -> Optional[MusicFinishedEvent]:
        ...

    @property
    def system(self) -> Optional[SystemEvent]:
        ...

    @property
    def window(self) -> Optional[WindowEvent]:
        ...


@type_check_only
class SystemManager:
    def get_clipboard_text(self) -> str:
        ...

    def set_clipboard_text(self, text: str) -> None:
        ...


@type_check_only
class KeyboardManager:
    def is_pressed(self, kc: Keycode) -> bool:
        ...

    def is_released(self, kc: Keycode) -> bool:
        ...


@type_check_only
class MouseManager:
    @property
    def cursor_visible(self) -> bool:
        ...

    @cursor_visible.setter
    def cursor_visible(self, visible: bool) -> None:
        ...

    @property
    def relative_mode(self) -> bool:
        ...

    @relative_mode.setter
    def relative_mode(self, rel: bool) -> None:
        ...

    def get_position(self) -> Vector: ...
    def is_pressed(self, mc: MouseButton) -> bool: ...
    def is_released(self, mc: MouseButton) -> bool: ...


@type_check_only
class ControllerManager:
    def get_axis_motion(self, axis: ControllerAxis, controller_id: int) -> float:
        ...

    def get_name(self, controller_id: int) -> str:
        ...

    def get_sticks(self, compound_axis: CompoundControllerAxis, controller_id: int) -> Vector:
        ...

    def get_triggers(self, controller_id: int) -> Vector:
        ...

    def is_axis_pressed(self, axis: ControllerAxis, controller_id: int) -> bool:
        ...

    def is_axis_released(self, axis: ControllerAxis, controller_id: int) -> bool:
        ...

    def is_connected(self, controller_id: int) -> bool:
        ...

    def is_pressed(self, cb: ControllerButton, controller_id: int) -> bool:
        ...

    def is_released(self, cb: ControllerButton, controller_id: int) -> bool:
        ...


@type_check_only
class InputManager:
    @property
    def controller(self) -> ControllerManager:
        ...

    @property
    def keyboard(self) -> KeyboardManager:
        ...

    @property
    def mouse(self) -> MouseManager:
        ...

    @property
    def system(self) -> SystemManager:
        ...

    def events(self) -> Iterable[Event]:
        ...

    @overload
    def register_callback(
        self, event_type: EventType, callback: Optional[Callable[[Event], bool]],
    ) -> None:
        ...

    @overload
    def register_callback(
        self, event_type: Iterable[EventType],
        callback: Optional[Callable[[Event], bool]],
    ) -> None:
        ...
