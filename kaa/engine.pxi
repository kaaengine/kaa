from enum import IntEnum
from contextlib import contextmanager

from libcpp.memory cimport unique_ptr
from libcpp.vector cimport vector

from .kaacore.vectors cimport CUVec2
from .kaacore.scenes cimport CScene
from .kaacore.engine cimport CEngine, get_c_engine, CVirtualResolutionMode
from .kaacore.display cimport CDisplay
from .kaacore.log cimport c_log_dynamic, CLogCategory, CLogLevel

from . import __version__


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
         _Renderer _renderer
         _AudioManager _audio_manager

    def __init__(self):
        self._window = _Window()
        self._renderer = _Renderer()
        self._audio_manager = _AudioManager()

    cdef inline CEngine* _get_c_engine(self):
        cdef CEngine* c_engine = get_c_engine()
        if c_engine == NULL:
            raise ValueError("Engine is not running")
        return c_engine

    @property
    def current_scene(self):
        return (<CPyScene*>self._get_c_engine().current_scene()).get_py_scene()

    def change_scene(self, Scene scene not None):
        self._get_c_engine().change_scene(scene.c_scene)

    def run(self, Scene scene not None):
        self._get_c_engine().run(<CScene*>scene.c_scene)

    def quit(self):
        self._get_c_engine().quit()

    def get_displays(self):
        cdef vector[CDisplay] c_displays = self._get_c_engine().get_displays()
        cdef CDisplay c_disp
        displays_list = []

        for c_disp in c_displays:
            displays_list.append(Display._wrap_c_display(c_disp))
        return displays_list

    @property
    def virtual_resolution(self):
        cdef CUVec2 c_virtual_resolution = self._get_c_engine().virtual_resolution()
        return Vector(c_virtual_resolution.x,
                      c_virtual_resolution.y)

    @virtual_resolution.setter
    def virtual_resolution(self, Vector new_resolution):
        self._get_c_engine().virtual_resolution(
            CUVec2(new_resolution.x, new_resolution.y)
        )

    @property
    def virtual_resolution_mode(self):
        return VirtualResolutionMode(
            <uint32_t>self._get_c_engine().virtual_resolution_mode()
        )

    @property
    def virtual_resolution_mode(self):
        return VirtualResolutionMode(
            <uint32_t>self._get_c_engine().virtual_resolution_mode()
        )

    @virtual_resolution_mode.setter
    def virtual_resolution_mode(self, new_mode):
        self._get_c_engine().virtual_resolution_mode(
            <CVirtualResolutionMode>(<uint32_t>(int(new_mode)))
        )

    @property
    def window(self):
        return self._window

    @property
    def renderer(self):
        return self._renderer

    @property
    def audio(self):
        return self._audio_manager

    def stop(self):
        if get_c_engine() == NULL:
            raise ValueError("Engine is stopped")
        assert _c_engine_instance != NULL

        _c_engine_instance.reset(NULL)

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.stop()


cdef _Engine _engine_wrapper = _Engine()


def Engine(Vector virtual_resolution,
           virtual_resolution_mode=None, show_window=True):
    global _c_engine_instance
    if get_c_engine() != NULL:
        raise ValueError('Engine was already started.')
    assert _c_engine_instance == NULL

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
    _c_engine_instance = unique_ptr[CEngine](c_engine_ptr)

    c_log_dynamic(
        CLogLevel.info, CLogCategory.engine, 'Engine initialized.'
    )
    _print_hello_message()

    if show_window is True:
        _engine_wrapper.window.show()

    return _engine_wrapper


def get_engine():
    if get_c_engine() != NULL:
        return _engine_wrapper


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
        c_log_dynamic(CLogLevel.info, CLogCategory.engine, line.encode())
