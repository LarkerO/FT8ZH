import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../domain/models.dart';
import '../platform_bridge/native_bridge.dart';

/// Central controller that drives the main console experience.
///
/// Manages real-time state from native: timer, rig, decode messages,
/// spectrum data, and transmit status.
class ConsoleController extends ChangeNotifier {
  ConsoleController();

  ConsoleSnapshot _snapshot = ConsoleSnapshot.initial();
  Map<String, dynamic> _platformSummary = const {};
  bool _isBusy = true;
  String? _error;

  StreamSubscription<TimerState>? _timerSub;
  StreamSubscription<RigState>? _rigSub;
  StreamSubscription<List<DecodeMessage>>? _decodeSub;
  StreamSubscription<List<double>>? _spectrumSub;

  /// Raw spectrum bars from the native FFT pipeline (or a generated preview).
  List<double> _spectrumBars = const [];

  ConsoleSnapshot get snapshot => _snapshot;
  Map<String, dynamic> get platformSummary => _platformSummary;
  bool get isBusy => _isBusy;
  String? get error => _error;

  /// Spectrum bars for display. Falls back to a generated preview when
  /// the native pipeline hasn't sent any data yet.
  List<double> get spectrumBars {
    if (_spectrumBars.isNotEmpty) return _spectrumBars;
    return _generatedPreview();
  }

  // -----------------------------------------------------------------------
  // Lifecycle
  // -----------------------------------------------------------------------

  Future<void> initialize() async {
    _isBusy = true;
    notifyListeners();

    try {
      final results = await Future.wait<Object>([
        NativeBridge.getPlatformSummary(),
        NativeBridge.getInitialSnapshot(),
      ]);
      _platformSummary = results[0] as Map<String, dynamic>;
      _snapshot = results[1] as ConsoleSnapshot;
      _error = null;

      await _cancelAllSubscriptions();

      _timerSub = NativeBridge.observeTimer().listen(
        (timerState) {
          _snapshot = ConsoleSnapshot(
            rigState: _snapshot.rigState,
            timerState: timerState,
            messages: _snapshot.messages,
            config: _snapshot.config,
            transmitFunctions: _snapshot.transmitFunctions,
            decodedCount: _snapshot.decodedCount,
          );
          notifyListeners();
        },
        onError: (Object e) {
          _error = 'Timer stream error: $e';
          debugPrint(_error);
          notifyListeners();
        },
      );

      _rigSub = NativeBridge.observeRigState().listen(
        (rigState) {
          _snapshot = ConsoleSnapshot(
            rigState: rigState,
            timerState: _snapshot.timerState,
            messages: _snapshot.messages,
            config: _snapshot.config,
            transmitFunctions: _snapshot.transmitFunctions,
            decodedCount: _snapshot.decodedCount,
          );
          notifyListeners();
        },
        onError: (Object e) {
          _error = 'Rig state stream error: $e';
          debugPrint(_error);
          notifyListeners();
        },
      );

      _decodeSub = NativeBridge.observeDecodeMessages().listen(
        (messages) {
          _snapshot = ConsoleSnapshot(
            rigState: _snapshot.rigState,
            timerState: _snapshot.timerState,
            messages: messages,
            config: _snapshot.config,
            transmitFunctions: _snapshot.transmitFunctions,
            decodedCount: messages.length,
          );
          notifyListeners();
        },
        onError: (Object e) {
          _error = 'Decode stream error: $e';
          debugPrint(_error);
          notifyListeners();
        },
      );

      _spectrumSub = NativeBridge.observeSpectrum().listen(
        (bars) {
          _spectrumBars = bars;
          notifyListeners();
        },
        onError: (Object e) {
          _error = 'Spectrum stream error: $e';
          debugPrint(_error);
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  // -----------------------------------------------------------------------
  // Actions
  // -----------------------------------------------------------------------

  Future<void> toggleListening() async {
    final shouldStart = !_snapshot.rigState.isListening;
    try {
      if (shouldStart) {
        await NativeBridge.startListening();
      } else {
        await NativeBridge.stopListening();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> callStation(String callsign) async {
    try {
      await NativeBridge.callStation(callsign);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> startTransmit(String targetCallsign) async {
    try {
      await NativeBridge.startTransmit(targetCallsign);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> stopTransmit() async {
    try {
      await NativeBridge.stopTransmit();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearMessages() async {
    try {
      await NativeBridge.clearMessages();
      _snapshot = ConsoleSnapshot(
        rigState: _snapshot.rigState,
        timerState: _snapshot.timerState,
        messages: const [],
        config: _snapshot.config,
        transmitFunctions: _snapshot.transmitFunctions,
        decodedCount: 0,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> setBand(int frequencyHz) async {
    try {
      await NativeBridge.setBand(frequencyHz);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> setTransmitFrequency(int offsetHz) async {
    try {
      await NativeBridge.setTransmitFrequency(offsetHz);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------

  List<double> _generatedPreview() {
    final progress = _snapshot.timerState.slotProgress;
    final seed = _snapshot.timerState.utcMillis / 1000;
    return List<double>.generate(48, (index) {
      final x = index / 48;
      final wave = math.sin((x * 6.28318 * 3) + progress * 6.28318);
      final shimmer = math.cos(seed / 3 + index * 0.37);
      final baseline = _snapshot.rigState.isListening ? 0.48 : 0.18;
      final value = baseline + (wave * 0.16) + (shimmer * 0.08);
      return value.clamp(0.08, 0.94);
    });
  }

  Future<void> _cancelAllSubscriptions() async {
    await _timerSub?.cancel();
    await _rigSub?.cancel();
    await _decodeSub?.cancel();
    await _spectrumSub?.cancel();
  }

  @override
  void dispose() {
    _timerSub?.cancel();
    _rigSub?.cancel();
    _decodeSub?.cancel();
    _spectrumSub?.cancel();
    super.dispose();
  }
}
