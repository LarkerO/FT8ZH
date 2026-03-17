import 'ft8_constants.dart';

// ---------------------------------------------------------------------------
// Rig / radio connection state
// ---------------------------------------------------------------------------

class RigState {
  const RigState({
    required this.connectionLabel,
    required this.isConnected,
    required this.isListening,
    required this.mode,
    required this.frequencyHz,
    required this.audioSource,
    required this.platform,
    this.isTransmitting = false,
    this.isDecoding = false,
    this.isRecording = false,
    this.connectMode = 0,
    this.rigName = '',
  });

  final String connectionLabel;
  final bool isConnected;
  final bool isListening;
  final bool isTransmitting;
  final bool isDecoding;
  final bool isRecording;
  final String mode;
  final int frequencyHz;
  final String audioSource;
  final String platform;
  final int connectMode;
  final String rigName;

  String get frequencyText {
    final mhz = frequencyHz / 1e6;
    return '${mhz.toStringAsFixed(3)} MHz';
  }

  String get bandText {
    final mhz = frequencyHz / 1e6;
    if (mhz < 2) return '160m';
    if (mhz < 4) return '80m';
    if (mhz < 6) return '60m';
    if (mhz < 8) return '40m';
    if (mhz < 11) return '30m';
    if (mhz < 15) return '20m';
    if (mhz < 19) return '17m';
    if (mhz < 22) return '15m';
    if (mhz < 26) return '12m';
    if (mhz < 30) return '10m';
    if (mhz < 55) return '6m';
    if (mhz < 150) return '2m';
    return '--';
  }

  RigState copyWith({
    String? connectionLabel,
    bool? isConnected,
    bool? isListening,
    bool? isTransmitting,
    bool? isDecoding,
    bool? isRecording,
    String? mode,
    int? frequencyHz,
    String? audioSource,
    String? platform,
    int? connectMode,
    String? rigName,
  }) {
    return RigState(
      connectionLabel: connectionLabel ?? this.connectionLabel,
      isConnected: isConnected ?? this.isConnected,
      isListening: isListening ?? this.isListening,
      isTransmitting: isTransmitting ?? this.isTransmitting,
      isDecoding: isDecoding ?? this.isDecoding,
      isRecording: isRecording ?? this.isRecording,
      mode: mode ?? this.mode,
      frequencyHz: frequencyHz ?? this.frequencyHz,
      audioSource: audioSource ?? this.audioSource,
      platform: platform ?? this.platform,
      connectMode: connectMode ?? this.connectMode,
      rigName: rigName ?? this.rigName,
    );
  }

  factory RigState.fromMap(Map<Object?, Object?> map) {
    return RigState(
      connectionLabel: (map['connectionLabel'] as String?) ?? '未连接',
      isConnected: (map['isConnected'] as bool?) ?? false,
      isListening: (map['isListening'] as bool?) ?? false,
      isTransmitting: (map['isTransmitting'] as bool?) ?? false,
      isDecoding: (map['isDecoding'] as bool?) ?? false,
      isRecording: (map['isRecording'] as bool?) ?? false,
      mode: (map['mode'] as String?) ?? 'FT8',
      frequencyHz: (map['frequencyHz'] as num?)?.toInt() ?? 14074000,
      audioSource: (map['audioSource'] as String?) ?? 'MIC',
      platform: (map['platform'] as String?) ?? 'android',
      connectMode: (map['connectMode'] as num?)?.toInt() ?? 0,
      rigName: (map['rigName'] as String?) ?? '',
    );
  }
}

// ---------------------------------------------------------------------------
// UTC timer / time-slot state
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Decoded FT8/FT4 message
// ---------------------------------------------------------------------------

class DecodeMessage {
  const DecodeMessage({
    required this.text,
    required this.snr,
    required this.offsetHz,
    required this.isWeakSignal,
    this.utcTime = 0,
    this.timeSec = 0,
    this.freqHz = 0,
    this.callsignFrom = '',
    this.callsignTo = '',
    this.extraInfo = '',
    this.modifier = '',
    this.i3 = 0,
    this.n3 = 0,
    this.isCQ = false,
    this.isQslCallsign = false,
    this.signalFormat = 0,
    this.sequence = 0,
    this.maidenGrid = '',
  });

  final String text;
  final int snr;
  final int offsetHz;
  final bool isWeakSignal;
  final int utcTime;
  final double timeSec;
  final double freqHz;
  final String callsignFrom;
  final String callsignTo;
  final String extraInfo;
  final String modifier;
  final int i3;
  final int n3;
  final bool isCQ;
  final bool isQslCallsign;
  final int signalFormat;
  final int sequence;
  final String maidenGrid;

  String get modeLabel => Ft8Constants.modeName(signalFormat);

  factory DecodeMessage.fromMap(Map<Object?, Object?> map) {
    return DecodeMessage(
      text: (map['text'] as String?) ?? '',
      snr: (map['snr'] as num?)?.toInt() ?? 0,
      offsetHz: (map['offsetHz'] as num?)?.toInt() ?? 0,
      isWeakSignal: (map['isWeakSignal'] as bool?) ?? false,
      utcTime: (map['utcTime'] as num?)?.toInt() ?? 0,
      timeSec: (map['timeSec'] as num?)?.toDouble() ?? 0,
      freqHz: (map['freqHz'] as num?)?.toDouble() ?? 0,
      callsignFrom: (map['callsignFrom'] as String?) ?? '',
      callsignTo: (map['callsignTo'] as String?) ?? '',
      extraInfo: (map['extraInfo'] as String?) ?? '',
      modifier: (map['modifier'] as String?) ?? '',
      i3: (map['i3'] as num?)?.toInt() ?? 0,
      n3: (map['n3'] as num?)?.toInt() ?? 0,
      isCQ: (map['isCQ'] as bool?) ?? false,
      isQslCallsign: (map['isQslCallsign'] as bool?) ?? false,
      signalFormat: (map['signalFormat'] as num?)?.toInt() ?? 0,
      sequence: (map['sequence'] as num?)?.toInt() ?? 0,
      maidenGrid: (map['maidenGrid'] as String?) ?? '',
    );
  }
}

// ---------------------------------------------------------------------------
// QSL / QSO log record
// ---------------------------------------------------------------------------

class QslRecord {
  const QslRecord({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.myCallsign,
    required this.toCallsign,
    required this.myMaidenGrid,
    required this.toMaidenGrid,
    required this.reportSent,
    required this.reportReceived,
    required this.mode,
    required this.frequencyHz,
    this.band = '',
    this.isConfirmed = false,
  });

  final int id;
  final int startTime;
  final int endTime;
  final String myCallsign;
  final String toCallsign;
  final String myMaidenGrid;
  final String toMaidenGrid;
  final int reportSent;
  final int reportReceived;
  final String mode;
  final int frequencyHz;
  final String band;
  final bool isConfirmed;

  String get startTimeLabel {
    final dt = DateTime.fromMillisecondsSinceEpoch(startTime, isUtc: true);
    return '${dt.year}-${_p(dt.month)}-${_p(dt.day)} ${_p(dt.hour)}:${_p(dt.minute)}';
  }

  String get frequencyMhzLabel => '${(frequencyHz / 1e6).toStringAsFixed(3)}';

  static String _p(int v) => v.toString().padLeft(2, '0');

  factory QslRecord.fromMap(Map<Object?, Object?> map) {
    return QslRecord(
      id: (map['id'] as num?)?.toInt() ?? 0,
      startTime: (map['startTime'] as num?)?.toInt() ?? 0,
      endTime: (map['endTime'] as num?)?.toInt() ?? 0,
      myCallsign: (map['myCallsign'] as String?) ?? '',
      toCallsign: (map['toCallsign'] as String?) ?? '',
      myMaidenGrid: (map['myMaidenGrid'] as String?) ?? '',
      toMaidenGrid: (map['toMaidenGrid'] as String?) ?? '',
      reportSent: (map['reportSent'] as num?)?.toInt() ?? 0,
      reportReceived: (map['reportReceived'] as num?)?.toInt() ?? 0,
      mode: (map['mode'] as String?) ?? 'FT8',
      frequencyHz: (map['frequencyHz'] as num?)?.toInt() ?? 14074000,
      band: (map['band'] as String?) ?? '',
      isConfirmed: (map['isConfirmed'] as bool?) ?? false,
    );
  }
}

// ---------------------------------------------------------------------------
// Transmit function step
// ---------------------------------------------------------------------------

class TransmitFunction {
  const TransmitFunction({
    required this.order,
    required this.message,
    this.isDone = false,
  });

  final int order;
  final String message;
  final bool isDone;

  factory TransmitFunction.fromMap(Map<Object?, Object?> map) {
    return TransmitFunction(
      order: (map['order'] as num?)?.toInt() ?? 0,
      message: (map['message'] as String?) ?? '',
      isDone: (map['isDone'] as bool?) ?? false,
    );
  }
}

// ---------------------------------------------------------------------------
// Application configuration / settings
// ---------------------------------------------------------------------------

class AppConfig {
  const AppConfig({
    this.myCallsign = '',
    this.myMaidenGrid = '',
    this.toModifier = '',
    this.transmitFrequencyHz = 1500,
    this.transmitDelay = 500,
    this.launchSupervisionMs = 600000,
    this.noReplyLimit = 0,
    this.connectMode = 0,
    this.controlMode = 0,
    this.instructionSet = 0,
    this.civAddress = 0xA4,
    this.baudRate = 19200,
    this.serialDataBits = 8,
    this.serialParity = 0,
    this.serialStopBits = 1,
    this.pttDelay = 100,
    this.bandHz = 14074000,
    this.synFrequency = true,
    this.deepDecode = false,
    this.saveSWLMessages = false,
    this.enableCloudlog = false,
    this.cloudlogAddress = '',
    this.cloudlogApiKey = '',
    this.cloudlogStationId = '',
    this.enableQrz = false,
    this.qrzApiKey = '',
    this.excludedCallsigns = '',
    this.volumePercent = 0.5,
    this.rigName = '',
    this.icomIp = '255.255.255.255',
    this.icomPort = 50001,
    this.icomUser = 'ic705',
    this.icomPassword = '',
  });

  final String myCallsign;
  final String myMaidenGrid;
  final String toModifier;
  final int transmitFrequencyHz;
  final int transmitDelay;
  final int launchSupervisionMs;
  final int noReplyLimit;
  final int connectMode;
  final int controlMode;
  final int instructionSet;
  final int civAddress;
  final int baudRate;
  final int serialDataBits;
  final int serialParity;
  final int serialStopBits;
  final int pttDelay;
  final int bandHz;
  final bool synFrequency;
  final bool deepDecode;
  final bool saveSWLMessages;
  final bool enableCloudlog;
  final String cloudlogAddress;
  final String cloudlogApiKey;
  final String cloudlogStationId;
  final bool enableQrz;
  final String qrzApiKey;
  final String excludedCallsigns;
  final double volumePercent;
  final String rigName;
  final String icomIp;
  final int icomPort;
  final String icomUser;
  final String icomPassword;

  AppConfig copyWith({
    String? myCallsign,
    String? myMaidenGrid,
    String? toModifier,
    int? transmitFrequencyHz,
    int? transmitDelay,
    int? launchSupervisionMs,
    int? noReplyLimit,
    int? connectMode,
    int? controlMode,
    int? instructionSet,
    int? civAddress,
    int? baudRate,
    int? serialDataBits,
    int? serialParity,
    int? serialStopBits,
    int? pttDelay,
    int? bandHz,
    bool? synFrequency,
    bool? deepDecode,
    bool? saveSWLMessages,
    bool? enableCloudlog,
    String? cloudlogAddress,
    String? cloudlogApiKey,
    String? cloudlogStationId,
    bool? enableQrz,
    String? qrzApiKey,
    String? excludedCallsigns,
    double? volumePercent,
    String? rigName,
    String? icomIp,
    int? icomPort,
    String? icomUser,
    String? icomPassword,
  }) {
    return AppConfig(
      myCallsign: myCallsign ?? this.myCallsign,
      myMaidenGrid: myMaidenGrid ?? this.myMaidenGrid,
      toModifier: toModifier ?? this.toModifier,
      transmitFrequencyHz: transmitFrequencyHz ?? this.transmitFrequencyHz,
      transmitDelay: transmitDelay ?? this.transmitDelay,
      launchSupervisionMs: launchSupervisionMs ?? this.launchSupervisionMs,
      noReplyLimit: noReplyLimit ?? this.noReplyLimit,
      connectMode: connectMode ?? this.connectMode,
      controlMode: controlMode ?? this.controlMode,
      instructionSet: instructionSet ?? this.instructionSet,
      civAddress: civAddress ?? this.civAddress,
      baudRate: baudRate ?? this.baudRate,
      serialDataBits: serialDataBits ?? this.serialDataBits,
      serialParity: serialParity ?? this.serialParity,
      serialStopBits: serialStopBits ?? this.serialStopBits,
      pttDelay: pttDelay ?? this.pttDelay,
      bandHz: bandHz ?? this.bandHz,
      synFrequency: synFrequency ?? this.synFrequency,
      deepDecode: deepDecode ?? this.deepDecode,
      saveSWLMessages: saveSWLMessages ?? this.saveSWLMessages,
      enableCloudlog: enableCloudlog ?? this.enableCloudlog,
      cloudlogAddress: cloudlogAddress ?? this.cloudlogAddress,
      cloudlogApiKey: cloudlogApiKey ?? this.cloudlogApiKey,
      cloudlogStationId: cloudlogStationId ?? this.cloudlogStationId,
      enableQrz: enableQrz ?? this.enableQrz,
      qrzApiKey: qrzApiKey ?? this.qrzApiKey,
      excludedCallsigns: excludedCallsigns ?? this.excludedCallsigns,
      volumePercent: volumePercent ?? this.volumePercent,
      rigName: rigName ?? this.rigName,
      icomIp: icomIp ?? this.icomIp,
      icomPort: icomPort ?? this.icomPort,
      icomUser: icomUser ?? this.icomUser,
      icomPassword: icomPassword ?? this.icomPassword,
    );
  }

  factory AppConfig.fromMap(Map<Object?, Object?> map) {
    return AppConfig(
      myCallsign: (map['myCallsign'] as String?) ?? '',
      myMaidenGrid: (map['myMaidenGrid'] as String?) ?? '',
      toModifier: (map['toModifier'] as String?) ?? '',
      transmitFrequencyHz:
          (map['transmitFrequencyHz'] as num?)?.toInt() ?? 1500,
      transmitDelay: (map['transmitDelay'] as num?)?.toInt() ?? 500,
      launchSupervisionMs:
          (map['launchSupervisionMs'] as num?)?.toInt() ?? 600000,
      noReplyLimit: (map['noReplyLimit'] as num?)?.toInt() ?? 0,
      connectMode: (map['connectMode'] as num?)?.toInt() ?? 0,
      controlMode: (map['controlMode'] as num?)?.toInt() ?? 0,
      instructionSet: (map['instructionSet'] as num?)?.toInt() ?? 0,
      civAddress: (map['civAddress'] as num?)?.toInt() ?? 0xA4,
      baudRate: (map['baudRate'] as num?)?.toInt() ?? 19200,
      serialDataBits: (map['serialDataBits'] as num?)?.toInt() ?? 8,
      serialParity: (map['serialParity'] as num?)?.toInt() ?? 0,
      serialStopBits: (map['serialStopBits'] as num?)?.toInt() ?? 1,
      pttDelay: (map['pttDelay'] as num?)?.toInt() ?? 100,
      bandHz: (map['bandHz'] as num?)?.toInt() ?? 14074000,
      synFrequency: (map['synFrequency'] as bool?) ?? true,
      deepDecode: (map['deepDecode'] as bool?) ?? false,
      saveSWLMessages: (map['saveSWLMessages'] as bool?) ?? false,
      enableCloudlog: (map['enableCloudlog'] as bool?) ?? false,
      cloudlogAddress: (map['cloudlogAddress'] as String?) ?? '',
      cloudlogApiKey: (map['cloudlogApiKey'] as String?) ?? '',
      cloudlogStationId: (map['cloudlogStationId'] as String?) ?? '',
      enableQrz: (map['enableQrz'] as bool?) ?? false,
      qrzApiKey: (map['qrzApiKey'] as String?) ?? '',
      excludedCallsigns: (map['excludedCallsigns'] as String?) ?? '',
      volumePercent: (map['volumePercent'] as num?)?.toDouble() ?? 0.5,
      rigName: (map['rigName'] as String?) ?? '',
      icomIp: (map['icomIp'] as String?) ?? '255.255.255.255',
      icomPort: (map['icomPort'] as num?)?.toInt() ?? 50001,
      icomUser: (map['icomUser'] as String?) ?? 'ic705',
      icomPassword: (map['icomPassword'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'myCallsign': myCallsign,
        'myMaidenGrid': myMaidenGrid,
        'toModifier': toModifier,
        'transmitFrequencyHz': transmitFrequencyHz,
        'transmitDelay': transmitDelay,
        'launchSupervisionMs': launchSupervisionMs,
        'noReplyLimit': noReplyLimit,
        'connectMode': connectMode,
        'controlMode': controlMode,
        'instructionSet': instructionSet,
        'civAddress': civAddress,
        'baudRate': baudRate,
        'serialDataBits': serialDataBits,
        'serialParity': serialParity,
        'serialStopBits': serialStopBits,
        'pttDelay': pttDelay,
        'bandHz': bandHz,
        'synFrequency': synFrequency,
        'deepDecode': deepDecode,
        'saveSWLMessages': saveSWLMessages,
        'enableCloudlog': enableCloudlog,
        'cloudlogAddress': cloudlogAddress,
        'cloudlogApiKey': cloudlogApiKey,
        'cloudlogStationId': cloudlogStationId,
        'enableQrz': enableQrz,
        'qrzApiKey': qrzApiKey,
        'excludedCallsigns': excludedCallsigns,
        'volumePercent': volumePercent,
        'rigName': rigName,
        'icomIp': icomIp,
        'icomPort': icomPort,
        'icomUser': icomUser,
        'icomPassword': icomPassword,
      };
}

// ---------------------------------------------------------------------------
// Console snapshot – aggregates all real-time state
// ---------------------------------------------------------------------------

class ConsoleSnapshot {
  const ConsoleSnapshot({
    required this.rigState,
    required this.timerState,
    required this.messages,
    this.config = const AppConfig(),
    this.transmitFunctions = const [],
    this.decodedCount = 0,
  });

  final RigState rigState;
  final TimerState timerState;
  final List<DecodeMessage> messages;
  final AppConfig config;
  final List<TransmitFunction> transmitFunctions;
  final int decodedCount;

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
