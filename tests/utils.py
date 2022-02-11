from kaa.engine import Scene


class TestScene(Scene):
    def __init__(self, update_function):
        self._frames = None
        self._test_update_function = update_function

    def update(self, dt):
        if self._frames == 0:
            self.engine.quit()
            return

        self._test_update_function(self, dt)
        self._frames -= 1

    def run_on_engine(self, frames):
        self._frames = frames
        self.engine.run(self)
