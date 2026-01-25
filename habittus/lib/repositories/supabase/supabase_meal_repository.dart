import '../../core/database/supabase_service.dart';

/// Modelo de dados para refeição
class MealEntry {
  final int? id;
  final int? userId;
  final String? mealType;
  final DateTime createdAt;
  final String? notes;
  final List<MealItemEntry> items;

  const MealEntry({
    this.id,
    this.userId,
    this.mealType,
    required this.createdAt,
    this.notes,
    this.items = const [],
  });

  int get totalKcal => items.fold(0, (sum, item) => sum + item.kcal);

  factory MealEntry.fromJson(Map<String, dynamic> json, [List<MealItemEntry>? items]) {
    return MealEntry(
      id: json['meal_id'] as int?,
      userId: json['user_id'] as int?,
      mealType: json['meal_type'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      notes: json['notes'] as String?,
      items: items ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'meal_id': id,
      'meal_type': mealType,
      'created_at': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  MealEntry copyWith({
    int? id,
    int? userId,
    String? mealType,
    DateTime? createdAt,
    String? notes,
    List<MealItemEntry>? items,
  }) {
    return MealEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mealType: mealType ?? this.mealType,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      items: items ?? this.items,
    );
  }
}

/// Modelo de item de refeição
class MealItemEntry {
  final int? id;
  final int? mealId;
  final int? foodId;
  final String foodName;
  final double quantity;
  final String unitName;
  final int kcal;

  const MealItemEntry({
    this.id,
    this.mealId,
    this.foodId,
    required this.foodName,
    required this.quantity,
    required this.unitName,
    required this.kcal,
  });

  factory MealItemEntry.fromJson(Map<String, dynamic> json, [Map<String, dynamic>? food]) {
    return MealItemEntry(
      id: json['meal_item_id'] as int?,
      mealId: json['meal_id'] as int?,
      foodId: json['food_id'] as int?,
      foodName: food?['name'] as String? ?? json['food_name'] as String? ?? 'Desconhecido',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unitName: json['unit_name'] as String? ?? 'g',
      kcal: (json['kcal_override'] as num?)?.toInt() ?? (json['kcal'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'meal_item_id': id,
      if (mealId != null) 'meal_id': mealId,
      if (foodId != null) 'food_id': foodId,
      'quantity': quantity,
      'unit_name': unitName,
      'kcal_override': kcal,
    };
  }
}

/// Implementação Supabase do repositório de refeições
class SupabaseMealRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  int get _userId {
    final id = _supabase.currentUserId ?? 0;
    print('SupabaseMealRepository._userId: $id');
    return id;
  }

  /// Obtém refeições para uma data específica
  Future<List<MealEntry>> getForDate(DateTime date) async {
    final userId = _userId;
    if (userId == 0) {
      print('getForDate: userId é 0, retornando lista vazia');
      return [];
    }

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    print('getForDate: Buscando refeições de $startOfDay a $endOfDay para user $userId');

    try {
      final response = await _supabase
          .from('meal')
          .select('*, meal_item(*, food(*))')
          .eq('user_id', userId)
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String())
          .order('created_at', ascending: true);

      print('getForDate: Resposta: $response');

      if (response == null) return [];

      final meals = (response as List).map((json) {
        final itemsJson = json['meal_item'] as List? ?? [];
        final items = itemsJson.map((item) {
          final food = item['food'] as Map<String, dynamic>?;
          return MealItemEntry.fromJson(item, food);
        }).toList();
        return MealEntry.fromJson(json, items);
      }).toList();

      print('getForDate: Encontradas ${meals.length} refeições');
      return meals;
    } catch (e) {
      print('Erro ao obter refeições: $e');
      return [];
    }
  }

  /// Guarda nova refeição
  Future<int?> saveMeal(MealEntry meal) async {
    final userId = _userId;
    if (userId == 0) {
      print('saveMeal: userId é 0, não é possível guardar');
      throw Exception('Utilizador não autenticado');
    }

    print('saveMeal: Guardando refeição ${meal.mealType} para user $userId');

    try {
      final data = {
        'user_id': userId,
        'meal_type': meal.mealType,
        'created_at': meal.createdAt.toIso8601String(),
        'notes': meal.notes,
      };
      
      print('saveMeal: Dados a inserir: $data');

      final result = await _supabase
          .from('meal')
          .insert(data)
          .select('meal_id')
          .single();

      final mealId = result['meal_id'] as int;
      print('saveMeal: Refeição criada com ID $mealId');
      return mealId;
    } catch (e) {
      print('Erro ao guardar refeição: $e');
      rethrow;
    }
  }

  /// Adiciona item a uma refeição
  Future<void> addMealItem(int mealId, MealItemEntry item) async {
    print('addMealItem: Adicionando ${item.foodName} à refeição $mealId');

    try {
      // Obter ou criar food
      final foodId = await _getOrCreateFood(item.foodName);

      final data = {
        'meal_id': mealId,
        'food_id': foodId,
        'quantity': item.quantity,
        'unit_name': item.unitName,
        'kcal_override': item.kcal,
      };

      print('addMealItem: Dados a inserir: $data');

      await _supabase.from('meal_item').insert(data);
      print('addMealItem: Item adicionado com sucesso');
    } catch (e) {
      print('Erro ao adicionar item: $e');
      rethrow;
    }
  }

  /// Guarda refeição completa com itens
  Future<void> saveMealWithItems(MealEntry meal) async {
    final userId = _userId;
    if (userId == 0) {
      print('saveMealWithItems: userId é 0');
      throw Exception('Utilizador não autenticado');
    }

    print('saveMealWithItems: Guardando ${meal.mealType} com ${meal.items.length} itens');

    try {
      // Criar refeição
      final mealId = await saveMeal(meal);
      if (mealId == null) {
        throw Exception('Não foi possível criar a refeição');
      }

      // Adicionar itens
      for (final item in meal.items) {
        await addMealItem(mealId, item);
      }

      print('saveMealWithItems: Concluído com sucesso');
    } catch (e) {
      print('Erro ao guardar refeição completa: $e');
      rethrow;
    }
  }

  /// Atualiza uma refeição existente
  Future<void> updateMeal(MealEntry meal) async {
    if (meal.id == null) {
      throw Exception('ID da refeição não pode ser nulo');
    }

    print('updateMeal: Atualizando refeição ${meal.id}');

    try {
      // Atualizar dados da refeição
      await _supabase
          .from('meal')
          .update({
            'meal_type': meal.mealType,
            'notes': meal.notes,
          })
          .eq('meal_id', meal.id!);

      // Apagar itens antigos
      await _supabase
          .from('meal_item')
          .delete()
          .eq('meal_id', meal.id!);

      // Adicionar novos itens
      for (final item in meal.items) {
        await addMealItem(meal.id!, item);
      }

      print('updateMeal: Concluído com sucesso');
    } catch (e) {
      print('Erro ao atualizar refeição: $e');
      rethrow;
    }
  }

  /// Apaga refeição
  Future<void> deleteMeal(int mealId) async {
    print('deleteMeal: Apagando refeição $mealId');

    try {
      // Primeiro apagar itens (se não houver CASCADE)
      await _supabase
          .from('meal_item')
          .delete()
          .eq('meal_id', mealId);

      // Depois apagar refeição
      await _supabase
          .from('meal')
          .delete()
          .eq('meal_id', mealId);

      print('deleteMeal: Concluído com sucesso');
    } catch (e) {
      print('Erro ao apagar refeição: $e');
      rethrow;
    }
  }

  /// Obtém ou cria food
  Future<int> _getOrCreateFood(String name) async {
    try {
      print('_getOrCreateFood: Procurando "$name"');

      final existing = await _supabase
          .from('food')
          .select('food_id')
          .eq('name', name)
          .maybeSingle();

      if (existing != null) {
        print('_getOrCreateFood: Encontrado ID ${existing['food_id']}');
        return existing['food_id'] as int;
      }

      print('_getOrCreateFood: Criando novo food');
      final result = await _supabase
          .from('food')
          .insert({'name': name})
          .select('food_id')
          .single();

      print('_getOrCreateFood: Criado ID ${result['food_id']}');
      return result['food_id'] as int;
    } catch (e) {
      print('Erro ao obter/criar food: $e');
      // Retornar 1 como fallback (assumindo que existe um food com ID 1)
      return 1;
    }
  }

  /// Obtém calorias da semana para gráfico (otimizado - 1 query)
  Future<List<int>> getWeeklyCalories(DateTime endDate) async {
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final start = end.subtract(const Duration(days: 6));
    
    final startStr = start.toIso8601String().split('T')[0];
    final endStr = end.add(const Duration(days: 1)).toIso8601String().split('T')[0];

    print('getWeeklyCalories: De $startStr a $endStr (1 query)');

    try {
      // Buscar todas as refeições da semana numa única query
      // Nota: coluna é kcal_override, não kcal
      final response = await _supabase
          .from('meal')
          .select('meal_id, created_at, meal_item(kcal_override)')
          .eq('user_id', _userId)
          .gte('created_at', startStr)
          .lt('created_at', endStr);

      // Inicializar array com 7 dias
      final calories = List<int>.filled(7, 0);

      // Processar resultados
      for (final meal in response as List) {
        final createdAtStr = meal['created_at'] as String;
        final createdAt = DateTime.parse(createdAtStr);
        // Normalizar para usar apenas a data (sem horas)
        final mealDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
        final dayIndex = mealDate.difference(start).inDays;
        
        if (dayIndex >= 0 && dayIndex < 7) {
          final items = meal['meal_item'] as List? ?? [];
          for (final item in items) {
            // Coluna é kcal_override
            calories[dayIndex] += (item['kcal_override'] as num?)?.toInt() ?? 0;
          }
        }
      }

      print('getWeeklyCalories resultado: $calories');
      return calories;
    } catch (e) {
      print('Erro getWeeklyCalories: $e');
      return List.filled(7, 0);
    }
  }

  /// Procura alimentos por nome ou categoria
  Future<List<Map<String, dynamic>>> searchFoods(String query) async {
    try {
      final response = await _supabase
          .from('food')
          .select('food_id, name, icon, kcal_per_100g, category')
          .ilike('name', '%$query%')
          .order('name')
          .limit(30);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Erro ao procurar alimentos: $e');
      return [];
    }
  }

  /// Obtém alimentos por categoria
  Future<List<Map<String, dynamic>>> getFoodsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('food')
          .select('food_id, name, icon, kcal_per_100g, category')
          .eq('category', category)
          .order('name')
          .limit(50);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Erro ao obter alimentos por categoria: $e');
      return [];
    }
  }

  /// Obtém todas as categorias disponíveis
  Future<List<String>> getCategories() async {
    try {
      final response = await _supabase
          .from('food')
          .select('category')
          .not('category', 'is', null);

      final categories = (response as List)
          .map((e) => e['category'] as String?)
          .where((c) => c != null && c.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();
      
      categories.sort();
      return categories;
    } catch (e) {
      print('Erro ao obter categorias: $e');
      return [];
    }
  }

  /// Obtém alimentos populares/recentes
  Future<List<Map<String, dynamic>>> getPopularFoods() async {
    try {
      final response = await _supabase
          .from('food')
          .select('food_id, name, icon, kcal_per_100g, category')
          .order('name')
          .limit(20);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Erro ao obter alimentos populares: $e');
      return [];
    }
  }
}
