// frontend/lib/models/evenement.dart

class Evenement {
  final int? id;
  final String titre;
  final String description;
  final String date;
  final String typeEvent;
  final bool estPublic;

  Evenement({
    this.id,
    required this.titre,
    required this.description,
    required this.date,
    required this.typeEvent,
    this.estPublic = false,
  });

  factory Evenement.fromJson(Map<String, dynamic> json) {
    return Evenement(
      id: json['id'],
      titre: json['titre'],
      description: json['description'] ?? '',
      date: json['date'],
      typeEvent: json['type_event'] ?? 'personnel',
      estPublic: json['est_public'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'titre': titre,
    'description': description,
    'date': date,
    'type_event': typeEvent,
    'est_public': estPublic,
  };
}
