/// Radio frequency band definition.
///
/// See: ft8cn/.../database/OperationBand.java
class OperationBand {
  const OperationBand({
    required this.frequencyHz,
    required this.wavelength,
    this.isMarked = false,
  });

  final int frequencyHz;
  final String wavelength;
  final bool isMarked;

  double get frequencyMhz => frequencyHz / 1e6;

  String get label =>
      '${isMarked ? "★ " : ""}${frequencyMhz.toStringAsFixed(3)} MHz ($wavelength)';

  factory OperationBand.fromMap(Map<Object?, Object?> map) {
    return OperationBand(
      frequencyHz: (map['frequencyHz'] as num?)?.toInt() ?? 14074000,
      wavelength: (map['wavelength'] as String?) ?? '20m',
      isMarked: (map['isMarked'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'frequencyHz': frequencyHz,
        'wavelength': wavelength,
        'isMarked': isMarked,
      };

  /// Default bands commonly used for FT8/FT4.
  static const List<OperationBand> defaults = [
    OperationBand(frequencyHz: 1840000, wavelength: '160m'),
    OperationBand(frequencyHz: 3573000, wavelength: '80m'),
    OperationBand(frequencyHz: 5357000, wavelength: '60m'),
    OperationBand(frequencyHz: 7074000, wavelength: '40m', isMarked: true),
    OperationBand(frequencyHz: 10136000, wavelength: '30m'),
    OperationBand(frequencyHz: 14074000, wavelength: '20m', isMarked: true),
    OperationBand(frequencyHz: 18100000, wavelength: '17m'),
    OperationBand(frequencyHz: 21074000, wavelength: '15m', isMarked: true),
    OperationBand(frequencyHz: 24915000, wavelength: '12m'),
    OperationBand(frequencyHz: 28074000, wavelength: '10m', isMarked: true),
    OperationBand(frequencyHz: 50313000, wavelength: '6m'),
    OperationBand(frequencyHz: 144174000, wavelength: '2m'),
  ];
}
