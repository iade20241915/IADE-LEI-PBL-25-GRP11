/// Modelo de dados para registo do ciclo menstrual
class CycleEntry {
  final String id;
  final String userId;
  final DateTime entryDate;
  final CyclePhase? phase;
  final MenstrualFlow? menstrualFlow;
  final List<CycleSymptom> symptoms;
  final bool birthControlTaken;
  final bool ovulation;
  final bool sexualActivity;
  final String? notes;

  CycleEntry({
    required this.id,
    required this.userId,
    required this.entryDate,
    this.phase,
    this.menstrualFlow,
    this.symptoms = const [],
    this.birthControlTaken = false,
    this.ovulation = false,
    this.sexualActivity = false,
    this.notes,
  });

  CycleEntry copyWith({
    String? id,
    String? userId,
    DateTime? entryDate,
    CyclePhase? phase,
    MenstrualFlow? menstrualFlow,
    List<CycleSymptom>? symptoms,
    bool? birthControlTaken,
    bool? ovulation,
    bool? sexualActivity,
    String? notes,
  }) {
    return CycleEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      entryDate: entryDate ?? this.entryDate,
      phase: phase ?? this.phase,
      menstrualFlow: menstrualFlow ?? this.menstrualFlow,
      symptoms: symptoms ?? this.symptoms,
      birthControlTaken: birthControlTaken ?? this.birthControlTaken,
      ovulation: ovulation ?? this.ovulation,
      sexualActivity: sexualActivity ?? this.sexualActivity,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'entry_date': entryDate.toIso8601String(),
      'phase': phase?.toString().split('.').last,
      'menstrual_flow': menstrualFlow?.toString().split('.').last,
      'symptoms': symptoms.map((s) => s.toString().split('.').last).toList(),
      'birthcontrol_take': birthControlTaken,
      'ovulation': ovulation,
      'sexual_activity': sexualActivity,
      'notes': notes,
    };
  }

  factory CycleEntry.fromJson(Map<String, dynamic> json) {
    return CycleEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      entryDate: DateTime.parse(json['entry_date'] as String),
      phase: json['phase'] != null
          ? CyclePhase.values.firstWhere(
              (e) => e.toString().split('.').last == json['phase'],
            )
          : null,
      menstrualFlow: json['menstrual_flow'] != null
          ? MenstrualFlow.values.firstWhere(
              (e) => e.toString().split('.').last == json['menstrual_flow'],
            )
          : null,
      symptoms: (json['symptoms'] as List<dynamic>?)
              ?.map((s) => CycleSymptom.values.firstWhere(
                    (e) => e.toString().split('.').last == s,
                  ))
              .toList() ??
          [],
      birthControlTaken: json['birthcontrol_take'] as bool? ?? false,
      ovulation: json['ovulation'] as bool? ?? false,
      sexualActivity: json['sexual_activity'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }
}

/// Fase do ciclo
enum CyclePhase {
  menstruation,
  follicular,
  ovulation,
  luteal,
}

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
}

/// Fluxo menstrual
enum MenstrualFlow {
  none,
  spotting,
  light,
  medium,
  heavy,
}

extension MenstrualFlowExtension on MenstrualFlow {
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
}

/// Dados do ciclo para cálculos
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
}
