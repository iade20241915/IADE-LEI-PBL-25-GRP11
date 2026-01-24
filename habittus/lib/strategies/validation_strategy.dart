/// Design Pattern: STRATEGY
/// 
/// O Strategy Pattern permite definir diferentes algoritmos/estratégias
/// que podem ser trocados em runtime. Usado aqui para:
/// - Validação de dados
/// - Cálculos de metas
/// - Cálculos de pontuação
/// 
/// Benefícios:
/// - Flexibilidade para mudar algoritmos em runtime
/// - Separação de responsabilidades
/// - Facilita adicionar novos algoritmos
/// - Código mais testável

// ==================== VALIDATION STRATEGIES ====================

/// Interface base para estratégias de validação
abstract class ValidationStrategy<T> {
  /// Valida o objeto e retorna lista de erros (vazia se válido)
  List<String> validate(T object);

  /// Verifica se o objeto é válido
  bool isValid(T object) => validate(object).isEmpty;
}

/// Estratégia de validação para email
class EmailValidationStrategy extends ValidationStrategy<String> {
  @override
  List<String> validate(String email) {
    final errors = <String>[];

    if (email.isEmpty) {
      errors.add('Email é obrigatório');
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      errors.add('Email inválido');
    }

    return errors;
  }
}

/// Estratégia de validação para password
class PasswordValidationStrategy extends ValidationStrategy<String> {
  final int minLength;
  final bool requireUppercase;
  final bool requireLowercase;
  final bool requireNumber;
  final bool requireSpecialChar;

  PasswordValidationStrategy({
    this.minLength = 8,
    this.requireUppercase = true,
    this.requireLowercase = true,
    this.requireNumber = true,
    this.requireSpecialChar = false,
  });

  @override
  List<String> validate(String password) {
    final errors = <String>[];

    if (password.isEmpty) {
      errors.add('Password é obrigatória');
      return errors;
    }

    if (password.length < minLength) {
      errors.add('Password deve ter pelo menos $minLength caracteres');
    }

    if (requireUppercase && !password.contains(RegExp(r'[A-Z]'))) {
      errors.add('Password deve conter pelo menos uma letra maiúscula');
    }

    if (requireLowercase && !password.contains(RegExp(r'[a-z]'))) {
      errors.add('Password deve conter pelo menos uma letra minúscula');
    }

    if (requireNumber && !password.contains(RegExp(r'[0-9]'))) {
      errors.add('Password deve conter pelo menos um número');
    }

    if (requireSpecialChar && !password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      errors.add('Password deve conter pelo menos um caractere especial');
    }

    return errors;
  }
}

/// Estratégia de validação para nome
class NameValidationStrategy extends ValidationStrategy<String> {
  final int minLength;
  final int maxLength;

  NameValidationStrategy({
    this.minLength = 2,
    this.maxLength = 60,
  });

  @override
  List<String> validate(String name) {
    final errors = <String>[];

    if (name.isEmpty) {
      errors.add('Nome é obrigatório');
    } else if (name.length < minLength) {
      errors.add('Nome deve ter pelo menos $minLength caracteres');
    } else if (name.length > maxLength) {
      errors.add('Nome deve ter no máximo $maxLength caracteres');
    }

    return errors;
  }
}

/// Estratégia de validação para quantidade de água
class WaterAmountValidationStrategy extends ValidationStrategy<int> {
  final int minMl;
  final int maxMl;

  WaterAmountValidationStrategy({
    this.minMl = 50,
    this.maxMl = 2000,
  });

  @override
  List<String> validate(int amountMl) {
    final errors = <String>[];

    if (amountMl < minMl) {
      errors.add('Quantidade mínima é ${minMl}ml');
    } else if (amountMl > maxMl) {
      errors.add('Quantidade máxima é ${maxMl}ml');
    }

    return errors;
  }
}

/// Estratégia de validação para duração de sono
class SleepDurationValidationStrategy extends ValidationStrategy<Duration> {
  final Duration minDuration;
  final Duration maxDuration;

  SleepDurationValidationStrategy({
    this.minDuration = const Duration(minutes: 30),
    this.maxDuration = const Duration(hours: 16),
  });

  @override
  List<String> validate(Duration duration) {
    final errors = <String>[];

    if (duration < minDuration) {
      errors.add('Duração mínima é ${minDuration.inMinutes} minutos');
    } else if (duration > maxDuration) {
      errors.add('Duração máxima é ${maxDuration.inHours} horas');
    }

    return errors;
  }
}

// ==================== GOAL CALCULATION STRATEGIES ====================

/// Interface para estratégias de cálculo de metas
abstract class GoalCalculationStrategy {
  /// Calcula o progresso (0.0 a 1.0+)
  double calculateProgress(double current, double target);

  /// Verifica se a meta foi atingida
  bool isGoalReached(double current, double target);

  /// Calcula quanto falta para atingir a meta
  double calculateRemaining(double current, double target);
}

/// Estratégia simples: progresso linear
class LinearGoalStrategy implements GoalCalculationStrategy {
  @override
  double calculateProgress(double current, double target) {
    if (target <= 0) return 0;
    return current / target;
  }

  @override
  bool isGoalReached(double current, double target) {
    return current >= target;
  }

  @override
  double calculateRemaining(double current, double target) {
    final remaining = target - current;
    return remaining > 0 ? remaining : 0;
  }
}

/// Estratégia com bónus: dá pontos extra por ultrapassar a meta
class BonusGoalStrategy implements GoalCalculationStrategy {
  final double bonusMultiplier;

  BonusGoalStrategy({this.bonusMultiplier = 1.2});

  @override
  double calculateProgress(double current, double target) {
    if (target <= 0) return 0;
    final baseProgress = current / target;
    if (baseProgress > 1.0) {
      // Bónus por ultrapassar
      return 1.0 + ((baseProgress - 1.0) * bonusMultiplier);
    }
    return baseProgress;
  }

  @override
  bool isGoalReached(double current, double target) {
    return current >= target;
  }

  @override
  double calculateRemaining(double current, double target) {
    final remaining = target - current;
    return remaining > 0 ? remaining : 0;
  }
}

/// Estratégia com penalização: penaliza por não atingir
class PenaltyGoalStrategy implements GoalCalculationStrategy {
  final double penaltyThreshold; // Ex: 0.5 = penaliza se < 50%

  PenaltyGoalStrategy({this.penaltyThreshold = 0.5});

  @override
  double calculateProgress(double current, double target) {
    if (target <= 0) return 0;
    final progress = current / target;
    if (progress < penaltyThreshold) {
      // Penalização
      return progress * 0.8;
    }
    return progress;
  }

  @override
  bool isGoalReached(double current, double target) {
    return current >= target;
  }

  @override
  double calculateRemaining(double current, double target) {
    final remaining = target - current;
    return remaining > 0 ? remaining : 0;
  }
}

// ==================== CALORIE CALCULATION STRATEGIES ====================

/// Interface para estratégias de cálculo de calorias
abstract class CalorieCalculationStrategy {
  /// Calcula calorias queimadas
  int calculateCaloriesBurned({
    required int durationMinutes,
    required double weightKg,
    required String activityType,
  });

  /// Calcula calorias de uma refeição
  double calculateMealCalories({
    required double quantity,
    required double kcalPer100g,
    String unit = 'g',
  });
}

/// Estratégia padrão de cálculo de calorias
class StandardCalorieStrategy implements CalorieCalculationStrategy {
  // MET values para atividades comuns
  static const Map<String, double> _metValues = {
    'walking': 3.5,
    'running': 8.0,
    'cycling': 6.0,
    'swimming': 7.0,
    'yoga': 2.5,
    'gym': 5.0,
    'dancing': 4.5,
    'hiking': 6.0,
    'soccer': 7.0,
    'basketball': 6.5,
    'tennis': 7.0,
    'default': 4.0,
  };

  @override
  int calculateCaloriesBurned({
    required int durationMinutes,
    required double weightKg,
    required String activityType,
  }) {
    final met = _metValues[activityType.toLowerCase()] ?? _metValues['default']!;
    // Fórmula: Calorias = MET × peso (kg) × duração (horas)
    final hours = durationMinutes / 60.0;
    return (met * weightKg * hours).round();
  }

  @override
  double calculateMealCalories({
    required double quantity,
    required double kcalPer100g,
    String unit = 'g',
  }) {
    double grams = quantity;
    
    // Converter unidades para gramas
    switch (unit.toLowerCase()) {
      case 'kg':
        grams = quantity * 1000;
        break;
      case 'ml':
        grams = quantity; // Aproximação: 1ml ≈ 1g
        break;
      case 'l':
        grams = quantity * 1000;
        break;
      case 'unidade':
      case 'unit':
        grams = quantity * 100; // Assume 100g por unidade
        break;
    }

    return (kcalPer100g * grams) / 100;
  }
}

// ==================== SLEEP SCORE STRATEGIES ====================

/// Interface para estratégias de pontuação de sono
abstract class SleepScoreStrategy {
  /// Calcula pontuação de 0 a 100
  int calculateScore({
    required Duration duration,
    required int qualityScore,
    Duration? targetDuration,
  });

  /// Retorna classificação textual
  String getClassification(int score);
}

/// Estratégia padrão de pontuação de sono
class StandardSleepScoreStrategy implements SleepScoreStrategy {
  @override
  int calculateScore({
    required Duration duration,
    required int qualityScore,
    Duration? targetDuration,
  }) {
    final target = targetDuration ?? const Duration(hours: 8);
    
    // Pontuação de duração (0-50 pontos)
    final durationRatio = duration.inMinutes / target.inMinutes;
    int durationScore;
    if (durationRatio >= 0.9 && durationRatio <= 1.1) {
      durationScore = 50; // Ideal
    } else if (durationRatio >= 0.75 && durationRatio <= 1.25) {
      durationScore = 40;
    } else if (durationRatio >= 0.5) {
      durationScore = 25;
    } else {
      durationScore = 10;
    }

    // Pontuação de qualidade (0-50 pontos)
    final qualityScorePoints = (qualityScore / 5 * 50).round();

    return (durationScore + qualityScorePoints).clamp(0, 100);
  }

  @override
  String getClassification(int score) {
    if (score >= 90) return 'Excelente';
    if (score >= 75) return 'Bom';
    if (score >= 50) return 'Razoável';
    if (score >= 25) return 'Fraco';
    return 'Insuficiente';
  }
}

// ==================== CONTEXT CLASSES ====================

/// Contexto para usar estratégias de validação
class ValidationContext<T> {
  ValidationStrategy<T> _strategy;

  ValidationContext(this._strategy);

  void setStrategy(ValidationStrategy<T> strategy) {
    _strategy = strategy;
  }

  List<String> validate(T object) => _strategy.validate(object);
  bool isValid(T object) => _strategy.isValid(object);
}

/// Contexto para usar estratégias de metas
class GoalContext {
  GoalCalculationStrategy _strategy;

  GoalContext(this._strategy);

  void setStrategy(GoalCalculationStrategy strategy) {
    _strategy = strategy;
  }

  double calculateProgress(double current, double target) =>
      _strategy.calculateProgress(current, target);

  bool isGoalReached(double current, double target) =>
      _strategy.isGoalReached(current, target);

  double calculateRemaining(double current, double target) =>
      _strategy.calculateRemaining(current, target);
}

/// Contexto para usar estratégias de calorias
class CalorieContext {
  CalorieCalculationStrategy _strategy;

  CalorieContext(this._strategy);

  void setStrategy(CalorieCalculationStrategy strategy) {
    _strategy = strategy;
  }

  int calculateCaloriesBurned({
    required int durationMinutes,
    required double weightKg,
    required String activityType,
  }) =>
      _strategy.calculateCaloriesBurned(
        durationMinutes: durationMinutes,
        weightKg: weightKg,
        activityType: activityType,
      );

  double calculateMealCalories({
    required double quantity,
    required double kcalPer100g,
    String unit = 'g',
  }) =>
      _strategy.calculateMealCalories(
        quantity: quantity,
        kcalPer100g: kcalPer100g,
        unit: unit,
      );
}

/// Contexto para usar estratégias de pontuação de sono
class SleepScoreContext {
  SleepScoreStrategy _strategy;

  SleepScoreContext(this._strategy);

  void setStrategy(SleepScoreStrategy strategy) {
    _strategy = strategy;
  }

  int calculateScore({
    required Duration duration,
    required int qualityScore,
    Duration? targetDuration,
  }) =>
      _strategy.calculateScore(
        duration: duration,
        qualityScore: qualityScore,
        targetDuration: targetDuration,
      );

  String getClassification(int score) => _strategy.getClassification(score);
}
