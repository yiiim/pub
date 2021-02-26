// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'utils.dart';

/// A live-updating progress indicator for long-running log entries.
class Progress {
  /// The timer used to update the animation during a progress log.
  Timer _timer;
  final String message;
  static const int _padding = 59;
  static const int _statusWidth = 8;

  /// The [Stopwatch] used to track how long a progress log has been running.
  final _stopwatch = Stopwatch();

  /// Number of frames the animation has run.
  int ticks = 0;

  Progress(this.message);

  // Windows console font has a limited set of Unicode characters.
  List<String> get _animation => canUseUnicode
      ? const <String>['⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷']
      : const <String>[r'-', r'\', r'|', r'/'];

  void start() {
    _stopwatch.start();
    _write('${'$message...'.padRight(_padding)}'
        '${' ' * _statusWidth}' // for _callback to backspace over
        );
    _update(_timer);

    _timer = Timer.periodic(const Duration(milliseconds: 100), _update);
  }

  void _write(String message) => stdout.write(message);

  void _update(Timer timer) {
    ticks += 1;
    _replaceWith(_animation[ticks % _animation.length]);
  }

  void _replaceWith(String animationFrame) {
    _write('${'\b' * _statusWidth}'
        '$animationFrame'
        '${niceDuration(_stopwatch.elapsed).padLeft(_statusWidth - 1)}');
  }

  void stop(bool success) {
    _stopwatch.stop();
    _timer.cancel();
    _timer = null;
    _replaceWith(success ? '✓' : '✗');
    _write('\n');
  }
}
