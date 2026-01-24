/// Modelo de dados para Refeições
/// Alinhado com as tabelas `meal`, `food`, `meal_item` da base de dados
/// 
/// Tabela meal:
/// - meal_id (SERIAL PRIMARY KEY)
/// - meal_type (VARCHAR(45))
/// - created_at (TIMESTAMPTZ NOT NULL DEFAULT now())
/// - notes (TEXT)
/// - user_id (INT NOT NULL, FK -> users)
/// 
/// Tabela food:
/// - food_id (SERIAL PRIMARY KEY)
/// - name (VARCHAR(45) NOT NULL)
/// - kcal_per_100g (NUMERIC(10,2))
/// - protein_g (NUMERIC(10,2))
/// - carbs_g (NUMERIC(10,2))
/// - fat_g (NUMERIC(10,2))
/// 
/// Tabela meal_item:
/// - meal_item_id (SERIAL PRIMARY KEY)
/// - quantity (NUMERIC(10,2) NOT NULL)
/// - unit_name (VARCHAR(45) NOT NULL)
/// - kcal_override (NUMERIC(10,2) NOT NULL)
/// - meal_id (INT NOT NULL, FK -> meal)
/// - food_id (INT NOT NULL, FK -> food)

enum MealType { breakfast, lunch, snack, dinner }

extension MealTypeExtension on MealType {
  String get value {
    switch (this) {
      case MealType.breakfast:
        return 'breakfast';
      case MealType.lunch:
        return 'lunch';
      case MealType.snack:
        return 'snack';
      case MealType.dinner:
        return 'dinner';
    }
  }

  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Pequeno-almoço';
      case MealType.lunch:
        return 'Almoço';
      case MealType.snack:
        return 'Lanche';
      case MealType.dinner:
        return 'Jantar';
    }
  }

  String get shortLabel {
    switch (this) {
      case MealType.breakfast:
        return 'P. Almoço';
      case MealType.lunch:
        return 'Almoço';
      case MealType.snack:
        return 'Lanche';
      case MealType.dinner:
        return 'Jantar';
    }
  }

  static MealType fromValue(String value) {
    switch (value.toLowerCase()) {
      case 'breakfast':
        return MealType.breakfast;
      case 'lunch':
        return MealType.lunch;
      case 'snack':
        return MealType.snack;
      case 'dinner':
        return MealType.dinner;
      default:
        return MealType.lunch;
    }
  }
}

/// Modelo para alimento do catálogo
class FoodModel {
  final int? foodId;
  final String name;
  final double kcalPer100g;
  final double proteinG;
  final double carbsG;
  final double fatG;

  FoodModel({
    this.foodId,
    required this.name,
    this.kcalPer100g = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      foodId: json['food_id'] as int?,
      name: json['name'] as String,
      kcalPer100g: (json['kcal_per_100g'] as num?)?.toDouble() ?? 0,
      proteinG: (json['protein_g'] as num?)?.toDouble() ?? 0,
      carbsG: (json['carbs_g'] as num?)?.toDouble() ?? 0,
      fatG: (json['fat_g'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (foodId != null) 'food_id': foodId,
      'name': name,
      'kcal_per_100g': kcalPer100g,
      'protein_g': proteinG,
      'carbs_g': carbsG,
      'fat_g': fatG,
    };
  }

  FoodModel copyWith({
    int? foodId,
    String? name,
    double? kcalPer100g,
    double? proteinG,
    double? carbsG,
    double? fatG,
  }) {
    return FoodModel(
      foodId: foodId ?? this.foodId,
      name: name ?? this.name,
      kcalPer100g: kcalPer100g ?? this.kcalPer100g,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
    );
  }

  /// Calcula calorias para uma quantidade em gramas
  double kcalFor(double grams) => (kcalPer100g * grams) / 100;

  @override
  String toString() => 'FoodModel(id: $foodId, name: $name, kcal: $kcalPer100g/100g)';
}

/// Modelo para item de refeição (alimento + quantidade)
class MealItemModel {
  final int? mealItemId;
  final double quantity;
  final String unitName;
  final double kcalOverride;
  final int? mealId;
  final int foodId;
  final FoodModel? food; // Populated via JOIN

  MealItemModel({
    this.mealItemId,
    required this.quantity,
    this.unitName = 'g',
    required this.kcalOverride,
    this.mealId,
    required this.foodId,
    this.food,
  });

  factory MealItemModel.fromJson(Map<String, dynamic> json) {
    return MealItemModel(
      mealItemId: json['meal_item_id'] as int?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unitName: json['unit_name'] as String? ?? 'g',
      kcalOverride: (json['kcal_override'] as num?)?.toDouble() ?? 0,
      mealId: json['meal_id'] as int?,
      foodId: json['food_id'] as int,
      food: json['food'] != null ? FoodModel.fromJson(json['food'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (mealItemId != null) 'meal_item_id': mealItemId,
      'quantity': quantity,
      'unit_name': unitName,
      'kcal_override': kcalOverride,
      if (mealId != null) 'meal_id': mealId,
      'food_id': foodId,
    };
  }

  /// Calorias totais deste item
  double get totalKcal => kcalOverride;

  @override
  String toString() => 'MealItemModel(food: ${food?.name ?? foodId}, qty: $quantity$unitName, kcal: $kcalOverride)';
}

/// Modelo para refeição completa
class MealModel {
  final int? mealId;
  final MealType mealType;
  final DateTime createdAt;
  final String? notes;
  final int userId;
  final List<MealItemModel> items;

  MealModel({
    this.mealId,
    required this.mealType,
    DateTime? createdAt,
    this.notes,
    required this.userId,
    this.items = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      mealId: json['meal_id'] as int?,
      mealType: MealTypeExtension.fromValue(json['meal_type'] as String? ?? 'lunch'),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      notes: json['notes'] as String?,
      userId: json['user_id'] as int,
      items: (json['meal_items'] as List<dynamic>?)
              ?.map((e) => MealItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (mealId != null) 'meal_id': mealId,
      'meal_type': mealType.value,
      'created_at': createdAt.toIso8601String(),
      if (notes != null) 'notes': notes,
      'user_id': userId,
    };
  }

  MealModel copyWith({
    int? mealId,
    MealType? mealType,
    DateTime? createdAt,
    String? notes,
    int? userId,
    List<MealItemModel>? items,
  }) {
    return MealModel(
      mealId: mealId ?? this.mealId,
      mealType: mealType ?? this.mealType,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      items: items ?? this.items,
    );
  }

  /// Total de calorias da refeição
  double get totalKcal => items.fold(0, (sum, item) => sum + item.totalKcal);

  /// Data sem horas
  DateTime get date => DateTime(createdAt.year, createdAt.month, createdAt.day);

  /// Hora formatada
  String get timeFormatted {
    final h = createdAt.hour.toString().padLeft(2, '0');
    final m = createdAt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  String toString() => 'MealModel(id: $mealId, type: ${mealType.label}, items: ${items.length}, kcal: $totalKcal)';
}

/// Resumo diário de calorias
class DailyCaloriesSummary {
  final DateTime date;
  final List<MealModel> meals;
  final int goalKcal;

  DailyCaloriesSummary({
    required this.date,
    this.meals = const [],
    this.goalKcal = 2000,
  });

  double get totalKcal => meals.fold(0, (sum, m) => sum + m.totalKcal);

  double get progress => (totalKcal / goalKcal).clamp(0.0, 1.5);

  int get breakfastKcal => meals
      .where((m) => m.mealType == MealType.breakfast)
      .fold(0, (sum, m) => sum + m.totalKcal.round());

  int get lunchKcal => meals
      .where((m) => m.mealType == MealType.lunch)
      .fold(0, (sum, m) => sum + m.totalKcal.round());

  int get snackKcal => meals
      .where((m) => m.mealType == MealType.snack)
      .fold(0, (sum, m) => sum + m.totalKcal.round());

  int get dinnerKcal => meals
      .where((m) => m.mealType == MealType.dinner)
      .fold(0, (sum, m) => sum + m.totalKcal.round());
}
