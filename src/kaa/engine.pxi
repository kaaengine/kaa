import atexit
from enum import IntEnum
from contextlib import contextmanager

from libcpp.memory cimport unique_ptr
from libcpp.vector cimport vector

from .kaacore.vectors cimport CUVec2
from .kaacore.scenes cimport CScene
from .kaacore.engine cimport (
    CEngine, get_c_engine, is_c_engine_initialized, get_c_persistent_path,
    CVirtualResolutionMode
)
from .kaacore.display cimport CDisplay
from .kaacore.capture cimport CCapturingAdapterBase
from .kaacore.log cimport c_emit_log_dynamic, CLogLevel, _log_category_wrapper

from . import __version__


def _clean_up():
    # force _c_engine_instance deletion,
    # so we are sure that kaacore dies before the python process
    _c_engine_instance.reset()
atexit.register(_clean_up)


cdef unique_ptr[CEngine] _c_engine_instance
_c_engine_instance.reset(NULL)


class VirtualResolutionMode(IntEnum):
    adaptive_stretch = <uint32_t>CVirtualResolutionMode.adaptive_stretch
    aggresive_stretch = <uint32_t>CVirtualResolutionMode.aggresive_stretch
    no_stretch = <uint32_t>CVirtualResolutionMode.no_stretch


@cython.final
cdef class _Engine:
    cdef:
         _Window _window
         _AudioManager _audio_manager

    def __cinit__(self):
        self._window = _Window()
        self._audio_manager = _AudioManager()

    @property
    def current_scene(self):
        cdef CEngine* c_engine = get_c_engine()
        if c_engine.current_scene():
            return (<CPyScene*>c_engine.current_scene()).get_py_scene()

    @property
    def virtual_resolution(self):
        cdef CUVec2 c_virtual_resolution = get_c_engine().virtual_resolution()
        return Vector(c_virtual_resolution.x,
                      c_virtual_resolution.y)

    @virtual_resolution.setter
    def virtual_resolution(self, Vector new_resolution):
        get_c_engine().virtual_resolution(
            CUVec2(new_resolution.x, new_resolution.y)
        )

    @property
    def virtual_resolution_mode(self):
        return VirtualResolutionMode(
            <uint32_t>get_c_engine().virtual_resolution_mode()
        )

    @virtual_resolution_mode.setter
    def virtual_resolution_mode(self, new_mode):
        get_c_engine().virtual_resolution_mode(
            <CVirtualResolutionMode>(<uint32_t>(int(new_mode)))
        )

    @property
    def window(self):
        return self._window

    @property
    def audio(self):
        return self._audio_manager

    @property
    def total_time(self):
        return get_c_engine().total_time().count()

    def get_fps(self):
        return get_c_engine().get_fps()

    def change_scene(self, Scene scene not None):
        get_c_engine().change_scene(scene._c_scene.get())

    def run(self, Scene scene not None):
        cdef:
            CScene* c_scene = scene._c_scene.get()
            CEngine* c_engine = get_c_engine()
        with nogil:
            c_engine.run(c_scene, 0, NULL)

    def run_capture(
        self, Scene scene not None, uint32_t frames_limit,
        CapturingWrapperBase capturing_wrapper = None,
    ):
        cdef:
            CScene* c_scene = scene._c_scene.get()
            CEngine* c_engine = get_c_engine()
            CapturingWrapperBase final_capturing_wrapper = (
                capturing_wrapper if capturing_wrapper is not None
                else c_get_default_capturing_wrapper()
            )
            CCapturingAdapterBase* c_capture_adapter = final_capturing_wrapper.c_get_adapter()
        with nogil:
            c_engine.run(c_scene, frames_limit, c_capture_adapter)

        return final_capturing_wrapper.get_result()

    def quit(self):
        get_c_engine().quit()

    def get_displays(self):
        cdef vector[CDisplay] c_displays = get_c_engine().get_displays()
        cdef CDisplay c_disp
        displays_list = []

        for c_disp in c_displays:
            displays_list.append(Display._wrap_c_display(c_disp))
        return displays_list

    def stop(self):
        if not is_c_engine_initialized():
            raise ValueError('Engine is already stopped.')
        assert _c_engine_instance != NULL

        _c_engine_instance.reset(NULL)

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.stop()


cdef _Engine _engine_wrapper = _Engine()


def Engine(Vector virtual_resolution, virtual_resolution_mode=None):
    if is_c_engine_initialized():
        raise ValueError('Engine is already started.')

    cdef CUVec2 c_virtual_resolution = CUVec2(
        virtual_resolution.x, virtual_resolution.y
    )
    cdef CEngine* c_engine_ptr = NULL
    if virtual_resolution_mode is not None:
        c_engine_ptr = new CEngine(
            c_virtual_resolution,
            <CVirtualResolutionMode>(<uint32_t>int(virtual_resolution_mode))
        )
    else:
        c_engine_ptr = new CEngine(
            c_virtual_resolution,
        )
    assert c_engine_ptr != NULL
    global _c_engine_instance
    _c_engine_instance = unique_ptr[CEngine](c_engine_ptr)

    c_emit_log_dynamic(
        CLogLevel.info, _log_category_wrapper, 'Engine initialized.'
    )
    _print_hello_message()

    return _engine_wrapper


def get_engine():
    if is_c_engine_initialized():
        return _engine_wrapper


def get_persistent_path(str prefix not None, str organization = None):
    def _get_invalid_chars(str dir_name):
        return tuple(
            c for c in dir_name
            if not c.isalnum() and
            not c.isspace() and
            not c in ('_', '-')
        )

    organization = organization or ''
    invalid_chars = _get_invalid_chars(prefix)
    invalid_chars += _get_invalid_chars(organization)
    if invalid_chars:
        plural = len(invalid_chars) > 1
        raise Exception(
            '{} character{} {} not allowed.'.format(
                ', '.join(invalid_chars),
                's' if plural else '',
                'are' if plural else 'is'
            )
        )

    return get_c_persistent_path(
        prefix.encode(), organization.encode()
    ).c_str().decode()


cdef void _print_hello_message():
    cdef str kaa_ascii_logo = r"""
                      _   _
                   __/ \ / \
                  / |  @|@__|__
                 /   \_/      >\
                /   \__________/==<
                \       ____/
                 \     /
                 /    /
____            /    /
    \          /    /
_    \        /    /
 \    \      /    /       _   _
  \    \____/    /   |_/ |_| |_|
   \            /    | \ | | | |
    \__________/     v. {version}
    """.lstrip('\n').rstrip().format(version=__version__)

    for line in kaa_ascii_logo.split('\n'):
        c_emit_log_dynamic(CLogLevel.info, _log_category_wrapper, line.encode())
