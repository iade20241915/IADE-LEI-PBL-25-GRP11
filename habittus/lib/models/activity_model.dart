/// Modelo de dados para Atividade Física
/// Alinhado com as tabelas `activity`, `activity_types`, `activity_category`, `activity_track_points`
/// 
/// Tabela activity_types:
/// - activity_type_id (SERIAL PRIMARY KEY)
/// - activity_type (VARCHAR(45) NOT NULL)
/// - activity_type_group (VARCHAR(45))
/// - kcal (INT) - calorias por hora
/// - icon (VARCHAR(45))
/// - color (VARCHAR(45))
/// 
/// Tabela activity_category:
/// - activity_category_id (SERIAL PRIMARY KEY)
/// - name (VARCHAR(45) NOT NULL)
/// - icon (VARCHAR(45))
/// - color (VARCHAR(45))
/// - activity_type_id (INT, FK -> activity_types)
/// 
/// Tabela activity:
/// - activity_id (SERIAL PRIMARY KEY)
/// - user_id (INT NOT NULL, FK -> users)
/// - activity_type_id (INT NOT NULL, FK -> activity_types)
/// - duration_min (INT)
/// - steps (INT)
/// - kcal (INT)
/// - created_at (TIMESTAMPTZ NOT NULL DEFAULT now())
/// 
/// Tabela activity_track_points:
/// - activity_id (INT NOT NULL, PK)
/// - seq (INT NOT NULL, PK)
/// - lat (NUMERIC(10,7))
/// - lng (NUMERIC(10,7))
/// - altitude_m (NUMERIC(10,2))
/// - recorded_at (TIMESTAMPTZ NOT NULL DEFAULT now())

/// Modelo para tipo de atividade
class ActivityTypeModel {
  final int? activityTypeId;
  final String activityType;
  final String? activityTypeGroup;
  final int? kcalPerHour;
  final String? icon;
  final String? color;

  ActivityTypeModel({
    this.activityTypeId,
    required this.activityType,
    this.activityTypeGroup,
    this.kcalPerHour,
    this.icon,
    this.color,
  });

  factory ActivityTypeModel.fromJson(Map<String, dynamic> json) {
    return ActivityTypeModel(
      activityTypeId: json['activity_type_id'] as int?,
      activityType: json['activity_type'] as String,
      activityTypeGroup: json['activity_type_group'] as String?,
      kcalPerHour: json['kcal'] as int?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (activityTypeId != null) 'activity_type_id': activityTypeId,
      'activity_type': activityType,
      if (activityTypeGroup != null) 'activity_type_group': activityTypeGroup,
      if (kcalPerHour != null) 'kcal': kcalPerHour,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
    };
  }

  /// Calcula calorias para uma duração em minutos
  int kcalForDuration(int minutes) {
    if (kcalPerHour == null) return 0;
    return ((kcalPerHour! * minutes) / 60).round();
  }

  @override
  String toString() => 'ActivityTypeModel(id: $activityTypeId, type: $activityType)';
}

/// Modelo para categoria de atividade
class ActivityCategoryModel {
  final int? activityCategoryId;
  final String name;
  final String? icon;
  final String? color;
  final int? activityTypeId;
  final ActivityTypeModel? activityType;

  ActivityCategoryModel({
    this.activityCategoryId,
    required this.name,
    this.icon,
    this.color,
    this.activityTypeId,
    this.activityType,
  });

  factory ActivityCategoryModel.fromJson(Map<String, dynamic> json) {
    return ActivityCategoryModel(
      activityCategoryId: json['activity_category_id'] as int?,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      activityTypeId: json['activity_type_id'] as int?,
      activityType: json['activity_type'] != null
          ? ActivityTypeModel.fromJson(json['activity_type'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (activityCategoryId != null) 'activity_category_id': activityCategoryId,
      'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (activityTypeId != null) 'activity_type_id': activityTypeId,
    };
  }
}

/// Modelo para ponto de tracking GPS
class ActivityTrackPointModel {
  final int activityId;
  final int seq;
  final double? lat;
  final double? lng;
  final double? altitudeM;
  final DateTime recordedAt;

  ActivityTrackPointModel({
    required this.activityId,
    required this.seq,
    this.lat,
    this.lng,
    this.altitudeM,
    DateTime? recordedAt,
  }) : recordedAt = recordedAt ?? DateTime.now();

  factory ActivityTrackPointModel.fromJson(Map<String, dynamic> json) {
    return ActivityTrackPointModel(
      activityId: json['activity_id'] as int,
      seq: json['seq'] as int,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      altitudeM: (json['altitude_m'] as num?)?.toDouble(),
      recordedAt: json['recorded_at'] != null
          ? DateTime.parse(json['recorded_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_id': activityId,
      'seq': seq,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (altitudeM != null) 'altitude_m': altitudeM,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }

  /// Verifica se tem coordenadas válidas
  bool get hasLocation => lat != null && lng != null;
}

/// Modelo para atividade física
class ActivityModel {
  final int? activityId;
  final int userId;
  final int activityTypeId;
  final int? durationMin;
  final int? steps;
  final int? kcal;
  final DateTime createdAt;
  final ActivityTypeModel? activityType;
  final List<ActivityTrackPointModel> trackPoints;

  // Campos adicionais para UI
  final double? distanceKm;
  final String? notes;

  ActivityModel({
    this.activityId,
    required this.userId,
    required this.activityTypeId,
    this.durationMin,
    this.steps,
    this.kcal,
    DateTime? createdAt,
    this.activityType,
    this.trackPoints = const [],
    this.distanceKm,
    this.notes,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      activityId: json['activity_id'] as int?,
      userId: json['user_id'] as int,
      activityTypeId: json['activity_type_id'] as int,
      durationMin: json['duration_min'] as int?,
      steps: json['steps'] as int?,
      kcal: json['kcal'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      activityType: json['activity_type'] != null
          ? ActivityTypeModel.fromJson(json['activity_type'] as Map<String, dynamic>)
          : null,
      trackPoints: (json['track_points'] as List<dynamic>?)
              ?.map((e) => ActivityTrackPointModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (activityId != null) 'activity_id': activityId,
      'user_id': userId,
      'activity_type_id': activityTypeId,
      if (durationMin != null) 'duration_min': durationMin,
      if (steps != null) 'steps': steps,
      if (kcal != null) 'kcal': kcal,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ActivityModel copyWith({
    int? activityId,
    int? userId,
    int? activityTypeId,
    int? durationMin,
    int? steps,
    int? kcal,
    DateTime? createdAt,
    ActivityTypeModel? activityType,
    List<ActivityTrackPointModel>? trackPoints,
    double? distanceKm,
    String? notes,
  }) {
    return ActivityModel(
      activityId: activityId ?? this.activityId,
      userId: userId ?? this.userId,
      activityTypeId: activityTypeId ?? this.activityTypeId,
      durationMin: durationMin ?? this.durationMin,
      steps: steps ?? this.steps,
      kcal: kcal ?? this.kcal,
      createdAt: createdAt ?? this.createdAt,
      activityType: activityType ?? this.activityType,
      trackPoints: trackPoints ?? this.trackPoints,
      distanceKm: distanceKm ?? this.distanceKm,
      notes: notes ?? this.notes,
    );
  }

  /// Nome da atividade
  String get name => activityType?.activityType ?? 'Atividade';

  /// Duração formatada
  String get durationFormatted {
    if (durationMin == null) return '--';
    final hours = durationMin! ~/ 60;
    final mins = durationMin! % 60;
    if (hours > 0) {
      return '${hours}h ${mins}min';
    }
    return '${mins}min';
  }

  /// Data sem horas
  DateTime get date => DateTime(createdAt.year, createdAt.month, createdAt.day);

  /// Tem tracking GPS?
  bool get hasTracking => trackPoints.isNotEmpty;

  @override
  String toString() => 'ActivityModel(id: $activityId, type: $name, duration: $durationFormatted)';
}

/// Resumo semanal de atividades
class ActivityWeeklySummary {
  final DateTime weekStart;
  final List<ActivityModel> activities;

  ActivityWeeklySummary({
    required this.weekStart,
    this.activities = const [],
  });

  int get totalMinutes => activities.fold(0, (sum, a) => sum + (a.durationMin ?? 0));

  int get totalKcal => activities.fold(0, (sum, a) => sum + (a.kcal ?? 0));

  int get totalSteps => activities.fold(0, (sum, a) => sum + (a.steps ?? 0));

  int get activeDays {
    final days = <DateTime>{};
    for (final a in activities) {
      days.add(a.date);
    }
    return days.length;
  }

  double get averageMinutesPerDay => activities.isEmpty ? 0 : totalMinutes / 7;
}
