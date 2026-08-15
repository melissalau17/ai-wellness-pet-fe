class Pet {
  final String id;
  final String userId;
  final String petName;
  final int healthScore;
  final int energyScore;
  final String currentState; // "Happy" | "Neutral" | "Tired" | "Sad"
  final DateTime? updatedAt;

  Pet({
    required this.id,
    required this.userId,
    required this.petName,
    required this.healthScore,
    required this.energyScore,
    required this.currentState,
    this.updatedAt,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      petName: json['pet_name'] as String? ?? 'Milo',
      healthScore: (json['health_score'] as num?)?.toInt() ?? 50,
      energyScore: (json['energy_score'] as num?)?.toInt() ?? 50,
      currentState: json['current_state'] as String? ?? 'Neutral',
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Default pet used before the first successful API call.
  factory Pet.placeholder({String userId = '', String petName = 'Milo'}) {
    return Pet(
      id: '',
      userId: userId,
      petName: petName,
      healthScore: 50,
      energyScore: 50,
      currentState: 'Neutral',
    );
  }
}
