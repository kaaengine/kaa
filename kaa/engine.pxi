from .kaacore.engine cimport CEngine, get_c_engine
from .kaacore.scenes cimport CScene


def start_game(scene_builder, *args, **kwargs):
    cdef CEngine c_engine
    cdef Scene scene = scene_builder(*args, **kwargs)
    c_engine.attach_scene(<CScene*>scene.c_scene)
    c_engine.scene_run()


def quit_game():
    cdef CEngine* c_engine = get_c_engine()
    assert c_engine != NULL
    c_engine.attach_scene(NULL)
