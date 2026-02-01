import 'dart:async';
import '../constants/app_constants.dart';

/// Service for listening to real-time updates from backend
/// Uses polling mechanism to check for updates periodically
class RealtimeUpdateService {
  Timer? _pollingTimer;
  bool _isPolling = false;
  final Map<String, Function> _updateCallbacks = {};
  final Map<String, DateTime> _lastUpdateTimes = {};

  /// Start polling for updates
  void startPolling({
    required String key,
    required Future<void> Function() updateCallback,
    Duration? interval,
  }) {
    if (_isPolling && _updateCallbacks.containsKey(key)) {
      return; // Already polling for this key
    }

    _updateCallbacks[key] = updateCallback;
    _lastUpdateTimes[key] = DateTime.now();

    if (!_isPolling) {
      _isPolling = true;
      _startPollingTimer(interval ?? AppConstants.pollingInterval);
    }
  }

  /// Stop polling for a specific key
  void stopPolling(String key) {
    _updateCallbacks.remove(key);
    _lastUpdateTimes.remove(key);

    if (_updateCallbacks.isEmpty) {
      _stopPollingTimer();
      _isPolling = false;
    }
  }

  /// Stop all polling
  void stopAllPolling() {
    _updateCallbacks.clear();
    _lastUpdateTimes.clear();
    _stopPollingTimer();
    _isPolling = false;
  }

  /// Manually trigger update for a specific key
  Future<void> triggerUpdate(String key) async {
    final callback = _updateCallbacks[key];
    if (callback != null) {
      await callback();
      _lastUpdateTimes[key] = DateTime.now();
    }
  }

  /// Get last update time for a key
  DateTime? getLastUpdateTime(String key) {
    return _lastUpdateTimes[key];
  }

  void _startPollingTimer(Duration interval) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(interval, (timer) async {
      if (_updateCallbacks.isEmpty) {
        _stopPollingTimer();
        _isPolling = false;
        return;
      }

      // Execute all callbacks
      for (final entry in _updateCallbacks.entries) {
        try {
          await entry.value();
          _lastUpdateTimes[entry.key] = DateTime.now();
        } catch (e) {
          print('Error in polling callback for ${entry.key}: $e');
        }
      }
    });
  }

  void _stopPollingTimer() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Dispose service
  void dispose() {
    stopAllPolling();
  }
}
