class RigState {
  const RigState({
    required this.connectionLabel,
    required this.isConnected,
    required this.isListening,
    required this.mode,
    required this.frequencyHz,
    required this.audioSource,
    required this.platform,
  });

  final String connectionLabel;
  final bool isConnected;
  final bool isListening;
  final String mode;
  final int frequencyHz;
  final String audioSource;
  final String platform;

  String get frequencyText {
    final mhz = frequencyHz / 1000000;
    return '${mhz.toStringAsFixed(3)} MHz';
  }

  RigState copyWith({
    String? connectionLabel,
    bool? isConnected,
    bool? isListening,
    String? mode,
    int? frequencyHz,
    String? audioSource,
    String? platform,
  }) {
    return RigState(
      connectionLabel: connectionLabel ?? this.connectionLabel,
      isConnected: isConnected ?? this.isConnected,
      isListening: isListening ?? this.isListening,
      mode: mode ?? this.mode,
      frequencyHz: frequencyHz ?? this.frequencyHz,
      audioSource: audioSource ?? this.audioSource,
      platform: platform ?? this.platform,
    );
  }

  factory RigState.fromMap(Map<Object?, Object?> map) {
    return RigState(
      connectionLabel: (map['connectionLabel'] as String?) ?? '未连接',
      isConnected: (map['isConnected'] as bool?) ?? false,
      isListening: (map['isListening'] as bool?) ?? false,
      mode: (map['mode'] as String?) ?? 'FT8',
      frequencyHz: (map['frequencyHz'] as num?)?.toInt() ?? 14074000,
      audioSource: (map['audioSource'] as String?) ?? 'MIC',
      platform: (map['platform'] as String?) ?? 'android',
    );
  }
}

class TimerState {
  const TimerState({
    required this.utcMillis,
    required this.slotProgress,
    required this.sequential,
    required this.slotLengthSeconds,
  });

  final int utcMillis;
  final double slotProgress;
  final int sequential;
  final int slotLengthSeconds;

  Duration get remaining {
    final remainingMs =
        ((1 - slotProgress).clamp(0, 1) * slotLengthSeconds * 1000).round();
    return Duration(milliseconds: remainingMs);
  }

  String get utcLabel {
    final date = DateTime.fromMillisecondsSinceEpoch(utcMillis, isUtc: true);
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    final ss = date.second.toString().padLeft(2, '0');
    return 'UTC $hh:$mm:$ss';
  }

  String get slotLabel => 'T+$sequential';

  factory TimerState.fromMap(Map<Object?, Object?> map) {
    return TimerState(
      utcMillis: (map['utcMillis'] as num?)?.toInt() ?? 0,
      slotProgress: ((map['slotProgress'] as num?)?.toDouble() ?? 0).clamp(
        0,
        1,
      ),
      sequential: (map['sequential'] as num?)?.toInt() ?? 0,
      slotLengthSeconds: (map['slotLengthSeconds'] as num?)?.toInt() ?? 15,
    );
  }
}

class DecodeMessage {
  const DecodeMessage({
    required this.text,
    required this.snr,
    required this.offsetHz,
    required this.isWeakSignal,
  });

  final String text;
  final int snr;
  final int offsetHz;
  final bool isWeakSignal;

  factory DecodeMessage.fromMap(Map<Object?, Object?> map) {
    return DecodeMessage(
      text: (map['text'] as String?) ?? '',
      snr: (map['snr'] as num?)?.toInt() ?? 0,
      offsetHz: (map['offsetHz'] as num?)?.toInt() ?? 0,
      isWeakSignal: (map['isWeakSignal'] as bool?) ?? false,
    );
  }
}

class ConsoleSnapshot {
  const ConsoleSnapshot({
    required this.rigState,
    required this.timerState,
    required this.messages,
  });

  final RigState rigState;
  final TimerState timerState;
  final List<DecodeMessage> messages;

  factory ConsoleSnapshot.initial() {
    return ConsoleSnapshot(
      rigState: const RigState(
        connectionLabel: '未连接',
        isConnected: false,
        isListening: false,
        mode: 'FT8',
        frequencyHz: 14074000,
        audioSource: 'MIC',
        platform: 'android',
      ),
      timerState: const TimerState(
        utcMillis: 0,
        slotProgress: 0,
        sequential: 0,
        slotLengthSeconds: 15,
      ),
      messages: const [],
    );
  }
}
