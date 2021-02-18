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

  /// The [Stopwatch] used to track how long a progress log has been running.
  final _stopwatch = Stopwatch();

  /// Number of frames the animation has run.
  int ticks = 0;

  Progress(this.message);

  // Windows console font has a limited set of Unicode characters.
  List<String> get _animation => canUseUnicode
      ? const <String>['⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷']
      : const <String>[r'-', r'\', r'|', r'/'];

  String get _currentAnimationFrame => _animation[ticks % _animation.length];
  String get _backspace => '\b' * (spinnerIndent + 1);
  String get _clear => ' ' * (spinnerIndent + 1);
  static const String _margin = '     ';

  void start() {
    _stopwatch.start();
    final line = '${message.padRight(_padding)}$_margin';
    _totalMessageLength = line.length;
    _write('$line'
        '$_clear' // for _callback to backspace over
        );
    _update(_timer);

    _timer = Timer.periodic(const Duration(milliseconds: 100), _update);
  }

  void _write(String message) => stdout.write(message);

  void _update(Timer timer) {
    _write(_backspace);
    ticks += 1;
    _write('${' ' * spinnerIndent}$_currentAnimationFrame');
  }

  void stop() {
    _stopwatch.stop();
    _timer.cancel();
    _timer = null;
    _clearSpinner();
    _write(niceDuration(_stopwatch.elapsed).padLeft(_timePadding));
    _write('\n');
    _clearStatus();
  }

  void _clearSpinner() {
    _write('$_backspace$_clear$_backspace');
  }

  int get spinnerIndent => _timePadding - 1;
  static const int _timePadding = 8; // should fit "99,999ms"

  int _totalMessageLength;

  void _clearStatus() {
    _write(
      '${'\b' * _totalMessageLength}'
      '${' ' * _totalMessageLength}'
      '${'\b' * _totalMessageLength}',
    );
  }
}
