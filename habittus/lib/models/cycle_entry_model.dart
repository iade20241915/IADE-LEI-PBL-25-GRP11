/// Modelo de dados para Ciclo Menstrual
/// Alinhado com a tabela `cycle_entry` da base de dados
/// 
/// Campos da BD:
/// - cycle_entry_id (SERIAL PRIMARY KEY)
/// - entry_date (DATE NOT NULL)
/// - user_id (INT NOT NULL, FK -> users)
/// - symptoms (VARCHAR(100))
/// - menstrual_flow (VARCHAR(50))
/// - birthcontrol_take (BOOLEAN NOT NULL DEFAULT false)
/// - ovulation (BOOLEAN NOT NULL DEFAULT false)
/// - sexual_activity (BOOLEAN NOT NULL DEFAULT false)
/// - cycle_interval (VARCHAR(45))

/// Fase do ciclo menstrual
enum CyclePhase { menstruation, follicular, ovulation, luteal }

extension CyclePhaseExtension on CyclePhase {
  String get label {
    switch (this) {
      case CyclePhase.menstruation:
        return 'Menstruação';
      case CyclePhase.follicular:
        return 'Folicular';
      case CyclePhase.ovulation:
        return 'Ovulação';
      case CyclePhase.luteal:
        return 'Lútea';
    }
  }

  String get description {
    switch (this) {
      case CyclePhase.menstruation:
        return 'Período menstrual';
      case CyclePhase.follicular:
        return 'Preparação para ovulação';
      case CyclePhase.ovulation:
        return 'Período fértil';
      case CyclePhase.luteal:
        return 'Pós-ovulação';
    }
  }

  String get color {
    switch (this) {
      case CyclePhase.menstruation:
        return '#E57373'; // Vermelho
      case CyclePhase.follicular:
        return '#64B5F6'; // Azul
      case CyclePhase.ovulation:
        return '#81C784'; // Verde
      case CyclePhase.luteal:
        return '#FFB74D'; // Laranja
    }
  }
}

/// Fluxo menstrual
enum MenstrualFlow { none, spotting, light, medium, heavy }

extension MenstrualFlowExtension on MenstrualFlow {
  String get value {
    switch (this) {
      case MenstrualFlow.none:
        return 'none';
      case MenstrualFlow.spotting:
        return 'spotting';
      case MenstrualFlow.light:
        return 'light';
      case MenstrualFlow.medium:
        return 'medium';
      case MenstrualFlow.heavy:
        return 'heavy';
    }
  }

  String get label {
    switch (this) {
      case MenstrualFlow.none:
        return 'Nenhum';
      case MenstrualFlow.spotting:
        return 'Spotting';
      case MenstrualFlow.light:
        return 'Leve';
      case MenstrualFlow.medium:
        return 'Moderado';
      case MenstrualFlow.heavy:
        return 'Intenso';
    }
  }

  String get emoji {
    switch (this) {
      case MenstrualFlow.none:
        return '⚪';
      case MenstrualFlow.spotting:
        return '🔴';
      case MenstrualFlow.light:
        return '🩸';
      case MenstrualFlow.medium:
        return '💧';
      case MenstrualFlow.heavy:
        return '🌊';
    }
  }

  static MenstrualFlow fromValue(String? value) {
    switch (value?.toLowerCase()) {
      case 'spotting':
        return MenstrualFlow.spotting;
      case 'light':
        return MenstrualFlow.light;
      case 'medium':
        return MenstrualFlow.medium;
      case 'heavy':
        return MenstrualFlow.heavy;
      default:
        return MenstrualFlow.none;
    }
  }
}

/// Sintomas do ciclo
enum CycleSymptom {
  cramps,
  headache,
  bloating,
  breastTenderness,
  acne,
  fatigue,
  moodSwings,
  backPain,
  nausea,
  cravings,
  insomnia,
  hotFlashes,
}

extension CycleSymptomExtension on CycleSymptom {
  String get value => name;

  String get label {
    switch (this) {
      case CycleSymptom.cramps:
        return 'Cólicas';
      case CycleSymptom.headache:
        return 'Dor de cabeça';
      case CycleSymptom.bloating:
        return 'Inchaço';
      case CycleSymptom.breastTenderness:
        return 'Seios sensíveis';
      case CycleSymptom.acne:
        return 'Acne';
      case CycleSymptom.fatigue:
        return 'Fadiga';
      case CycleSymptom.moodSwings:
        return 'Humor instável';
      case CycleSymptom.backPain:
        return 'Dor lombar';
      case CycleSymptom.nausea:
        return 'Náusea';
      case CycleSymptom.cravings:
        return 'Desejos';
      case CycleSymptom.insomnia:
        return 'Insónia';
      case CycleSymptom.hotFlashes:
        return 'Afrontamentos';
    }
  }

  String get emoji {
    switch (this) {
      case CycleSymptom.cramps:
        return '😣';
      case CycleSymptom.headache:
        return '🤕';
      case CycleSymptom.bloating:
        return '🎈';
      case CycleSymptom.breastTenderness:
        return '💔';
      case CycleSymptom.acne:
        return '😰';
      case CycleSymptom.fatigue:
        return '😴';
      case CycleSymptom.moodSwings:
        return '🎭';
      case CycleSymptom.backPain:
        return '🔙';
      case CycleSymptom.nausea:
        return '🤢';
      case CycleSymptom.cravings:
        return '🍫';
      case CycleSymptom.insomnia:
        return '😵';
      case CycleSymptom.hotFlashes:
        return '🥵';
    }
  }

  static CycleSymptom? fromValue(String value) {
    try {
      return CycleSymptom.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Modelo para entrada do ciclo menstrual
class CycleEntryModel {
  final int? cycleEntryId;
  final DateTime entryDate;
  final int userId;
  final List<CycleSymptom> symptoms;
  final MenstrualFlow? menstrualFlow;
  final bool birthControlTaken;
  final bool ovulation;
  final bool sexualActivity;
  final String? cycleInterval;

  CycleEntryModel({
    this.cycleEntryId,
    required this.entryDate,
    required this.userId,
    this.symptoms = const [],
    this.menstrualFlow,
    this.birthControlTaken = false,
    this.ovulation = false,
    this.sexualActivity = false,
    this.cycleInterval,
  });

  factory CycleEntryModel.fromJson(Map<String, dynamic> json) {
    // Parse symptoms from comma-separated string
    List<CycleSymptom> parseSymptoms(String? symptomsStr) {
      if (symptomsStr == null || symptomsStr.isEmpty) return [];
      return symptomsStr
          .split(',')
          .map((s) => CycleSymptomExtension.fromValue(s.trim()))
          .whereType<CycleSymptom>()
          .toList();
    }

    return CycleEntryModel(
      cycleEntryId: json['cycle_entry_id'] as int?,
      entryDate: DateTime.parse(json['entry_date'] as String),
      userId: json['user_id'] as int,
      symptoms: parseSymptoms(json['symptoms'] as String?),
      menstrualFlow: MenstrualFlowExtension.fromValue(json['menstrual_flow'] as String?),
      birthControlTaken: json['birthcontrol_take'] as bool? ?? false,
      ovulation: json['ovulation'] as bool? ?? false,
      sexualActivity: json['sexual_activity'] as bool? ?? false,
      cycleInterval: json['cycle_interval'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (cycleEntryId != null) 'cycle_entry_id': cycleEntryId,
      'entry_date': entryDate.toIso8601String().split('T')[0],
      'user_id': userId,
      'symptoms': symptoms.map((s) => s.value).join(','),
      if (menstrualFlow != null) 'menstrual_flow': menstrualFlow!.value,
      'birthcontrol_take': birthControlTaken,
      'ovulation': ovulation,
      'sexual_activity': sexualActivity,
      if (cycleInterval != null) 'cycle_interval': cycleInterval,
    };
  }

  CycleEntryModel copyWith({
    int? cycleEntryId,
    DateTime? entryDate,
    int? userId,
    List<CycleSymptom>? symptoms,
    MenstrualFlow? menstrualFlow,
    bool? birthControlTaken,
    bool? ovulation,
    bool? sexualActivity,
    String? cycleInterval,
  }) {
    return CycleEntryModel(
      cycleEntryId: cycleEntryId ?? this.cycleEntryId,
      entryDate: entryDate ?? this.entryDate,
      userId: userId ?? this.userId,
      symptoms: symptoms ?? this.symptoms,
      menstrualFlow: menstrualFlow ?? this.menstrualFlow,
      birthControlTaken: birthControlTaken ?? this.birthControlTaken,
      ovulation: ovulation ?? this.ovulation,
      sexualActivity: sexualActivity ?? this.sexualActivity,
      cycleInterval: cycleInterval ?? this.cycleInterval,
    );
  }

  /// Está em período menstrual?
  bool get isMenstruating => menstrualFlow != null && menstrualFlow != MenstrualFlow.none;

  @override
  String toString() => 'CycleEntryModel(date: $entryDate, flow: ${menstrualFlow?.label}, symptoms: ${symptoms.length})';
}

/// Dados calculados do ciclo
class CycleData {
  final int cycleLength;
  final int periodLength;
  final DateTime? lastPeriodStart;

  CycleData({
    this.cycleLength = 28,
    this.periodLength = 5,
    this.lastPeriodStart,
  });

  /// Dias até próxima menstruação
  int? get daysUntilNextPeriod {
    if (lastPeriodStart == null) return null;
    final nextPeriod = lastPeriodStart!.add(Duration(days: cycleLength));
    final diff = nextPeriod.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  /// Dia atual do período (se em menstruação)
  int? get currentPeriodDay {
    if (lastPeriodStart == null) return null;
    final daysSinceStart = DateTime.now().difference(lastPeriodStart!).inDays;
    if (daysSinceStart >= 0 && daysSinceStart < periodLength) {
      return daysSinceStart + 1;
    }
    return null;
  }

  /// Fase atual do ciclo
  CyclePhase? get currentPhase {
    if (lastPeriodStart == null) return null;
    final dayOfCycle = DateTime.now().difference(lastPeriodStart!).inDays % cycleLength;

    if (dayOfCycle < periodLength) {
      return CyclePhase.menstruation;
    } else if (dayOfCycle < 13) {
      return CyclePhase.follicular;
    } else if (dayOfCycle < 17) {
      return CyclePhase.ovulation;
    } else {
      return CyclePhase.luteal;
    }
  }

  /// Dias até ovulação
  int? get daysUntilOvulation {
    if (lastPeriodStart == null) return null;
    final ovulationDay = lastPeriodStart!.add(Duration(days: cycleLength ~/ 2 - 1));
    final diff = ovulationDay.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : null;
  }

  /// Próxima data de menstruação prevista
  DateTime? get nextPeriodDate {
    if (lastPeriodStart == null) return null;
    return lastPeriodStart!.add(Duration(days: cycleLength));
  }

  /// Próxima data de ovulação prevista
  DateTime? get nextOvulationDate {
    if (lastPeriodStart == null) return null;
    return lastPeriodStart!.add(Duration(days: cycleLength ~/ 2 - 1));
  }
}
