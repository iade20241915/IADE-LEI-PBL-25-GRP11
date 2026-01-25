/// Modelo de alimento com informação nutricional
class FoodItem {
  final int? id;
  final String name;
  final String? icon;
  final String? category;
  final double kcalPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;

  const FoodItem({
    this.id,
    required this.name,
    this.icon,
    this.category,
    this.kcalPer100g = 0,
    this.proteinPer100g = 0,
    this.carbsPer100g = 0,
    this.fatPer100g = 0,
  });

  /// Cria FoodItem a partir de dados do Supabase
  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['food_id'] as int?,
      name: map['name'] as String? ?? '',
      icon: map['icon'] as String?,
      category: map['category'] as String?,
      kcalPer100g: _parseDouble(map['kcal_per_100g']),
      proteinPer100g: _parseDouble(map['protein_per_100g']),
      carbsPer100g: _parseDouble(map['carbs_per_100g']),
      fatPer100g: _parseDouble(map['fat_per_100g']),
    );
  }

  /// Helper para converter num para double
  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  /// Converte para Map (para guardar no Supabase)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'food_id': id,
      'name': name,
      'icon': icon,
      'category': category,
      'kcal_per_100g': kcalPer100g,
      'protein_per_100g': proteinPer100g,
      'carbs_per_100g': carbsPer100g,
      'fat_per_100g': fatPer100g,
    };
  }

  /// Cria cópia com valores alterados
  FoodItem copyWith({
    int? id,
    String? name,
    String? icon,
    String? category,
    double? kcalPer100g,
    double? proteinPer100g,
    double? carbsPer100g,
    double? fatPer100g,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      kcalPer100g: kcalPer100g ?? this.kcalPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      fatPer100g: fatPer100g ?? this.fatPer100g,
    );
  }

  /// Calcula calorias para uma quantidade específica
  int caloriesFor(double grams) {
    return ((kcalPer100g * grams) / 100).round();
  }

  /// Calcula proteína para uma quantidade específica
  double proteinFor(double grams) {
    return (proteinPer100g * grams) / 100;
  }

  /// Calcula hidratos para uma quantidade específica
  double carbsFor(double grams) {
    return (carbsPer100g * grams) / 100;
  }

  /// Calcula gordura para uma quantidade específica
  double fatFor(double grams) {
    return (fatPer100g * grams) / 100;
  }

  @override
  String toString() {
    return 'FoodItem(id: $id, name: $name, kcal: $kcalPer100g, P: $proteinPer100g, C: $carbsPer100g, G: $fatPer100g)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodItem && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
