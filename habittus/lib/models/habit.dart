/// Modelo de dados para registro de hábitos e vícios
class Habit {
  final String id;
  final String userId;
  final String name;
  final HabitType type;
  final HabitCategory category;
  final String? description;
  final String? emoji;
  final DateTime createdAt;
  final bool isActive;

  Habit({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.category,
    this.description,
    this.emoji,
    required this.createdAt,
    this.isActive = true,
  });

  Habit copyWith({
    String? id,
    String? userId,
    String? name,
    HabitType? type,
    HabitCategory? category,
    String? description,
    String? emoji,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type.toString().split('.').last,
      'category': category.toString().split('.').last,
      'description': description,
      'emoji': emoji,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      type: HabitType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      category: HabitCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
      ),
      description: json['description'] as String?,
      emoji: json['emoji'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

/// Registro de ocorrência de um hábito/vício
class HabitLog {
  final String id;
  final String habitId;
  final String userId;
  final DateTime timestamp;
  final int? quantity;
  final String? notes;
  final HabitMood? mood;

  HabitLog({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.timestamp,
    this.quantity,
    this.notes,
    this.mood,
  });

  HabitLog copyWith({
    String? id,
    String? habitId,
    String? userId,
    DateTime? timestamp,
    int? quantity,
    String? notes,
    HabitMood? mood,
  }) {
    return HabitLog(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      mood: mood ?? this.mood,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habit_id': habitId,
      'user_id': userId,
      'timestamp': timestamp.toIso8601String(),
      'quantity': quantity,
      'notes': notes,
      'mood': mood?.toString().split('.').last,
    };
  }

  factory HabitLog.fromJson(Map<String, dynamic> json) {
    return HabitLog(
      id: json['id'] as String,
      habitId: json['habit_id'] as String,
      userId: json['user_id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      quantity: json['quantity'] as int?,
      notes: json['notes'] as String?,
      mood: json['mood'] != null
          ? HabitMood.values.firstWhere(
              (e) => e.toString().split('.').last == json['mood'],
            )
          : null,
    );
  }
}

/// Tipo de hábito
enum HabitType {
  positive, // Hábito positivo (exercício, leitura, etc)
  negative, // Vício/Hábito negativo (fumar, álcool, etc)
}

extension HabitTypeExtension on HabitType {
  String get label {
    switch (this) {
      case HabitType.positive:
        return 'Hábito Positivo';
      case HabitType.negative:
        return 'Hábito a Reduzir';
    }
  }
}

/// Categoria de hábito/vício
enum HabitCategory {
  // Vícios/Hábitos negativos
  smoking,
  alcohol,
  drugs,
  gambling,
  screenTime,
  socialMedia,
  gaming,
  shopping,
  caffeine,
  sugarSnacks,

  // Hábitos positivos
  reading,
  meditation,
  exercise,
  waterIntake,
  healthyEating,
  learning,
  creativity,
  socializing,
  other,
}

extension HabitCategoryExtension on HabitCategory {
  String get label {
    switch (this) {
      // Negativos
      case HabitCategory.smoking:
        return 'Fumar';
      case HabitCategory.alcohol:
        return 'Álcool';
      case HabitCategory.drugs:
        return 'Substâncias';
      case HabitCategory.gambling:
        return 'Jogo';
      case HabitCategory.screenTime:
        return 'Tempo de Ecrã';
      case HabitCategory.socialMedia:
        return 'Redes Sociais';
      case HabitCategory.gaming:
        return 'Videojogos';
      case HabitCategory.shopping:
        return 'Compras';
      case HabitCategory.caffeine:
        return 'Cafeína';
      case HabitCategory.sugarSnacks:
        return 'Açúcar/Snacks';

      // Positivos
      case HabitCategory.reading:
        return 'Leitura';
      case HabitCategory.meditation:
        return 'Meditação';
      case HabitCategory.exercise:
        return 'Exercício';
      case HabitCategory.waterIntake:
        return 'Água';
      case HabitCategory.healthyEating:
        return 'Alimentação Saudável';
      case HabitCategory.learning:
        return 'Aprendizagem';
      case HabitCategory.creativity:
        return 'Criatividade';
      case HabitCategory.socializing:
        return 'Socialização';
      case HabitCategory.other:
        return 'Outro';
    }
  }

  String get emoji {
    switch (this) {
      // Negativos
      case HabitCategory.smoking:
        return '🚬';
      case HabitCategory.alcohol:
        return '🍺';
      case HabitCategory.drugs:
        return '💊';
      case HabitCategory.gambling:
        return '🎰';
      case HabitCategory.screenTime:
        return '📱';
      case HabitCategory.socialMedia:
        return '📲';
      case HabitCategory.gaming:
        return '🎮';
      case HabitCategory.shopping:
        return '🛍️';
      case HabitCategory.caffeine:
        return '☕';
      case HabitCategory.sugarSnacks:
        return '🍭';

      // Positivos
      case HabitCategory.reading:
        return '📚';
      case HabitCategory.meditation:
        return '🧘';
      case HabitCategory.exercise:
        return '💪';
      case HabitCategory.waterIntake:
        return '💧';
      case HabitCategory.healthyEating:
        return '🥗';
      case HabitCategory.learning:
        return '🎓';
      case HabitCategory.creativity:
        return '🎨';
      case HabitCategory.socializing:
        return '👥';
      case HabitCategory.other:
        return '⭐';
    }
  }

  bool get isNegative {
    return [
      HabitCategory.smoking,
      HabitCategory.alcohol,
      HabitCategory.drugs,
      HabitCategory.gambling,
      HabitCategory.screenTime,
      HabitCategory.socialMedia,
      HabitCategory.gaming,
      HabitCategory.shopping,
      HabitCategory.caffeine,
      HabitCategory.sugarSnacks,
    ].contains(this);
  }
}

/// Estado emocional ao registrar ocorrência
enum HabitMood {
  veryBad,
  bad,
  neutral,
  good,
  veryGood,
}

extension HabitMoodExtension on HabitMood {
  String get label {
    switch (this) {
      case HabitMood.veryBad:
        return 'Muito Mal';
      case HabitMood.bad:
        return 'Mal';
      case HabitMood.neutral:
        return 'Neutro';
      case HabitMood.good:
        return 'Bem';
      case HabitMood.veryGood:
        return 'Muito Bem';
    }
  }

  String get emoji {
    switch (this) {
      case HabitMood.veryBad:
        return '😢';
      case HabitMood.bad:
        return '😟';
      case HabitMood.neutral:
        return '😐';
      case HabitMood.good:
        return '🙂';
      case HabitMood.veryGood:
        return '😄';
    }
  }
}
