import 'dart:async';

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    cancel();
  }
}

class Throttler {
  final Duration delay;
  DateTime? _lastExecution;

  Throttler({this.delay = const Duration(milliseconds: 300)});

  bool canExecute() {
    final now = DateTime.now();
    if (_lastExecution == null ||
        now.difference(_lastExecution!) >= delay) {
      _lastExecution = now;
      return true;
    }
    return false;
  }

  void reset() {
    _lastExecution = null;
  }
}
