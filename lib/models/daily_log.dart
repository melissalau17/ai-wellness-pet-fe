class DailyLog {
  final String id;
  final String userId;
  final int waterGlasses;
  final double sleepHours;
  final String journalText;
  final DateTime createdAt;

  DailyLog({
    required this.id,
    required this.userId,
    required this.waterGlasses,
    required this.sleepHours,
    required this.journalText,
    required this.createdAt,
  });

  factory DailyLog.fromJson(Map<String, dynamic> json) {
    return DailyLog(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      waterGlasses: (json['water_glasses'] as num?)?.toInt() ?? 0,
      sleepHours: (json['sleep_hours'] as num?)?.toDouble() ?? 0.0,
      journalText: json['journal_text'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  String get displayMood {
    final hydrated = waterGlasses >= 4;
    final rested = sleepHours >= 7.0;
    final journaled = journalText.trim().isNotEmpty;
    if (hydrated && rested) return 'Happy';
    if (!rested && !hydrated) return 'Tired';
    if (journaled) return 'Calm';
    return 'Calm';
  }
}
