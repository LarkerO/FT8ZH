import 'dart:async';

import 'package:flutter/services.dart';

import '../domain/models.dart';

class NativeBridge {
  NativeBridge._();

  static const MethodChannel _methodChannel = MethodChannel(
    'cn.bg7qvu.ft8zh/native',
  );
  static const EventChannel _timerChannel = EventChannel(
    'cn.bg7qvu.ft8zh/timer',
  );
  static const EventChannel _stateChannel = EventChannel(
    'cn.bg7qvu.ft8zh/state',
  );

  static Future<Map<String, dynamic>> getPlatformSummary() async {
    final result = await _methodChannel.invokeMapMethod<String, dynamic>(
      'getPlatformSummary',
    );
    return result ?? const <String, dynamic>{};
  }

  static Future<ConsoleSnapshot> getInitialSnapshot() async {
    final result = await _methodChannel.invokeMapMethod<Object?, Object?>(
      'getInitialSnapshot',
    );
    final map = result ?? const <Object?, Object?>{};
    return ConsoleSnapshot(
      rigState: RigState.fromMap(
        (map['rigState'] as Map<Object?, Object?>?) ??
            const <Object?, Object?>{},
      ),
      timerState: TimerState.fromMap(
        (map['timerState'] as Map<Object?, Object?>?) ??
            const <Object?, Object?>{},
      ),
      messages: ((map['messages'] as List<Object?>?) ?? const <Object?>[])
          .whereType<Map<Object?, Object?>>()
          .map(DecodeMessage.fromMap)
          .toList(growable: false),
    );
  }

  static Future<void> startListening() =>
      _methodChannel.invokeMethod<void>('startListening');

  static Future<void> stopListening() =>
      _methodChannel.invokeMethod<void>('stopListening');

  static Stream<TimerState> observeTimer() {
    return _timerChannel
        .receiveBroadcastStream()
        .where((event) => event is Map)
        .cast<Map<Object?, Object?>>()
        .map(TimerState.fromMap);
  }

  static Stream<RigState> observeRigState() {
    return _stateChannel
        .receiveBroadcastStream()
        .where((event) => event is Map)
        .cast<Map<Object?, Object?>>()
        .map(RigState.fromMap);
  }
}
