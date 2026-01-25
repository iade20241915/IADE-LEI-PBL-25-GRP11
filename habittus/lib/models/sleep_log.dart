/// Modelo de dados para Sessão de Sono
/// Alinhado com a tabela `sleep_session` da base de dados
/// 
/// Campos da BD:
/// - sleep_session_id (SERIAL PRIMARY KEY)
/// - sleep_date (TIMESTAMPTZ NOT NULL DEFAULT now())
/// - start_time (TIMESTAMPTZ NOT NULL)
/// - end_time (TIMESTAMPTZ NOT NULL)
/// - duration_minutes (INT NOT NULL)
/// - quality_score (INT NOT NULL)
/// - user_id (INT NOT NULL)

class SleepLog {
  final int? id;
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final int quality;
  final int? userId;

  const SleepLog({
    this.id,
    required this.date,
    this.startTime,
    this.endTime,
    required this.durationMinutes,
    this.quality = 3,
    this.userId,
  });

  Duration get sleepDuration => Duration(minutes: durationMinutes);
  int get minutes => durationMinutes;
  
  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    return '${hours}h${mins > 0 ? '${mins.toString().padLeft(2, '0')}' : ''}';
  }

  /// Cria SleepLog a partir de JSON (da BD)
  factory SleepLog.fromJson(Map<String, dynamic> json) {
    return SleepLog(
      id: json['sleep_session_id'] as int?,
      date: json['sleep_date'] != null
          ? DateTime.parse(json['sleep_date'] as String)
          : DateTime.now(),
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'] as String)
          : null,
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      quality: json['quality_score'] as int? ?? 3,
      userId: json['user_id'] as int?,
    );
  }

  /// Converte para JSON (para BD)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'sleep_session_id': id,
      'sleep_date': date.toIso8601String(),
      if (startTime != null) 'start_time': startTime!.toIso8601String(),
      if (endTime != null) 'end_time': endTime!.toIso8601String(),
      'duration_minutes': durationMinutes,
      'quality_score': quality,
      if (userId != null) 'user_id': userId,
    };
  }

  /// Cria cópia com campos alterados
  SleepLog copyWith({
    int? id,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    int? quality,
    int? userId,
  }) {
    return SleepLog(
      id: id ?? this.id,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      quality: quality ?? this.quality,
      userId: userId ?? this.userId,
    );
  }

  /// Cria SleepLog a partir de hora de início e fim
  factory SleepLog.fromTimes({
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    int quality = 3,
    int? userId,
  }) {
    final duration = endTime.difference(startTime).inMinutes;
    return SleepLog(
      date: date,
      startTime: startTime,
      endTime: endTime,
      durationMinutes: duration > 0 ? duration : 0,
      quality: quality,
      userId: userId,
    );
  }
}
