from libcpp cimport bool
from libcpp.string cimport string
from libcpp.pair cimport pair
from libc.stdint cimport int32_t

from .vectors cimport CUVec2
from .exceptions cimport raise_py_error


cdef extern from "kaacore/window.h" nogil:
    cdef cppclass CWindow "kaacore::Window":
        void show() \
            except +raise_py_error
        void hide() \
            except +raise_py_error
        string title() \
            except +raise_py_error
        void title(const string& title) \
            except +raise_py_error
        bool fullscreen() \
            except +raise_py_error
        void fullscreen(bool fullscreen) \
            except +raise_py_error
        CUVec2 size() \
            except +raise_py_error
        void size(const CUVec2& size) \
            except +raise_py_error
        void maximize() \
            except +raise_py_error
        void minimize() \
            except +raise_py_error
        void restore() \
            except +raise_py_error
        CUVec2 position() \
            except +raise_py_error
        void position(const CUVec2& position) \
            except +raise_py_error
        void center() \
            except +raise_py_error
