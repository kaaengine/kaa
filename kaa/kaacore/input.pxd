from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.functional cimport function
from libc.stdint cimport int32_t, uint32_t

from .vectors cimport CVector
from .exceptions cimport raise_py_error
from .glue cimport CPythonicCallbackWrapper


cdef extern from "kaacore/input.h" nogil:
    ctypedef int32_t CControllerID "kaacore::ControllerID"

    cdef enum CKeycode "kaacore::Keycode":
        k_unknown "kaacore::Keycode::unknown",
        k_return "kaacore::Keycode::return_",
        k_escape "kaacore::Keycode::escape",
        k_backspace "kaacore::Keycode::backspace",
        k_tab "kaacore::Keycode::tab",
        k_space "kaacore::Keycode::space",
        k_exclaim "kaacore::Keycode::exclaim",
        k_quotedbl "kaacore::Keycode::quotedbl",
        k_hash "kaacore::Keycode::hash",
        k_percent "kaacore::Keycode::percent",
        k_dollar "kaacore::Keycode::dollar",
        k_ampersand "kaacore::Keycode::ampersand",
        k_quote "kaacore::Keycode::quote",
        k_leftparen "kaacore::Keycode::leftparen",
        k_rightparen "kaacore::Keycode::rightparen",
        k_asterisk "kaacore::Keycode::asterisk",
        k_plus "kaacore::Keycode::plus",
        k_comma "kaacore::Keycode::comma",
        k_minus "kaacore::Keycode::minus",
        k_period "kaacore::Keycode::period",
        k_slash "kaacore::Keycode::slash",
        k_num_0 "kaacore::Keycode::num_0",
        k_num_1 "kaacore::Keycode::num_1",
        k_num_2 "kaacore::Keycode::num_2",
        k_num_3 "kaacore::Keycode::num_3",
        k_num_4 "kaacore::Keycode::num_4",
        k_num_5 "kaacore::Keycode::num_5",
        k_num_6 "kaacore::Keycode::num_6",
        k_num_7 "kaacore::Keycode::num_7",
        k_num_8 "kaacore::Keycode::num_8",
        k_num_9 "kaacore::Keycode::num_9",
        k_colon "kaacore::Keycode::colon",
        k_semicolon "kaacore::Keycode::semicolon",
        k_less "kaacore::Keycode::less",
        k_equals "kaacore::Keycode::equals",
        k_greater "kaacore::Keycode::greater",
        k_question "kaacore::Keycode::question",
        k_at "kaacore::Keycode::at",
        k_leftbracket "kaacore::Keycode::leftbracket",
        k_backslash "kaacore::Keycode::backslash",
        k_rightbracket "kaacore::Keycode::rightbracket",
        k_caret "kaacore::Keycode::caret",
        k_underscore "kaacore::Keycode::underscore",
        k_backquote "kaacore::Keycode::backquote",
        k_a "kaacore::Keycode::a",
        k_b "kaacore::Keycode::b",
        k_c "kaacore::Keycode::c",
        k_d "kaacore::Keycode::d",
        k_e "kaacore::Keycode::e",
        k_f "kaacore::Keycode::f",
        k_g "kaacore::Keycode::g",
        k_h "kaacore::Keycode::h",
        k_i "kaacore::Keycode::i",
        k_j "kaacore::Keycode::j",
        k_k "kaacore::Keycode::k",
        k_l "kaacore::Keycode::l",
        k_m "kaacore::Keycode::m",
        k_n "kaacore::Keycode::n",
        k_o "kaacore::Keycode::o",
        k_p "kaacore::Keycode::p",
        k_q "kaacore::Keycode::q",
        k_r "kaacore::Keycode::r",
        k_s "kaacore::Keycode::s",
        k_t "kaacore::Keycode::t",
        k_u "kaacore::Keycode::u",
        k_v "kaacore::Keycode::v",
        k_w "kaacore::Keycode::w",
        k_x "kaacore::Keycode::x",
        k_y "kaacore::Keycode::y",
        k_z "kaacore::Keycode::z",
        k_A "kaacore::Keycode::A",
        k_B "kaacore::Keycode::B",
        k_C "kaacore::Keycode::C",
        k_D "kaacore::Keycode::D",
        k_E "kaacore::Keycode::E",
        k_F "kaacore::Keycode::F",
        k_G "kaacore::Keycode::G",
        k_H "kaacore::Keycode::H",
        k_I "kaacore::Keycode::I",
        k_J "kaacore::Keycode::J",
        k_K "kaacore::Keycode::K",
        k_L "kaacore::Keycode::L",
        k_M "kaacore::Keycode::M",
        k_N "kaacore::Keycode::N",
        k_O "kaacore::Keycode::O",
        k_P "kaacore::Keycode::P",
        k_Q "kaacore::Keycode::Q",
        k_R "kaacore::Keycode::R",
        k_S "kaacore::Keycode::S",
        k_T "kaacore::Keycode::T",
        k_U "kaacore::Keycode::U",
        k_V "kaacore::Keycode::V",
        k_W "kaacore::Keycode::W",
        k_X "kaacore::Keycode::X",
        k_Y "kaacore::Keycode::Y",
        k_Z "kaacore::Keycode::Z",
        k_capslock "kaacore::Keycode::capslock",
        k_F1 "kaacore::Keycode::F1",
        k_F2 "kaacore::Keycode::F2",
        k_F3 "kaacore::Keycode::F3",
        k_F4 "kaacore::Keycode::F4",
        k_F5 "kaacore::Keycode::F5",
        k_F6 "kaacore::Keycode::F6",
        k_F7 "kaacore::Keycode::F7",
        k_F8 "kaacore::Keycode::F8",
        k_F9 "kaacore::Keycode::F9",
        k_F10 "kaacore::Keycode::F10",
        k_F11 "kaacore::Keycode::F11",
        k_F12 "kaacore::Keycode::F12",
        k_printscreen "kaacore::Keycode::printscreen",
        k_scrolllock "kaacore::Keycode::scrolllock",
        k_pause "kaacore::Keycode::pause",
        k_insert "kaacore::Keycode::insert",
        k_home "kaacore::Keycode::home",
        k_pageup "kaacore::Keycode::pageup",
        k_delete "kaacore::Keycode::delete_",
        k_end "kaacore::Keycode::end",
        k_pagedown "kaacore::Keycode::pagedown",
        k_right "kaacore::Keycode::right",
        k_left "kaacore::Keycode::left",
        k_down "kaacore::Keycode::down",
        k_up "kaacore::Keycode::up",
        k_numlockclear "kaacore::Keycode::numlockclear",
        k_kp_divide "kaacore::Keycode::kp_divide",
        k_kp_multiply "kaacore::Keycode::kp_multiply",
        k_kp_minus "kaacore::Keycode::kp_minus",
        k_kp_plus "kaacore::Keycode::kp_plus",
        k_kp_enter "kaacore::Keycode::kp_enter",
        k_kp_1 "kaacore::Keycode::kp_1",
        k_kp_2 "kaacore::Keycode::kp_2",
        k_kp_3 "kaacore::Keycode::kp_3",
        k_kp_4 "kaacore::Keycode::kp_4",
        k_kp_5 "kaacore::Keycode::kp_5",
        k_kp_6 "kaacore::Keycode::kp_6",
        k_kp_7 "kaacore::Keycode::kp_7",
        k_kp_8 "kaacore::Keycode::kp_8",
        k_kp_9 "kaacore::Keycode::kp_9",
        k_kp_0 "kaacore::Keycode::kp_0",
        k_kp_period "kaacore::Keycode::kp_period",
        k_application "kaacore::Keycode::application",
        k_power "kaacore::Keycode::power",
        k_kp_equals "kaacore::Keycode::kp_equals",
        k_F13 "kaacore::Keycode::F13",
        k_F14 "kaacore::Keycode::F14",
        k_F15 "kaacore::Keycode::F15",
        k_F16 "kaacore::Keycode::F16",
        k_F17 "kaacore::Keycode::F17",
        k_F18 "kaacore::Keycode::F18",
        k_F19 "kaacore::Keycode::F19",
        k_F20 "kaacore::Keycode::F20",
        k_F21 "kaacore::Keycode::F21",
        k_F22 "kaacore::Keycode::F22",
        k_F23 "kaacore::Keycode::F23",
        k_F24 "kaacore::Keycode::F24",
        k_execute "kaacore::Keycode::execute",
        k_help "kaacore::Keycode::help",
        k_menu "kaacore::Keycode::menu",
        k_select "kaacore::Keycode::select",
        k_stop "kaacore::Keycode::stop",
        k_again "kaacore::Keycode::again",
        k_undo "kaacore::Keycode::undo",
        k_cut "kaacore::Keycode::cut",
        k_copy "kaacore::Keycode::copy",
        k_paste "kaacore::Keycode::paste",
        k_find "kaacore::Keycode::find",
        k_mute "kaacore::Keycode::mute",
        k_volumeup "kaacore::Keycode::volumeup",
        k_volumedown "kaacore::Keycode::volumedown",
        k_kp_comma "kaacore::Keycode::kp_comma",
        k_kp_equalsas400 "kaacore::Keycode::kp_equalsas400",
        k_alterase "kaacore::Keycode::alterase",
        k_sysreq "kaacore::Keycode::sysreq",
        k_cancel "kaacore::Keycode::cancel",
        k_clear "kaacore::Keycode::clear",
        k_prior "kaacore::Keycode::prior",
        k_return2 "kaacore::Keycode::return2",
        k_separator "kaacore::Keycode::separator",
        k_out "kaacore::Keycode::out",
        k_oper "kaacore::Keycode::oper",
        k_clearagain "kaacore::Keycode::clearagain",
        k_crsel "kaacore::Keycode::crsel",
        k_exsel "kaacore::Keycode::exsel",
        k_kp_00 "kaacore::Keycode::kp_00",
        k_kp_000 "kaacore::Keycode::kp_000",
        k_thousandsseparator "kaacore::Keycode::thousandsseparator",
        k_decimalseparator "kaacore::Keycode::decimalseparator",
        k_currencyunit "kaacore::Keycode::currencyunit",
        k_currencysubunit "kaacore::Keycode::currencysubunit",
        k_kp_leftparen "kaacore::Keycode::kp_leftparen",
        k_kp_rightparen "kaacore::Keycode::kp_rightparen",
        k_kp_leftbrace "kaacore::Keycode::kp_leftbrace",
        k_kp_rightbrace "kaacore::Keycode::kp_rightbrace",
        k_kp_tab "kaacore::Keycode::kp_tab",
        k_kp_backspace "kaacore::Keycode::kp_backspace",
        k_kp_a "kaacore::Keycode::kp_a",
        k_kp_b "kaacore::Keycode::kp_b",
        k_kp_c "kaacore::Keycode::kp_c",
        k_kp_d "kaacore::Keycode::kp_d",
        k_kp_e "kaacore::Keycode::kp_e",
        k_kp_f "kaacore::Keycode::kp_f",
        k_kp_xor "kaacore::Keycode::kp_xor",
        k_kp_power "kaacore::Keycode::kp_power",
        k_kp_percent "kaacore::Keycode::kp_percent",
        k_kp_less "kaacore::Keycode::kp_less",
        k_kp_greater "kaacore::Keycode::kp_greater",
        k_kp_ampersand "kaacore::Keycode::kp_ampersand",
        k_kp_dblampersand "kaacore::Keycode::kp_dblampersand",
        k_kp_verticalbar "kaacore::Keycode::kp_verticalbar",
        k_kp_dblverticalbar "kaacore::Keycode::kp_dblverticalbar",
        k_kp_colon "kaacore::Keycode::kp_colon",
        k_kp_hash "kaacore::Keycode::kp_hash",
        k_kp_space "kaacore::Keycode::kp_space",
        k_kp_at "kaacore::Keycode::kp_at",
        k_kp_exclam "kaacore::Keycode::kp_exclam",
        k_kp_memstore "kaacore::Keycode::kp_memstore",
        k_kp_memrecall "kaacore::Keycode::kp_memrecall",
        k_kp_memclear "kaacore::Keycode::kp_memclear",
        k_kp_memadd "kaacore::Keycode::kp_memadd",
        k_kp_memsubtract "kaacore::Keycode::kp_memsubtract",
        k_kp_memmultiply "kaacore::Keycode::kp_memmultiply",
        k_kp_memdivide "kaacore::Keycode::kp_memdivide",
        k_kp_plusminus "kaacore::Keycode::kp_plusminus",
        k_kp_clear "kaacore::Keycode::kp_clear",
        k_kp_clearentry "kaacore::Keycode::kp_clearentry",
        k_kp_binary "kaacore::Keycode::kp_binary",
        k_kp_octal "kaacore::Keycode::kp_octal",
        k_kp_decimal "kaacore::Keycode::kp_decimal",
        k_kp_hexadecimal "kaacore::Keycode::kp_hexadecimal",
        k_lctrl "kaacore::Keycode::lctrl",
        k_lshift "kaacore::Keycode::lshift",
        k_lalt "kaacore::Keycode::lalt",
        k_lgui "kaacore::Keycode::lgui",
        k_rctrl "kaacore::Keycode::rctrl",
        k_rshift "kaacore::Keycode::rshift",
        k_ralt "kaacore::Keycode::ralt",
        k_rgui "kaacore::Keycode::rgui",
        k_mode "kaacore::Keycode::mode",
        k_audionext "kaacore::Keycode::audionext",
        k_audioprev "kaacore::Keycode::audioprev",
        k_audiostop "kaacore::Keycode::audiostop",
        k_audioplay "kaacore::Keycode::audioplay",
        k_audiomute "kaacore::Keycode::audiomute",
        k_mediaselect "kaacore::Keycode::mediaselect",
        k_www "kaacore::Keycode::www",
        k_mail "kaacore::Keycode::mail",
        k_calculator "kaacore::Keycode::calculator",
        k_computer "kaacore::Keycode::computer",
        k_ac_search "kaacore::Keycode::ac_search",
        k_ac_home "kaacore::Keycode::ac_home",
        k_ac_back "kaacore::Keycode::ac_back",
        k_ac_forward "kaacore::Keycode::ac_forward",
        k_ac_stop "kaacore::Keycode::ac_stop",
        k_ac_refresh "kaacore::Keycode::ac_refresh",
        k_ac_bookmarks "kaacore::Keycode::ac_bookmarks",
        k_brightnessdown "kaacore::Keycode::brightnessdown",
        k_brightnessup "kaacore::Keycode::brightnessup",
        k_displayswitch "kaacore::Keycode::displayswitch",
        k_kbdillumtoggle "kaacore::Keycode::kbdillumtoggle",
        k_kbdillumdown "kaacore::Keycode::kbdillumdown",
        k_kbdillumup "kaacore::Keycode::kbdillumup",
        k_eject "kaacore::Keycode::eject",
        k_sleep "kaacore::Keycode::sleep"

    cdef enum CMouseButton "kaacore::MouseButton":
        m_left "kaacore::MouseButton::left",
        m_middle "kaacore::MouseButton::middle",
        m_right "kaacore::MouseButton::right",
        m_x1 "kaacore::MouseButton::x1",
        m_x2 "kaacore::MouseButton::x2"

    cdef enum CControllerButton "kaacore::ControllerButton":
        c_a "kaacore::ControllerButton::a",
        c_b "kaacore::ControllerButton::b",
        c_x "kaacore::ControllerButton::x",
        c_y "kaacore::ControllerButton::y",
        c_back "kaacore::ControllerButton::back",
        c_guide "kaacore::ControllerButton::guide",
        c_start "kaacore::ControllerButton::start",
        c_left_stick "kaacore::ControllerButton::left_stick",
        c_right_stick "kaacore::ControllerButton::right_stick",
        c_left_shoulder "kaacore::ControllerButton::left_shoulder",
        c_right_shoulder "kaacore::ControllerButton::right_shoulder",
        c_dpad_up "kaacore::ControllerButton::dpad_up",
        c_dpad_down "kaacore::ControllerButton::dpad_down",
        c_dpad_left "kaacore::ControllerButton::dpad_left",
        c_dpad_right "kaacore::ControllerButton::dpad_right"

    cdef enum CControllerAxis "kaacore::ControllerAxis":
        c_left_x "kaacore::ControllerAxis::left_x",
        c_left_y "kaacore::ControllerAxis::left_y",
        c_right_x "kaacore::ControllerAxis::right_x",
        c_right_y "kaacore::ControllerAxis::right_y",
        c_trigger_left "kaacore::ControllerAxis::trigger_left",
        c_trigger_right "kaacore::ControllerAxis::trigger_right",

    cdef enum CEventType "kaacore::EventType":
        quit "kaacore::EventType::quit",
        clipboard_updated "kaacore::EventType::clipboard_updated",
        window_shown "kaacore::EventType::window_shown",
        window_hidden "kaacore::EventType::window_hidden",
        window_exposed "kaacore::EventType::window_exposed",
        window_moved "kaacore::EventType::window_moved",
        window_resized "kaacore::EventType::window_resized",
        window_minimized "kaacore::EventType::window_minimized",
        window_maximized "kaacore::EventType::window_maximized",
        window_restored "kaacore::EventType::window_restored",
        window_enter "kaacore::EventType::window_enter",
        window_leave "kaacore::EventType::window_leave",
        window_focus_gained "kaacore::EventType::window_focus_gained",
        window_focus_lost "kaacore::EventType::window_focus_lost",
        window_close "kaacore::EventType::window_close",
        key_down "kaacore::EventType::key_down",
        key_up "kaacore::EventType::key_up",
        text_input "kaacore::EventType::text_input",
        mouse_motion "kaacore::EventType::mouse_motion",
        mouse_button_down "kaacore::EventType::mouse_button_down",
        mouse_button_up "kaacore::EventType::mouse_button_up",
        mouse_wheel "kaacore::EventType::mouse_wheel",
        controller_axis_motion "kaacore::EventType::controller_axis_motion",
        controller_button_down "kaacore::EventType::controller_button_down",
        controller_button_up "kaacore::EventType::controller_button_up",
        controller_added "kaacore::EventType::controller_added",
        controller_removed "kaacore::EventType::controller_removed",
        controller_remapped "kaacore::EventType::controller_remapped",
        music_finished "kaacore::EventType::music_finished",
        channel_finished "kaacore::EventType::channel_finished",
    
    cdef enum CCompoundControllerAxis "kaacore::CompoundControllerAxis":
        left_stick "kaacore::CompoundControllerAxis::left_stick",
        right_stick "kaacore::CompoundControllerAxis::right_stick"
    
    cdef cppclass CSystemEvent "kaacore::SystemEvent":
        bint is_quit() except +raise_py_error
        bint is_clipboard_updated() except +raise_py_error

    cdef cppclass CWindowEvent "kaacore::WindowEvent":
        bint is_shown() except +raise_py_error
        bint is_exposed() except +raise_py_error
        bint is_moved() except +raise_py_error
        bint is_resized() except +raise_py_error
        bint is_minimized() except +raise_py_error
        bint is_maximized() except +raise_py_error
        bint is_restored() except +raise_py_error
        bint is_enter() except +raise_py_error
        bint is_leave() except +raise_py_error
        bint is_focus_gained() except +raise_py_error
        bint is_focus_lost() except +raise_py_error
        bint is_close() except +raise_py_error

    cdef cppclass CKeyboardKeyEvent "kaacore::KeyboardKeyEvent":
        CKeycode key() except +raise_py_error
        bint is_key_down() except +raise_py_error
        bint is_key_up() except +raise_py_error
        bint repeat() except +raise_py_error

    cdef cppclass CKeyboardTextEvent "kaacore::KeyboardTextEvent":
        string text() except +raise_py_error

    cdef cppclass CMouseButtonEvent "kaacore::MouseButtonEvent":
        CMouseButton button() except +raise_py_error
        bint is_button_down() except +raise_py_error
        bint is_button_up() except +raise_py_error
        CVector position() except +raise_py_error

    cdef cppclass CMouseMotionEvent "kaacore::MouseMotionEvent":
        CVector position() except +raise_py_error

    cdef cppclass CMouseWheelEvent "kaacore::MouseWheelEvent":
        CVector scroll() except +raise_py_error

    cdef cppclass CControllerButtonEvent "kaacore::ControllerButtonEvent":
        CControllerID id() except +raise_py_error
        CControllerButton button() except +raise_py_error
        bint is_button_down() except +raise_py_error
        bint is_button_up() except +raise_py_error

    cdef cppclass CControllerAxisEvent "kaacore::ControllerAxisEvent":
        CControllerID id() except +raise_py_error
        CControllerAxis axis() except +raise_py_error
        double motion() except +raise_py_error

    cdef cppclass CControllerDeviceEvent "kaacore::ControllerDeviceEvent":
        CControllerID id() except +raise_py_error
        bint is_added() except +raise_py_error
        bint is_removed() except +raise_py_error

    cdef cppclass CMusicFinishedEvent "kaacore::MusicFinishedEvent":
        pass

    cdef cppclass CEvent "kaacore::Event":
        CEventType type() except +raise_py_error
        uint32_t timestamp() except +raise_py_error
        const CSystemEvent* const system() except +raise_py_error
        const CWindowEvent* const window() except +raise_py_error
        const CKeyboardKeyEvent* const keyboard_key() except +raise_py_error
        const CKeyboardTextEvent* const keyboard_text() except +raise_py_error
        const CMouseButtonEvent* const mouse_button() except +raise_py_error
        const CMouseMotionEvent* const mouse_motion() except +raise_py_error
        const CMouseWheelEvent* const mouse_wheel() except +raise_py_error
        const CControllerButtonEvent* const controller_button() except +raise_py_error
        const CControllerAxisEvent* const controller_axis() except +raise_py_error
        const CControllerDeviceEvent* const controller_device() except +raise_py_error
        const CMusicFinishedEvent* const music_finished() except +raise_py_error
    
    cdef cppclass CSystemManager "kaacore::InputManager::SystemManager":
        string get_clipboard_text() except +raise_py_error
        void set_clipboard_text(string& text) except +raise_py_error

    cdef cppclass CKeyboardManager "kaacore::InputManager::KeyboardManager":
        bint is_pressed(CKeycode kc) except +raise_py_error
        bint is_released(CKeycode kc) except +raise_py_error

    cdef cppclass CMouseManager "kaacore::InputManager::MouseManager":
        bint is_pressed(CMouseButton mb) except +raise_py_error
        bint is_released(CMouseButton mb) except +raise_py_error
        CVector get_position() except +raise_py_error

    cdef cppclass CControllerManager "kaacore::InputManager::ControllerManager":
        bint is_connected(int32_t id_) except +raise_py_error
        bint is_pressed(CControllerButton cb, CControllerID id_) except +raise_py_error
        bint is_released(CControllerButton cb, CControllerID id_) except +raise_py_error
        bint is_pressed (CControllerAxis ca, CControllerID id_) except +raise_py_error
        bint is_released (CControllerAxis ca, CControllerID id_) except +raise_py_error
        double get_axis_motion(CControllerAxis ca, CControllerID id_) except +raise_py_error
        string get_name(CControllerID id_) except +raise_py_error
        CVector get_triggers(CControllerID id_) except +raise_py_error
        CVector get_sticks(CCompoundControllerAxis ca, CControllerID id_) except +raise_py_error
        vector[int32_t] get_connected_controllers() except +raise_py_error

    ctypedef function[int(const CEvent&)] CEventCallback "kaacore::EventCallback"

    cdef cppclass CInputManager "kaacore::InputManager":
        vector[CEvent] events_queue
        CSystemManager system
        CKeyboardManager keyboard
        CMouseManager mouse
        CControllerManager controller

        void register_callback(CEventType type_, CEventCallback callback)


cdef extern from "extra/include/pythonic_callback.h":
    ctypedef int32_t (*CythonEventCallback)(CPythonicCallbackWrapper, const CEvent&)
    CythonEventCallback bind_cython_event_callback(
        const CythonEventCallback cy_handler,
        const CPythonicCallbackWrapper callback
    )
