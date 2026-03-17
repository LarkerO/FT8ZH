import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../domain/models.dart';
import '../platform_bridge/native_bridge.dart';

class ConsoleController extends ChangeNotifier {
  ConsoleController();

  ConsoleSnapshot _snapshot = ConsoleSnapshot.initial();
  Map<String, dynamic> _platformSummary = const {};
  bool _isBusy = true;
  String? _error;

  StreamSubscription<TimerState>? _timerSub;
  StreamSubscription<RigState>? _rigSub;

  ConsoleSnapshot get snapshot => _snapshot;
  Map<String, dynamic> get platformSummary => _platformSummary;
  bool get isBusy => _isBusy;
  String? get error => _error;

  List<double> get spectrumPreview {
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
      await _timerSub?.cancel();
      await _rigSub?.cancel();
      _timerSub = NativeBridge.observeTimer().listen((timerState) {
        _snapshot = ConsoleSnapshot(
          rigState: _snapshot.rigState,
          timerState: timerState,
          messages: _snapshot.messages,
        );
        notifyListeners();
      });
      _rigSub = NativeBridge.observeRigState().listen((rigState) {
        _snapshot = ConsoleSnapshot(
          rigState: rigState,
          timerState: _snapshot.timerState,
          messages: _snapshot.messages,
        );
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

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

  @override
  void dispose() {
    _timerSub?.cancel();
    _rigSub?.cancel();
    super.dispose();
  }
}
