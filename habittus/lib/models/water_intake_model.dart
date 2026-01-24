/// Modelo de dados para Consumo de Água
/// Alinhado com a tabela `water_intake` da base de dados
/// 
/// Campos da BD:
/// - water_intake_id (SERIAL PRIMARY KEY)
/// - intake_at (TIMESTAMPTZ NOT NULL DEFAULT now())
/// - amount_ml (INT NOT NULL DEFAULT 0)
/// - source (water_source_enum: 'manual', 'bottle')
/// - user_id (INT NOT NULL, FK -> users)

enum WaterSource { manual, bottle }

extension WaterSourceExtension on WaterSource {
  String get value {
    switch (this) {
      case WaterSource.manual:
        return 'manual';
      case WaterSource.bottle:
        return 'bottle';
    }
  }

  String get label {
    switch (this) {
      case WaterSource.manual:
        return 'Manual';
      case WaterSource.bottle:
        return 'Garrafa';
    }
  }

  static WaterSource fromValue(String value) {
    switch (value) {
      case 'bottle':
        return WaterSource.bottle;
      default:
        return WaterSource.manual;
    }
  }
}

class WaterIntakeModel {
  final int? waterIntakeId;
  final DateTime intakeAt;
  final int amountMl;
  final WaterSource source;
  final int userId;

  WaterIntakeModel({
    this.waterIntakeId,
    DateTime? intakeAt,
    required this.amountMl,
    this.source = WaterSource.manual,
    required this.userId,
  }) : intakeAt = intakeAt ?? DateTime.now();

  /// Cria WaterIntakeModel a partir de JSON (da BD)
  factory WaterIntakeModel.fromJson(Map<String, dynamic> json) {
    return WaterIntakeModel(
      waterIntakeId: json['water_intake_id'] as int?,
      intakeAt: json['intake_at'] != null
          ? DateTime.parse(json['intake_at'] as String)
          : DateTime.now(),
      amountMl: json['amount_ml'] as int? ?? 0,
      source: json['source'] != null
          ? WaterSourceExtension.fromValue(json['source'] as String)
          : WaterSource.manual,
      userId: json['user_id'] as int,
    );
  }

  /// Converte para JSON (para BD)
  Map<String, dynamic> toJson() {
    return {
      if (waterIntakeId != null) 'water_intake_id': waterIntakeId,
      'intake_at': intakeAt.toIso8601String(),
      'amount_ml': amountMl,
      'source': source.value,
      'user_id': userId,
    };
  }

  /// Cria cópia com campos alterados
  WaterIntakeModel copyWith({
    int? waterIntakeId,
    DateTime? intakeAt,
    int? amountMl,
    WaterSource? source,
    int? userId,
  }) {
    return WaterIntakeModel(
      waterIntakeId: waterIntakeId ?? this.waterIntakeId,
      intakeAt: intakeAt ?? this.intakeAt,
      amountMl: amountMl ?? this.amountMl,
      source: source ?? this.source,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() => 'WaterIntakeModel(id: $waterIntakeId, amount: ${amountMl}ml, source: ${source.label})';
}

/// Modelo agregado para resumo diário de água
class WaterDailySummary {
  final DateTime date;
  final int totalMl;
  final int goalMl;
  final List<WaterIntakeModel> intakes;

  WaterDailySummary({
    required this.date,
    required this.totalMl,
    this.goalMl = 2000,
    this.intakes = const [],
  });

  /// Progresso em percentagem (0.0 a 1.0)
  double get progress => (totalMl / goalMl).clamp(0.0, 1.0);

  /// Número de copos (250ml cada)
  int get cups => (totalMl / 250).round();

  /// Meta atingida?
  bool get goalReached => totalMl >= goalMl;
}
