from libcpp.memory cimport unique_ptr
from cython.view cimport array as cvarray

from .kaacore.capture cimport CCapturingAdapterBase, CMemoryVectorCapturingAdapter

import base64
from io import BytesIO


cdef class CapturingWrapperBase:
    cdef unique_ptr[CCapturingAdapterBase] capturing_adapter

    cdef CCapturingAdapterBase* c_get_adapter(self):
        assert self.capturing_adapter.get() != NULL
        return self.capturing_adapter.get()

    def get_result(self):
        raise NotImplementedError


cdef class AnimatedGifCapturingWrapper(CapturingWrapperBase):
    def __init__(self):
        self.capturing_adapter = \
            unique_ptr[CCapturingAdapterBase](new CMemoryVectorCapturingAdapter())

    @property
    def frames_memoryviews(self):
        cdef CMemoryVectorCapturingAdapter* c_capturing_adapter = \
                <CMemoryVectorCapturingAdapter*>self.capturing_adapter.get()
        cdef cvarray image_array
        cdef uint8_t* frame_data
        cdef tuple frame_shape = self.frame_shape
        cdef list collected_memoryviews = []

        for frame_data in c_capturing_adapter.frames_uint8():
            image_array = cvarray(
                shape=frame_shape,
                itemsize=4, format='I', mode='c', allocate_buffer=False,
            )
            image_array.data = <char*>frame_data
            collected_memoryviews.append(image_array.get_memview())
        return collected_memoryviews

    @property
    def frame_shape(self):
        cdef CMemoryVectorCapturingAdapter* c_capturing_adapter = \
                <CMemoryVectorCapturingAdapter*>self.capturing_adapter.get()
        return (c_capturing_adapter.width(), c_capturing_adapter.height())

    def get_result(self):
        from PIL import Image

        cdef object bytes_buffer = BytesIO()
        cdef list images = [Image.frombuffer('RGBA', memview.shape, memview)
                            for memview in self.frames_memoryviews]

        images[0].save(bytes_buffer,
                       format='gif',
                       save_all=True,
                       append_images=images[1:],
                       duration=50,
                       loop=0)
        return AnimatedGifCaptureResult(bytes_buffer)


cdef class AnimatedGifCaptureResult:
    cdef object bytes_buffer

    def __init__(self, object bytes_buffer not None):
        self.bytes_buffer = bytes_buffer

    def _repr_html_(self):
        self.bytes_buffer.seek(0)
        return '<img src="data:image/gif;base64,{}" />'.format(
            base64.b64encode(self.bytes_buffer.read()).decode('ascii')
        )


cdef CapturingWrapperBase c_get_default_capturing_wrapper():
    return AnimatedGifCapturingWrapper()
