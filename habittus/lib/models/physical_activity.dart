/// Modelo de dados para registro de atividade física
class PhysicalActivity {
  final String id;
  final String userId;
  final DateTime timestamp;
  final ActivityType activityType;
  final int durationMinutes;
  final ActivityIntensity intensity;
  final double? distanceKm;
  final int? caloriesBurned;
  final String? notes;

  PhysicalActivity({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.activityType,
    required this.durationMinutes,
    required this.intensity,
    this.distanceKm,
    this.caloriesBurned,
    this.notes,
  });

  /// Calcula calorias queimadas baseado em MET (Metabolic Equivalent of Task)
  /// Fórmula: Calorias = MET × peso(kg) × tempo(horas)
  int calculateCalories(double weightKg) {
    final hours = durationMinutes / 60.0;
    final met = activityType.getMET(intensity);
    return (met * weightKg * hours).round();
  }

  /// Cria uma cópia com valores atualizados
  PhysicalActivity copyWith({
    String? id,
    String? userId,
    DateTime? timestamp,
    ActivityType? activityType,
    int? durationMinutes,
    ActivityIntensity? intensity,
    double? distanceKm,
    int? caloriesBurned,
    String? notes,
  }) {
    return PhysicalActivity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      activityType: activityType ?? this.activityType,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      intensity: intensity ?? this.intensity,
      distanceKm: distanceKm ?? this.distanceKm,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      notes: notes ?? this.notes,
    );
  }

  /// Converte para Map (para Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'timestamp': timestamp.toIso8601String(),
      'activity_type': activityType.toString().split('.').last,
      'duration_minutes': durationMinutes,
      'intensity': intensity.toString().split('.').last,
      'distance_km': distanceKm,
      'calories_burned': caloriesBurned,
      'notes': notes,
    };
  }

  /// Cria a partir de Map (do Supabase)
  factory PhysicalActivity.fromJson(Map<String, dynamic> json) {
    return PhysicalActivity(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      activityType: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == json['activity_type'],
      ),
      durationMinutes: json['duration_minutes'] as int,
      intensity: ActivityIntensity.values.firstWhere(
        (e) => e.toString().split('.').last == json['intensity'],
      ),
      distanceKm: json['distance_km'] as double?,
      caloriesBurned: json['calories_burned'] as int?,
      notes: json['notes'] as String?,
    );
  }
}

/// Tipos de atividade física
enum ActivityType {
  running,
  walking,
  cycling,
  swimming,
  gym,
  yoga,
  dance,
  soccer,
  basketball,
  tennis,
  hiking,
  other,
}

extension ActivityTypeExtension on ActivityType {
  String get label {
    switch (this) {
      case ActivityType.running:
        return 'Corrida';
      case ActivityType.walking:
        return 'Caminhada';
      case ActivityType.cycling:
        return 'Ciclismo';
      case ActivityType.swimming:
        return 'Natação';
      case ActivityType.gym:
        return 'Ginásio';
      case ActivityType.yoga:
        return 'Yoga';
      case ActivityType.dance:
        return 'Dança';
      case ActivityType.soccer:
        return 'Futebol';
      case ActivityType.basketball:
        return 'Basquetebol';
      case ActivityType.tennis:
        return 'Ténis';
      case ActivityType.hiking:
        return 'Caminhada (Trilho)';
      case ActivityType.other:
        return 'Outro';
    }
  }

  String get icon {
    switch (this) {
      case ActivityType.running:
        return '🏃';
      case ActivityType.walking:
        return '🚶';
      case ActivityType.cycling:
        return '🚴';
      case ActivityType.swimming:
        return '🏊';
      case ActivityType.gym:
        return '💪';
      case ActivityType.yoga:
        return '🧘';
      case ActivityType.dance:
        return '💃';
      case ActivityType.soccer:
        return '⚽';
      case ActivityType.basketball:
        return '🏀';
      case ActivityType.tennis:
        return '🎾';
      case ActivityType.hiking:
        return '🥾';
      case ActivityType.other:
        return '🏃‍♂️';
    }
  }

  /// Retorna o valor MET (Metabolic Equivalent of Task) baseado na intensidade
  double getMET(ActivityIntensity intensity) {
    switch (this) {
      case ActivityType.running:
        return intensity == ActivityIntensity.low
            ? 6.0
            : intensity == ActivityIntensity.moderate
            ? 9.8
            : 12.8;
      case ActivityType.walking:
        return intensity == ActivityIntensity.low
            ? 2.5
            : intensity == ActivityIntensity.moderate
            ? 3.5
            : 5.0;
      case ActivityType.cycling:
        return intensity == ActivityIntensity.low
            ? 4.0
            : intensity == ActivityIntensity.moderate
            ? 8.0
            : 12.0;
      case ActivityType.swimming:
        return intensity == ActivityIntensity.low
            ? 5.8
            : intensity == ActivityIntensity.moderate
            ? 9.8
            : 13.8;
      case ActivityType.gym:
        return intensity == ActivityIntensity.low
            ? 3.0
            : intensity == ActivityIntensity.moderate
            ? 5.0
            : 8.0;
      case ActivityType.yoga:
        return 2.5;
      case ActivityType.dance:
        return intensity == ActivityIntensity.low
            ? 3.0
            : intensity == ActivityIntensity.moderate
            ? 5.0
            : 7.0;
      case ActivityType.soccer:
        return 10.0;
      case ActivityType.basketball:
        return 8.0;
      case ActivityType.tennis:
        return 7.3;
      case ActivityType.hiking:
        return intensity == ActivityIntensity.low
            ? 5.0
            : intensity == ActivityIntensity.moderate
            ? 7.0
            : 9.0;
      case ActivityType.other:
        return 5.0;
    }
  }
}

/// Intensidade da atividade física
enum ActivityIntensity { low, moderate, high }

extension ActivityIntensityExtension on ActivityIntensity {
  String get label {
    switch (this) {
      case ActivityIntensity.low:
        return 'Baixa';
      case ActivityIntensity.moderate:
        return 'Moderada';
      case ActivityIntensity.high:
        return 'Alta';
    }
  }

  String get emoji {
    switch (this) {
      case ActivityIntensity.low:
        return '😌';
      case ActivityIntensity.moderate:
        return '😅';
      case ActivityIntensity.high:
        return '🥵';
    }
  }
}
