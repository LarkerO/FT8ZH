/// FT8/FT4 protocol constants mirrored from the original FT8CN project.
///
/// See: ft8cn/.../FT8Common.java
class Ft8Constants {
  Ft8Constants._();

  /// Mode identifiers.
  static const int ft8Mode = 0;
  static const int ft4Mode = 1;

  /// Audio sample rate used by the decoder (Hz).
  static const int sampleRate = 12000;

  /// FT8 time-slot length.
  static const int ft8SlotTimeSeconds = 15;
  static const int ft8SlotTimeMs = 15000;

  /// FT4 time-slot length.
  static const int ft4SlotTimeMs = 7500;

  /// 5-symbol duration for FT8 (ms).
  static const int ft8FiveSymbolsMs = 800;

  /// Default transmission delay (ms).
  static const int defaultTransmitDelay = 500;

  /// Deep decode timeout (ms).
  static const int deepDecodeTimeout = 7000;

  /// Max decode iterations per slot.
  static const int decodeMaxIterations = 1;

  /// Default frequency for 20m FT8 band (Hz).
  static const int defaultBandHz = 14074000;

  /// Maximum cached messages.
  static const int maxMessageCount = 3000;

  /// Connect modes.
  static const int connectModeUsb = 0;
  static const int connectModeBluetooth = 1;
  static const int connectModeWifi = 2;
  static const int connectModeFlexNetwork = 3;

  /// Control modes.
  static const int controlModeVox = 0;
  static const int controlModePtt = 1;

  /// Instruction sets (rig protocol families).
  static const int instructionSetIcom = 0;
  static const int instructionSetYaesu2 = 1;
  static const int instructionSetYaesu3 = 2;
  static const int instructionSetElecraft = 3;
  static const int instructionSetKenwood = 4;
  static const int instructionSetXiegu = 5;
  static const int instructionSetFlexRadio = 6;

  /// Mode name helper.
  static String modeName(int mode) =>
      mode == ft4Mode ? 'FT4' : 'FT8';
}
