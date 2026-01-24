/// Modelo de dados para Sessão de Sono
/// Alinhado com a tabela `sleep_session` da base de dados
/// 
/// Campos da BD:
/// - sleep_session_id (SERIAL PRIMARY KEY)
/// - start_time (TIMESTAMPTZ NOT NULL)
/// - end_time (TIMESTAMPTZ NOT NULL)
/// - quality_score (INT NOT NULL)
/// - user_id (INT NOT NULL, FK -> users)
/// - CONSTRAINT: end_time >= start_time

class SleepSessionModel {
  final int? sleepSessionId;
  final DateTime startTime;
  final DateTime endTime;
  final int qualityScore; // 1-5
  final int userId;

  SleepSessionModel({
    this.sleepSessionId,
    required this.startTime,
    required this.endTime,
    required this.qualityScore,
    required this.userId,
  }) : assert(endTime.isAfter(startTime) || endTime.isAtSameMomentAs(startTime),
            'end_time deve ser >= start_time');

  /// Cria SleepSessionModel a partir de JSON (da BD)
  factory SleepSessionModel.fromJson(Map<String, dynamic> json) {
    return SleepSessionModel(
      sleepSessionId: json['sleep_session_id'] as int?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      qualityScore: json['quality_score'] as int? ?? 3,
      userId: json['user_id'] as int,
    );
  }

  /// Cria a partir de duração (helper para UI)
  factory SleepSessionModel.fromDuration({
    required Duration duration,
    required int userId,
    int qualityScore = 3,
    DateTime? date,
  }) {
    final now = date ?? DateTime.now();
    // Assume que dormiu à meia-noite e acordou após a duração
    final startTime = DateTime(now.year, now.month, now.day, 0, 0);
    final endTime = startTime.add(duration);
    
    return SleepSessionModel(
      startTime: startTime,
      endTime: endTime,
      qualityScore: qualityScore,
      userId: userId,
    );
  }

  /// Converte para JSON (para BD)
  Map<String, dynamic> toJson() {
    return {
      if (sleepSessionId != null) 'sleep_session_id': sleepSessionId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'quality_score': qualityScore,
      'user_id': userId,
    };
  }

  /// Cria cópia com campos alterados
  SleepSessionModel copyWith({
    int? sleepSessionId,
    DateTime? startTime,
    DateTime? endTime,
    int? qualityScore,
    int? userId,
  }) {
    return SleepSessionModel(
      sleepSessionId: sleepSessionId ?? this.sleepSessionId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      qualityScore: qualityScore ?? this.qualityScore,
      userId: userId ?? this.userId,
    );
  }

  /// Duração do sono
  Duration get duration => endTime.difference(startTime);

  /// Duração em horas (double)
  double get durationHours => duration.inMinutes / 60.0;

  /// Duração formatada (ex: "7h 30min")
  String get durationFormatted {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}min';
  }

  /// Qualidade do sono em texto
  String get qualityLabel {
    switch (qualityScore) {
      case 1:
        return 'Muito má';
      case 2:
        return 'Má';
      case 3:
        return 'Razoável';
      case 4:
        return 'Boa';
      case 5:
        return 'Excelente';
      default:
        return 'N/A';
    }
  }

  /// Emoji da qualidade
  String get qualityEmoji {
    switch (qualityScore) {
      case 1:
        return '😫';
      case 2:
        return '😔';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '😴';
      default:
        return '❓';
    }
  }

  /// Data do registo (sem horas)
  DateTime get date => DateTime(startTime.year, startTime.month, startTime.day);

  @override
  String toString() => 'SleepSessionModel(id: $sleepSessionId, duration: $durationFormatted, quality: $qualityLabel)';
}

/// Modelo agregado para resumo semanal de sono
class SleepWeeklySummary {
  final List<SleepSessionModel> sessions;
  final DateTime weekStart;

  SleepWeeklySummary({
    required this.sessions,
    required this.weekStart,
  });

  /// Média de horas de sono na semana
  double get averageHours {
    if (sessions.isEmpty) return 0;
    final total = sessions.fold<double>(0, (sum, s) => sum + s.durationHours);
    return total / sessions.length;
  }

  /// Média de qualidade na semana
  double get averageQuality {
    if (sessions.isEmpty) return 0;
    final total = sessions.fold<int>(0, (sum, s) => sum + s.qualityScore);
    return total / sessions.length;
  }

  /// Total de horas dormidas na semana
  double get totalHours {
    return sessions.fold<double>(0, (sum, s) => sum + s.durationHours);
  }
}
