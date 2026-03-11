// frontend/lib/models/date_conversion.dart

class DateConversion {
  final Map<String, dynamic> gregorien;
  final Map<String, dynamic> hijri;
  final Map<String, dynamic> wolof;

  DateConversion({
    required this.gregorien,
    required this.hijri,
    required this.wolof,
  });

  factory DateConversion.fromJson(Map<String, dynamic> json) => DateConversion(
    gregorien: json['gregorien'] ?? {},
    hijri: json['hijri'] ?? {},
    wolof: json['wolof'] ?? {},
  );

  String get dateGregorienne => gregorien['date'] ?? '--';
  String get dateHijri => hijri['texte'] ?? '--';
  String get nomJourWolof => wolof['nom'] ?? '--';
  String get infoWolof => wolof['info'] ?? '';
}
