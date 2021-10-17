from libcpp.vector cimport vector
from cython.view cimport array as cvarray

from .kaacore.capture cimport CCapturedFrames

import base64
from io import BytesIO


cdef class CapturedFrames:
    cdef CCapturedFrames c_captured_frames

    cdef void c_attach_captured_frames(self, CCapturedFrames& c_captured_frames):
        self.c_captured_frames = c_captured_frames

    @property
    def memoryviews(self):
        cdef cvarray image_array
        cdef uint8_t* frame_data
        cdef tuple dimensions = self.dimensions
        cdef list collected_memoryviews = []

        for frame_data in self.c_captured_frames.raw_ptr_frames_uint8():
            image_array = cvarray(
                shape=dimensions,
                itemsize=4, format='I', mode='c', allocate_buffer=False,
            )
            image_array.data = <char*>frame_data
            collected_memoryviews.append(image_array.get_memview())
        return collected_memoryviews

    @property
    def dimensions(self):
        return (self.c_captured_frames.width, self.c_captured_frames.height)


class HTMLBase64Image:
    def __init__(self, bytes content, str image_type):
        self.content_encoded = base64.b64encode(content).decode('ascii')
        self.image_type = image_type

    def _repr_html_(self):
        return '<img src="data:{};base64,{}" />'.format(
            self.image_type, self.content_encoded,
        )


def generate_gif(CapturedFrames captured_frames, *, duration=33):
    from PIL import Image

    cdef object bytes_buffer = BytesIO()
    cdef list images = [Image.frombuffer('RGBA', memview.shape, memview)
                        for memview in captured_frames.memoryviews]

    images[0].save(
        bytes_buffer, format='gif', save_all=True,
        append_images=images[1:], duration=duration, loop=0,
        optimize=False,
    )

    bytes_buffer.seek(0)
    return HTMLBase64Image(bytes_buffer.read(), 'image/gif')


def generate_auto(CapturedFrames captured_frames):
    return generate_gif(captured_frames)
