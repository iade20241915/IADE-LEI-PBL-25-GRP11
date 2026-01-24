/// Modelo de dados para Humor
/// Alinhado com as tabelas `mood` e `mood_types` da base de dados
/// 
/// Tabela mood_types:
/// - mood_type_id (SERIAL PRIMARY KEY)
/// - mood (VARCHAR(45) NOT NULL)
/// 
/// Tabela mood:
/// - mood_id (SERIAL PRIMARY KEY)
/// - user_id (INT NOT NULL, FK -> users)
/// - mood_type_id (INT NOT NULL, FK -> mood_types)
/// - created_at (TIMESTAMPTZ NOT NULL DEFAULT now())
/// - intensity (INT) - 1 a 5
/// - notes (VARCHAR(300))

/// Tipos de humor predefinidos
enum MoodLevel { veryBad, bad, neutral, good, veryGood }

extension MoodLevelExtension on MoodLevel {
  int get value {
    switch (this) {
      case MoodLevel.veryBad:
        return 1;
      case MoodLevel.bad:
        return 2;
      case MoodLevel.neutral:
        return 3;
      case MoodLevel.good:
        return 4;
      case MoodLevel.veryGood:
        return 5;
    }
  }

  String get label {
    switch (this) {
      case MoodLevel.veryBad:
        return 'Muito Mau';
      case MoodLevel.bad:
        return 'Mau';
      case MoodLevel.neutral:
        return 'Normal';
      case MoodLevel.good:
        return 'Bom';
      case MoodLevel.veryGood:
        return 'Muito Bom';
    }
  }

  String get emoji {
    switch (this) {
      case MoodLevel.veryBad:
        return '😢';
      case MoodLevel.bad:
        return '😔';
      case MoodLevel.neutral:
        return '😐';
      case MoodLevel.good:
        return '😊';
      case MoodLevel.veryGood:
        return '😄';
    }
  }

  static MoodLevel fromValue(int value) {
    switch (value) {
      case 1:
        return MoodLevel.veryBad;
      case 2:
        return MoodLevel.bad;
      case 3:
        return MoodLevel.neutral;
      case 4:
        return MoodLevel.good;
      case 5:
        return MoodLevel.veryGood;
      default:
        return MoodLevel.neutral;
    }
  }
}

/// Modelo para tipo de humor (tabela mood_types)
class MoodTypeModel {
  final int? moodTypeId;
  final String mood;

  MoodTypeModel({
    this.moodTypeId,
    required this.mood,
  });

  factory MoodTypeModel.fromJson(Map<String, dynamic> json) {
    return MoodTypeModel(
      moodTypeId: json['mood_type_id'] as int?,
      mood: json['mood'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (moodTypeId != null) 'mood_type_id': moodTypeId,
      'mood': mood,
    };
  }
}

/// Modelo para registo de humor
class MoodModel {
  final int? moodId;
  final int userId;
  final int moodTypeId;
  final DateTime createdAt;
  final int? intensity; // 1-5
  final String? notes;
  final MoodTypeModel? moodType; // Populated via JOIN

  // Campos adicionais para detalhes do dia (podem ser JSON ou tabelas separadas)
  final String? sleepQuality;
  final List<String> emotions;
  final List<String> healthFactors;
  final List<String> foodFactors;
  final List<String> weatherFactors;

  MoodModel({
    this.moodId,
    required this.userId,
    required this.moodTypeId,
    DateTime? createdAt,
    this.intensity,
    this.notes,
    this.moodType,
    this.sleepQuality,
    this.emotions = const [],
    this.healthFactors = const [],
    this.foodFactors = const [],
    this.weatherFactors = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  factory MoodModel.fromJson(Map<String, dynamic> json) {
    return MoodModel(
      moodId: json['mood_id'] as int?,
      userId: json['user_id'] as int,
      moodTypeId: json['mood_type_id'] as int,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      intensity: json['intensity'] as int?,
      notes: json['notes'] as String?,
      moodType: json['mood_type'] != null
          ? MoodTypeModel.fromJson(json['mood_type'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (moodId != null) 'mood_id': moodId,
      'user_id': userId,
      'mood_type_id': moodTypeId,
      'created_at': createdAt.toIso8601String(),
      if (intensity != null) 'intensity': intensity,
      if (notes != null) 'notes': notes,
    };
  }

  MoodModel copyWith({
    int? moodId,
    int? userId,
    int? moodTypeId,
    DateTime? createdAt,
    int? intensity,
    String? notes,
    MoodTypeModel? moodType,
    String? sleepQuality,
    List<String>? emotions,
    List<String>? healthFactors,
    List<String>? foodFactors,
    List<String>? weatherFactors,
  }) {
    return MoodModel(
      moodId: moodId ?? this.moodId,
      userId: userId ?? this.userId,
      moodTypeId: moodTypeId ?? this.moodTypeId,
      createdAt: createdAt ?? this.createdAt,
      intensity: intensity ?? this.intensity,
      notes: notes ?? this.notes,
      moodType: moodType ?? this.moodType,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      emotions: emotions ?? this.emotions,
      healthFactors: healthFactors ?? this.healthFactors,
      foodFactors: foodFactors ?? this.foodFactors,
      weatherFactors: weatherFactors ?? this.weatherFactors,
    );
  }

  /// Nível de humor baseado no intensity
  MoodLevel get level => MoodLevelExtension.fromValue(intensity ?? 3);

  /// Data sem horas
  DateTime get date => DateTime(createdAt.year, createdAt.month, createdAt.day);

  @override
  String toString() => 'MoodModel(id: $moodId, level: ${level.label}, intensity: $intensity)';
}
