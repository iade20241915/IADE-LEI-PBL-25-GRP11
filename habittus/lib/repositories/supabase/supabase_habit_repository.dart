import '../../core/database/supabase_service.dart';
import '../../models/habit.dart';
import '../interfaces/habit_repository.dart';

/// Implementação Supabase do repositório de hábitos
/// Alinhado com tabelas: habits, habit_types
class SupabaseHabitRepository implements HabitRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  int get _userId => _supabase.currentUserId ?? 0;
  String get _userIdStr => _userId.toString();

  @override
  Future<List<Habit>> getHabits(String userId) async {
    if (_userId == 0) return [];

    try {
      final response = await _supabase
          .from('habits')
          .select('*, habit_types(*)')
          .eq('user_id', _userId)
          .order('created_at', ascending: false);

      //if (response == null) return [];
      return (response as List).map((json) => _fromJson(json)).toList();
    } catch (e) {
      print('Erro ao obter hábitos: $e');
      return [];
    }
  }

  @override
  Future<List<Habit>> getActiveHabits(String userId) async {
    return getHabits(userId); // Todos são ativos por enquanto
  }

  @override
  Future<List<Habit>> getHabitsByType(String userId, HabitType type) async {
    final habits = await getHabits(userId);
    return habits.where((h) => h.type == type).toList();
  }

  @override
  Future<Habit?> getHabitById(String id) async {
    try {
      final response = await _supabase
          .from('habits')
          .select('*, habit_types(*)')
          .eq('habit_id', int.parse(id))
          .maybeSingle();

      if (response == null) return null;
      return _fromJson(response);
    } catch (e) {
      print('Erro ao obter hábito: $e');
      return null;
    }
  }

  @override
  Future<void> addHabit(Habit habit) async {
    if (_userId == 0) return;

    try {
      // Obter ou criar habit_type_id
      final typeId = await _getOrCreateHabitType(habit.category.label);

      await _supabase.from('habits').insert({
        'user_id': _userId,
        'habit_type_id': typeId,
        'created_at': habit.createdAt.toIso8601String(),
        'daysweek': 7,
        'timesday': 1,
        'moneysspent': 0,
        'notes': habit.description,
      });
    } catch (e) {
      print('Erro ao adicionar hábito: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    try {
      final typeId = await _getOrCreateHabitType(habit.category.label);

      await _supabase
          .from('habits')
          .update({'habit_type_id': typeId, 'notes': habit.description})
          .eq('habit_id', int.parse(habit.id));
    } catch (e) {
      print('Erro ao atualizar hábito: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    try {
      await _supabase.from('habits').delete().eq('habit_id', int.parse(id));
    } catch (e) {
      print('Erro ao apagar hábito: $e');
      rethrow;
    }
  }

  @override
  Future<List<HabitLog>> getHabitLogs(String habitId) async {
    // Não temos tabela de logs na BD atual
    return [];
  }

  @override
  Future<List<HabitLog>> getHabitLogsByDateRange(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return [];
  }

  @override
  Future<void> addHabitLog(HabitLog log) async {
    // Não implementado - BD não tem tabela de logs
  }

  @override
  Future<void> updateHabitLog(HabitLog log) async {
    // Não implementado
  }

  @override
  Future<void> deleteHabitLog(String id) async {
    // Não implementado
  }

  @override
  Future<int> getTotalOccurrences(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return 0;
  }

  @override
  Future<int> getDaysWithoutOccurrence(String habitId) async {
    final habit = await getHabitById(habitId);
    if (habit == null) return 0;
    return DateTime.now().difference(habit.createdAt).inDays;
  }

  /// Obtém contagem de hábitos por categoria
  Future<Map<String, int>> getHabitCountByCategory() async {
    final habits = await getHabits(_userIdStr);
    final counts = <String, int>{};

    for (final habit in habits) {
      final cat = habit.category.label;
      counts[cat] = (counts[cat] ?? 0) + 1;
    }

    return counts;
  }

  /// Obtém ou cria tipo de hábito
  Future<int> _getOrCreateHabitType(String typeName) async {
    try {
      final existing = await _supabase
          .from('habit_types')
          .select('habit_type_id')
          .eq('habit_type', typeName)
          .maybeSingle();

      if (existing != null) {
        return existing['habit_type_id'] as int;
      }

      // Criar novo tipo
      final result = await _supabase
          .from('habit_types')
          .insert({'habit_type': typeName})
          .select('habit_type_id')
          .single();

      return result['habit_type_id'] as int;
    } catch (e) {
      print('Erro ao obter/criar tipo de hábito: $e');
      return 1;
    }
  }

  /// Converte JSON da BD para Habit
  Habit _fromJson(Map<String, dynamic> json) {
    final typeData = json['habit_types'] as Map<String, dynamic>?;
    final typeName = typeData?['habit_type'] as String? ?? 'Outro';

    // Determinar categoria pelo nome
    final category = HabitCategory.values.firstWhere(
      (c) => c.label == typeName,
      orElse: () => HabitCategory.other,
    );

    return Habit(
      id: (json['habit_id'] as int).toString(),
      userId: (json['user_id'] as int).toString(),
      name: typeName,
      type: category.isNegative ? HabitType.negative : HabitType.positive,
      category: category,
      description: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isActive: true,
    );
  }
}
