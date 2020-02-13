import sys
import os
from collections import namedtuple

from kaa.engine import Engine, Scene, get_engine
from kaa.geometry import Vector, Alignment
from kaa.audio import Sound, SoundPlayback
from kaa.fonts import TextNode, Font
from kaa.colors import Color
from kaa.input import Keycode


FONT_PATH = os.path.join('kaacore', 'demos', 'assets', 'fonts',
                         'Roboto', 'Roboto-Regular.ttf')

SampleEntry = namedtuple('SampleEntry',
                         ['name', 'playback', 'ui_node', 'index'])


ENTRY_INACTIVE_COLOR = Color(1., 1., 1.)
ENTRY_ACTIVE_COLOR = Color(1., 0.5, 0.5)


class SamplePlayerDemoScene(Scene):
    def __init__(self, samples_paths):
        self.font = Font(FONT_PATH)
        self.samples = []
        for idx, path in enumerate(samples_paths):
            print("Loading... {}".format(path))
            name = os.path.basename(path)
            playback = SoundPlayback(Sound(path))
            ui_node = self.root.add_child(
                TextNode(
                    font_size=5.,
                    font=self.font,
                    # simple multiline positioning
                    position=Vector(10, 10 + idx * 8),
                    origin_alignment=Alignment.top_left,
                )
            )
            self.samples.append(
                SampleEntry(name, playback, ui_node, idx)
            )

        self.active_ui_entry_index = 0
        self._update_ui_nodes()

    def _update_ui_nodes(self):
        for sample in self.samples:
            if sample.index == self.active_ui_entry_index:
                sample.ui_node.color = ENTRY_ACTIVE_COLOR
            else:
                sample.ui_node.color = ENTRY_INACTIVE_COLOR
            sample.ui_node.text = "{} ({}) [{:.0f}%]".format(
                sample.name, str(sample.playback.state),
                sample.playback.volume * 100
            )

    def update(self, dt):
        for event in self.input.events():
            if event.system and event.system.quit:
                self.engine.quit()
            elif event.keyboard_key and event.keyboard_key.is_key_down:
                pressed_key = event.keyboard_key.key
                if pressed_key == Keycode.up:
                    self.active_ui_entry_index = (
                        (self.active_ui_entry_index - 1) % len(self.samples)
                    )
                elif pressed_key == Keycode.down:
                    self.active_ui_entry_index = (
                        (self.active_ui_entry_index + 1) % len(self.samples)
                    )
                elif pressed_key == Keycode.x:
                    self.samples[self.active_ui_entry_index].playback.play()
                    print("Playing sample #{}".
                          format(self.active_ui_entry_index))
                elif pressed_key == Keycode.c:
                    ret = self.samples[self.active_ui_entry_index].playback.pause()
                    print("Pausing sample #{}, success: {}"
                          .format(self.active_ui_entry_index, ret))
                elif pressed_key == Keycode.v:
                    ret = self.samples[self.active_ui_entry_index].playback.resume()
                    print("Resuming sample #{}, success: {}"
                          .format(self.active_ui_entry_index, ret))
                elif pressed_key == Keycode.b:
                    ret = self.samples[self.active_ui_entry_index].playback.stop()
                    print("Stopping sample #{}, success: {}"
                          .format(self.active_ui_entry_index, ret))
                elif pressed_key == Keycode.num_9:
                    self.samples[self.active_ui_entry_index].playback.volume -= 0.1
                elif pressed_key == Keycode.num_0:
                    self.samples[self.active_ui_entry_index].playback.volume += 0.1
        self._update_ui_nodes()


def main(args):
    print("""Usage:
    Provide WAV/OGG files as command-line parameters.
    Keys:
    * Up/Down arrows - navigation
    * 0/9 volume up/down
    * X - play
    * C - pause 
    * V - resume
    * B - stop""")
    samples_paths = []
    for path in args:
        if not os.path.exists(path):
            raise Exception("Invalid sample path provided: {}"
                            .format(path))
        samples_paths.append(path)

    if not samples_paths:
        raise Exception("No samples provided")

    scene = SamplePlayerDemoScene(samples_paths)
    get_engine().run(scene)


if __name__ == '__main__':
    with Engine(virtual_resolution=Vector(150, 200)) as engine:
        main(sys.argv[1:])
