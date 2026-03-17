import 'dart:async';

import 'package:flutter/services.dart';

import '../domain/models.dart';

/// Platform bridge to the native Android layer.
///
/// Method calls and event streams follow a naming convention that mirrors
/// the original FT8CN Java/Kotlin host APIs.
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
  static const EventChannel _decodeChannel = EventChannel(
    'cn.bg7qvu.ft8zh/decode',
  );
  static const EventChannel _spectrumChannel = EventChannel(
    'cn.bg7qvu.ft8zh/spectrum',
  );

  // -----------------------------------------------------------------------
  // Method channel calls
  // -----------------------------------------------------------------------

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
      messages: _parseMessages(map['messages']),
      config: AppConfig.fromMap(
        (map['config'] as Map<Object?, Object?>?) ??
            const <Object?, Object?>{},
      ),
    );
  }

  static Future<void> startListening() =>
      _methodChannel.invokeMethod<void>('startListening');

  static Future<void> stopListening() =>
      _methodChannel.invokeMethod<void>('stopListening');

  static Future<void> startTransmit(String targetCallsign) =>
      _methodChannel.invokeMethod<void>(
        'startTransmit',
        {'callsign': targetCallsign},
      );

  static Future<void> stopTransmit() =>
      _methodChannel.invokeMethod<void>('stopTransmit');

  static Future<void> saveConfig(AppConfig config) =>
      _methodChannel.invokeMethod<void>('saveConfig', config.toMap());

  static Future<AppConfig> loadConfig() async {
    final result = await _methodChannel.invokeMapMethod<Object?, Object?>(
      'loadConfig',
    );
    return AppConfig.fromMap(result ?? const <Object?, Object?>{});
  }

  static Future<void> setBand(int frequencyHz) =>
      _methodChannel.invokeMethod<void>('setBand', {'frequencyHz': frequencyHz});

  static Future<void> setTransmitFrequency(int offsetHz) =>
      _methodChannel.invokeMethod<void>(
        'setTransmitFrequency',
        {'offsetHz': offsetHz},
      );

  static Future<List<QslRecord>> queryLogs({
    String? callsign,
    int? limit,
    int? offset,
  }) async {
    final result = await _methodChannel.invokeMethod<List<Object?>>(
      'queryLogs',
      {
        if (callsign != null) 'callsign': callsign,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      },
    );
    if (result == null) return const [];
    return result
        .whereType<Map<Object?, Object?>>()
        .map(QslRecord.fromMap)
        .toList(growable: false);
  }

  static Future<int> getLogCount() async {
    final result = await _methodChannel.invokeMethod<int>('getLogCount');
    return result ?? 0;
  }

  static Future<void> deleteLog(int id) =>
      _methodChannel.invokeMethod<void>('deleteLog', {'id': id});

  static Future<void> clearMessages() =>
      _methodChannel.invokeMethod<void>('clearMessages');

  static Future<void> callStation(String callsign) =>
      _methodChannel.invokeMethod<void>('callStation', {'callsign': callsign});

  // -----------------------------------------------------------------------
  // Event channel streams
  // -----------------------------------------------------------------------

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

  static Stream<List<DecodeMessage>> observeDecodeMessages() {
    return _decodeChannel
        .receiveBroadcastStream()
        .where((event) => event is List)
        .map((event) => _parseMessages(event));
  }

  static Stream<List<double>> observeSpectrum() {
    return _spectrumChannel
        .receiveBroadcastStream()
        .where((event) => event is List)
        .map(
          (event) => (event as List<Object?>)
              .map((e) => (e as num?)?.toDouble() ?? 0)
              .toList(growable: false),
        );
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------

  static List<DecodeMessage> _parseMessages(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<Object?, Object?>>()
        .map(DecodeMessage.fromMap)
        .toList(growable: false);
  }
}
