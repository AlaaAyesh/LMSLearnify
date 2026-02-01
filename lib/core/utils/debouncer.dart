import 'dart:async';

/// Utility class for debouncing function calls
/// Useful for search inputs, filter changes, etc.
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  /// Execute a function after the delay period
  /// If called again before delay expires, cancels previous call
  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancel any pending execution
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Dispose resources
  void dispose() {
    cancel();
  }
}

/// Throttler for limiting function execution frequency
class Throttler {
  final Duration delay;
  DateTime? _lastExecution;

  Throttler({this.delay = const Duration(milliseconds: 300)});

  /// Execute function only if enough time has passed since last execution
  bool canExecute() {
    final now = DateTime.now();
    if (_lastExecution == null ||
        now.difference(_lastExecution!) >= delay) {
      _lastExecution = now;
      return true;
    }
    return false;
  }

  /// Reset throttler
  void reset() {
    _lastExecution = null;
  }
}
