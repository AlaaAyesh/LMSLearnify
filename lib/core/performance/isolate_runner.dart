import 'package:flutter/foundation.dart';

/// Runs [computation] on a separate isolate to keep the UI thread free.
/// Use for: JSON parsing of large payloads, image processing, heavy algorithms.
/// Avoid for: trivial work (isolate spawn cost ~50–100ms).
///
/// Example:
/// ```dart
/// final result = await runInIsolate(() => parseLargeJson(responseBody));
/// ```
Future<T> runInIsolate<T>(T Function() computation) async {
  return compute<_Payload<T>, T>(_run, _Payload(computation));
}

@immutable
class _Payload<T> {
  const _Payload(this.computation);
  final T Function() computation;
}

T _run<T>(_Payload<T> p) => p.computation();
