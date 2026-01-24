/// Modelo de dados para Hábitos
/// Alinhado com as tabelas `habits` e `habit_types` da base de dados
/// 
/// Tabela habit_types:
/// - habit_type_id (SERIAL PRIMARY KEY)
/// - habit_type (VARCHAR(45) NOT NULL)
/// 
/// Tabela habits:
/// - habit_id (SERIAL PRIMARY KEY)
/// - user_id (INT NOT NULL, FK -> users)
/// - habit_type_id (INT NOT NULL, FK -> habit_types)
/// - created_at (TIMESTAMPTZ NOT NULL DEFAULT now())
/// - daysweek (INT) - dias por semana
/// - timesday (INT) - vezes por dia
/// - moneysspent (NUMERIC(10,2)) - dinheiro gasto
/// - notes (VARCHAR(300))

/// Modelo para tipo de hábito
class HabitTypeModel {
  final int? habitTypeId;
  final String habitType;

  HabitTypeModel({
    this.habitTypeId,
    required this.habitType,
  });

  factory HabitTypeModel.fromJson(Map<String, dynamic> json) {
    return HabitTypeModel(
      habitTypeId: json['habit_type_id'] as int?,
      habitType: json['habit_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (habitTypeId != null) 'habit_type_id': habitTypeId,
      'habit_type': habitType,
    };
  }
}

/// Categorias de hábitos (para UI)
enum HabitCategory {
  smoking,
  alcohol,
  caffeine,
  sugar,
  gaming,
  socialMedia,
  shopping,
  exercise,
  meditation,
  reading,
  learning,
  water,
  sleep,
  other,
}

extension HabitCategoryExtension on HabitCategory {
  String get label {
    switch (this) {
      case HabitCategory.smoking:
        return 'Fumar';
      case HabitCategory.alcohol:
        return 'Álcool';
      case HabitCategory.caffeine:
        return 'Cafeína';
      case HabitCategory.sugar:
        return 'Açúcar';
      case HabitCategory.gaming:
        return 'Jogos';
      case HabitCategory.socialMedia:
        return 'Redes Sociais';
      case HabitCategory.shopping:
        return 'Compras';
      case HabitCategory.exercise:
        return 'Exercício';
      case HabitCategory.meditation:
        return 'Meditação';
      case HabitCategory.reading:
        return 'Leitura';
      case HabitCategory.learning:
        return 'Aprendizagem';
      case HabitCategory.water:
        return 'Água';
      case HabitCategory.sleep:
        return 'Sono';
      case HabitCategory.other:
        return 'Outro';
    }
  }

  String get emoji {
    switch (this) {
      case HabitCategory.smoking:
        return '🚬';
      case HabitCategory.alcohol:
        return '🍺';
      case HabitCategory.caffeine:
        return '☕';
      case HabitCategory.sugar:
        return '🍬';
      case HabitCategory.gaming:
        return '🎮';
      case HabitCategory.socialMedia:
        return '📱';
      case HabitCategory.shopping:
        return '🛍️';
      case HabitCategory.exercise:
        return '💪';
      case HabitCategory.meditation:
        return '🧘';
      case HabitCategory.reading:
        return '📚';
      case HabitCategory.learning:
        return '🎓';
      case HabitCategory.water:
        return '💧';
      case HabitCategory.sleep:
        return '😴';
      case HabitCategory.other:
        return '✨';
    }
  }

  bool get isNegative {
    switch (this) {
      case HabitCategory.smoking:
      case HabitCategory.alcohol:
      case HabitCategory.caffeine:
      case HabitCategory.sugar:
      case HabitCategory.gaming:
      case HabitCategory.socialMedia:
      case HabitCategory.shopping:
        return true;
      default:
        return false;
    }
  }

  static HabitCategory fromString(String value) {
    return HabitCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => HabitCategory.other,
    );
  }
}

/// Modelo para hábito
class HabitModel {
  final int? habitId;
  final int userId;
  final int habitTypeId;
  final DateTime createdAt;
  final int? daysWeek;
  final int? timesDay;
  final double? moneySpent;
  final String? notes;
  final HabitTypeModel? habitType;

  // Campos adicionais para UI
  final String? name;
  final String? description;
  final HabitCategory category;
  final String? emoji;
  final bool isPositive;
  final int? currentStreak;
  final int? longestStreak;

  HabitModel({
    this.habitId,
    required this.userId,
    required this.habitTypeId,
    DateTime? createdAt,
    this.daysWeek,
    this.timesDay,
    this.moneySpent,
    this.notes,
    this.habitType,
    this.name,
    this.description,
    this.category = HabitCategory.other,
    this.emoji,
    this.isPositive = true,
    this.currentStreak,
    this.longestStreak,
  }) : createdAt = createdAt ?? DateTime.now();

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      habitId: json['habit_id'] as int?,
      userId: json['user_id'] as int,
      habitTypeId: json['habit_type_id'] as int,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      daysWeek: json['daysweek'] as int?,
      timesDay: json['timesday'] as int?,
      moneySpent: (json['moneysspent'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      habitType: json['habit_type'] != null
          ? HabitTypeModel.fromJson(json['habit_type'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (habitId != null) 'habit_id': habitId,
      'user_id': userId,
      'habit_type_id': habitTypeId,
      'created_at': createdAt.toIso8601String(),
      if (daysWeek != null) 'daysweek': daysWeek,
      if (timesDay != null) 'timesday': timesDay,
      if (moneySpent != null) 'moneysspent': moneySpent,
      if (notes != null) 'notes': notes,
    };
  }

  HabitModel copyWith({
    int? habitId,
    int? userId,
    int? habitTypeId,
    DateTime? createdAt,
    int? daysWeek,
    int? timesDay,
    double? moneySpent,
    String? notes,
    HabitTypeModel? habitType,
    String? name,
    String? description,
    HabitCategory? category,
    String? emoji,
    bool? isPositive,
    int? currentStreak,
    int? longestStreak,
  }) {
    return HabitModel(
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      habitTypeId: habitTypeId ?? this.habitTypeId,
      createdAt: createdAt ?? this.createdAt,
      daysWeek: daysWeek ?? this.daysWeek,
      timesDay: timesDay ?? this.timesDay,
      moneySpent: moneySpent ?? this.moneySpent,
      notes: notes ?? this.notes,
      habitType: habitType ?? this.habitType,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      isPositive: isPositive ?? this.isPositive,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }

  /// Nome para exibição
  String get displayName => name ?? habitType?.habitType ?? 'Hábito';

  /// Emoji para exibição
  String get displayEmoji => emoji ?? category.emoji;

  /// Dias desde o início
  int get daysSinceStart => DateTime.now().difference(createdAt).inDays;

  /// Dinheiro poupado (se for hábito negativo)
  double get moneySaved {
    if (moneySpent == null || moneySpent! <= 0) return 0;
    return moneySpent! * daysSinceStart;
  }

  @override
  String toString() => 'HabitModel(id: $habitId, name: $displayName, streak: $currentStreak)';
}

/// Modelo para registo diário de hábito (para tracking)
class HabitLogModel {
  final int? logId;
  final int habitId;
  final DateTime logDate;
  final bool completed;
  final String? notes;

  HabitLogModel({
    this.logId,
    required this.habitId,
    required this.logDate,
    this.completed = false,
    this.notes,
  });

  factory HabitLogModel.fromJson(Map<String, dynamic> json) {
    return HabitLogModel(
      logId: json['log_id'] as int?,
      habitId: json['habit_id'] as int,
      logDate: DateTime.parse(json['log_date'] as String),
      completed: json['completed'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (logId != null) 'log_id': logId,
      'habit_id': habitId,
      'log_date': logDate.toIso8601String().split('T')[0],
      'completed': completed,
      if (notes != null) 'notes': notes,
    };
  }
}
