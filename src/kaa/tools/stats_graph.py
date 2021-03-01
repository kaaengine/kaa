import re
import dataclasses
import typing
import queue
import threading
import socket
import socketserver
import struct
from collections import defaultdict

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

DEFAULT_SERVER_HOST = '0.0.0.0'
DEFAULT_SERVER_PORT = 9771

SUBPLOT_PATTERNS = [
    re.compile(r':time$'),
    re.compile(r':memory$'),
]
PLOT_ANIMATION_INTERVAL = 30  # ms
PLOT_FULL_REDRAW_INTERVAL = 100  # frames
PLOT_DISPLAYED_VALUES = 500

STAT_NAMES_ENCODING = 'utf-8'


class BinaryDatagramFormatter:
    HEADER_STRUCT = struct.Struct('=12sHH16x')
    STAT_SEGMENT_STRUCT = struct.Struct('=40sd')

    @classmethod
    def parse(cls, datagram: bytes) \
            -> typing.List[typing.Tuple[str, float]]:
        results: typing.List[typing.Tuple[str, float]] = []
        assert len(datagram) > cls.HEADER_STRUCT.size

        (magic_string, version, segments_count) = cls.HEADER_STRUCT.unpack_from(datagram)
        assert magic_string == b'KAACOREstats'
        assert version == 0x01
        assert segments_count > 0

        expected_message_size = (
            cls.HEADER_STRUCT.size
            + segments_count * cls.STAT_SEGMENT_STRUCT.size
        )
        for i in range(segments_count):
            stat_name, value = cls.STAT_SEGMENT_STRUCT.unpack_from(
                datagram, offset=(cls.HEADER_STRUCT.size
                                  + i * cls.STAT_SEGMENT_STRUCT.size)
            )
            if (null_pos := stat_name.find(b'\0')) != -1:
                stat_name = stat_name[:null_pos]
            results.append((stat_name.decode(STAT_NAMES_ENCODING), value))

        return results


class GraphingUDPServer(socketserver.UDPServer):
    def __init__(self, server_address, RequestHandlerClass, *,
                 formatter_class, data_queue, bind_and_activate=True):
        super().__init__(server_address=server_address,
                         RequestHandlerClass=RequestHandlerClass,
                         bind_and_activate=bind_and_activate)
        self.data_queue = data_queue
        self.formatter_class = formatter_class


class ServerRequestHandler(socketserver.DatagramRequestHandler):
    def handle(self):
        parsed_stats = self.server.formatter_class.parse(self.packet)
        if parsed_stats:
            self.server.data_queue.put_nowait(parsed_stats)


@dataclasses.dataclass
class GraphSettings:
    subplot_patterns: typing.List[re.Pattern] = \
        dataclasses.field(default_factory=lambda: SUBPLOT_PATTERNS)
    selected_stats: typing.List[re.Pattern] = \
        dataclasses.field(default_factory=list)


class GraphingServer:
    def __init__(self, server_host: str = DEFAULT_SERVER_HOST,
                 server_port: int = DEFAULT_SERVER_PORT,
                 graph_settings: typing.Optional[GraphSettings] = None):
        self.data_queue = queue.Queue()
        self.graph = Graph(
            data_queue=self.data_queue,
            settings=graph_settings or GraphSettings(),
        )

        self.udp_server = GraphingUDPServer(
            (server_host, server_port), ServerRequestHandler,
            formatter_class=BinaryDatagramFormatter,
            data_queue=self.data_queue,
        )
        self.udp_server_thread = threading.Thread(
            target=self.udp_server.serve_forever,
        )
        self.udp_server_thread.daemon = True
        self.udp_server_thread.start()


class Graph:
    def __init__(self, data_queue: queue.Queue,
                 settings: GraphSettings):
        self.data_queue = data_queue
        self.settings = settings

        needed_subplots_count = len(self.settings.subplot_patterns) + 1
        self.figure, self.axes = plt.subplots(needed_subplots_count, 1)
        # for single plot returned axes will not be an iterable
        if not isinstance(self.axes, np.ndarray):
            self.axes = np.array([self.axes])
        plt.subplots_adjust(left=0.1, right=0.99, top=0.95, bottom=0.05)
        for ax in self.axes:
            ax.set_xlim(-PLOT_DISPLAYED_VALUES, 0)
            ax.minorticks_on()
            ax.grid(which='major', axis='y')
            ax.grid(which='minor', axis='y', color='gray', linestyle='dotted', alpha=0.5)
            ax.get_xaxis().set_visible(False)

        self.needs_redraw = False

        self.x_data = np.arange(-PLOT_DISPLAYED_VALUES, 0) + 1
        self.y_data = np.ndarray((0, PLOT_DISPLAYED_VALUES * 2))
        self.y_data.fill(float('nan'))
        self.y_data_offset = PLOT_DISPLAYED_VALUES

        self.stat_name_metadata_map = {}
        self.ignored_stats = set()

        self.default_ax, *other_axes = self.axes
        self.pattern_subplots_map = {
            pattern: ax for pattern, ax in zip(self.settings.subplot_patterns,
                                               other_axes)
        }

    def _add_new_stat(self, stat_name):
        if self.settings.selected_stats:
            for selected_stat_pattern in self.settings.selected_stats:
                if selected_stat_pattern.match(stat_name):
                    break
            else:
                self.ignored_stats.add(stat_name)
                return False
        next_index, _ = self.y_data.shape
        for pattern, ax in self.pattern_subplots_map.items():
            if pattern.search(stat_name):
                break
        else:
            ax = self.default_ax
        new_line, *_ = ax.plot([], [], label=stat_name, lw=1)

        self.stat_name_metadata_map[stat_name] = (next_index, new_line)

        new_y_row = np.ndarray((1, PLOT_DISPLAYED_VALUES * 2))
        new_y_row.fill(float('nan'))
        self.y_data = np.vstack((self.y_data, new_y_row))
        return True

    def _add_values(self, stats):
        for stat_name, value in stats:
            if stat_name not in self.stat_name_metadata_map:
                if stat_name in self.ignored_stats:
                    continue
                elif not self._add_new_stat(stat_name):
                    continue
            y_index, _ = self.stat_name_metadata_map[stat_name]
            self.y_data[y_index, self.y_data_offset] = value

        self.y_data_offset += 1
        if self.y_data_offset == PLOT_DISPLAYED_VALUES * 2:
            self.y_data_offset = PLOT_DISPLAYED_VALUES
            self.y_data = np.roll(self.y_data, -PLOT_DISPLAYED_VALUES)
        self.needs_redraw = True

    def _plot_frame(self, frame_num):
        try:
            while frame_stats := self.data_queue.get_nowait():
                self._add_values(frame_stats)
        except queue.Empty:
            pass

        changed_lines = []
        if self.needs_redraw:
            for y_index, line in self.stat_name_metadata_map.values():
                line.set_data(
                    self.x_data,
                    self.y_data[y_index,
                                self.y_data_offset - PLOT_DISPLAYED_VALUES
                                :self.y_data_offset]
                )
                changed_lines.append(line)

        if frame_num % PLOT_FULL_REDRAW_INTERVAL == 0:
            for ax in self.axes:
                if ax.has_data():
                    ax.relim(visible_only=True)
                    ax.autoscale_view()
                    ax.legend(loc='upper left')
            self.figure.canvas.draw()
        return changed_lines

    def start_plotting(self):
        self.animation = FuncAnimation(self.figure, self._plot_frame,
                                       interval=PLOT_ANIMATION_INTERVAL, blit=True)
        plt.show()


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument('-H', '--host', type=str,
                        help="Bind to specific address (default: {})"
                        .format(DEFAULT_SERVER_HOST),
                        default=DEFAULT_SERVER_HOST)
    parser.add_argument('-P', '--port', type=int,
                        help="Port to listen on (default: {})"
                        .format(DEFAULT_SERVER_PORT),
                        default=DEFAULT_SERVER_PORT)
    parser.add_argument('-1', '--single-plot', action='store_true', dest='single_plot',
                        help="Don't use subplots")
    parser.add_argument('-s', '--select', action='append', dest='selected_stats',
                        type=str,
                        help="Select only specified stats, supports"
                        " python regex syntax, can be used multiple times")

    args = parser.parse_args()

    graph_settings = GraphSettings()
    if args.single_plot:
        graph_settings.subplot_patterns = []
    if args.selected_stats:
        graph_settings.selected_stats = [re.compile(s) for s in args.selected_stats]

    graphing_server = GraphingServer(
        server_host=args.host, server_port=args.port, graph_settings=graph_settings
    )
    print("Graph server is listening for UDP on: {}:{}"
          .format(args.host, args.port))
    print("Run your application with env: KAACORE_STATS_EXPORT_UDP={}:{} ..."
          .format(args.host, args.port))
    graphing_server.graph.start_plotting()
