/// Modelo de dados para Consumo de Água
/// Alinhado com a tabela `water_intake` da base de dados
/// 
/// Campos da BD:
/// - water_intake_id (SERIAL PRIMARY KEY)
/// - intake_at (TIMESTAMPTZ NOT NULL DEFAULT now())
/// - amount_ml (INT NOT NULL DEFAULT 0)
/// - source (water_source_enum: 'manual', 'bottle')
/// - user_id (INT NOT NULL)

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

  static WaterSource fromString(String? value) {
    switch (value) {
      case 'bottle':
        return WaterSource.bottle;
      default:
        return WaterSource.manual;
    }
  }
}

class WaterLog {
  final int? id;
  final DateTime date;
  final int amountMl;
  final WaterSource source;
  final int? userId;

  // Para compatibilidade com código existente
  final int mlPerCup;
  final int cups;

  const WaterLog({
    this.id,
    required this.date,
    this.amountMl = 0,
    this.source = WaterSource.manual,
    this.userId,
    this.mlPerCup = 250,
    this.cups = 0,
  });

  int get totalMl => amountMl > 0 ? amountMl : (mlPerCup * cups);

  /// Cria WaterLog a partir de JSON (da BD)
  factory WaterLog.fromJson(Map<String, dynamic> json) {
    final amount = json['amount_ml'] as int? ?? 0;
    return WaterLog(
      id: json['water_intake_id'] as int?,
      date: json['intake_at'] != null
          ? DateTime.parse(json['intake_at'] as String)
          : DateTime.now(),
      amountMl: amount,
      source: WaterSourceExtension.fromString(json['source'] as String?),
      userId: json['user_id'] as int?,
      mlPerCup: 250,
      cups: amount ~/ 250,
    );
  }

  /// Converte para JSON (para BD)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'water_intake_id': id,
      'intake_at': date.toIso8601String(),
      'amount_ml': totalMl,
      'source': source.value,
      if (userId != null) 'user_id': userId,
    };
  }

  /// Cria cópia com campos alterados
  WaterLog copyWith({
    int? id,
    DateTime? date,
    int? amountMl,
    WaterSource? source,
    int? userId,
    int? mlPerCup,
    int? cups,
  }) {
    return WaterLog(
      id: id ?? this.id,
      date: date ?? this.date,
      amountMl: amountMl ?? this.amountMl,
      source: source ?? this.source,
      userId: userId ?? this.userId,
      mlPerCup: mlPerCup ?? this.mlPerCup,
      cups: cups ?? this.cups,
    );
  }
}
