import 'package:flutter/foundation.dart';

Future<T> runInIsolate<T>(T Function() computation) async {
  return compute<_Payload<T>, T>(_run, _Payload(computation));
}

@immutable
class _Payload<T> {
  const _Payload(this.computation);
  final T Function() computation;
}

T _run<T>(_Payload<T> p) => p.computation();
