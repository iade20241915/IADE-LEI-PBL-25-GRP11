import '../../models/habit.dart';

/// Interface para repositório de hábitos e vícios
abstract class HabitRepository {
  /// Busca todos os hábitos de um usuário
  Future<List<Habit>> getHabits(String userId);

  /// Busca hábitos ativos de um usuário
  Future<List<Habit>> getActiveHabits(String userId);

  /// Busca hábitos por tipo (positivo/negativo)
  Future<List<Habit>> getHabitsByType(String userId, HabitType type);

  /// Busca um hábito específico por ID
  Future<Habit?> getHabitById(String id);

  /// Adiciona um novo hábito
  Future<void> addHabit(Habit habit);

  /// Atualiza um hábito existente
  Future<void> updateHabit(Habit habit);

  /// Remove um hábito (soft delete - marca como inativo)
  Future<void> deleteHabit(String id);

  /// Busca registros de um hábito
  Future<List<HabitLog>> getHabitLogs(String habitId);

  /// Busca registros de um hábito em um período
  Future<List<HabitLog>> getHabitLogsByDateRange(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Adiciona um registro de ocorrência
  Future<void> addHabitLog(HabitLog log);

  /// Atualiza um registro
  Future<void> updateHabitLog(HabitLog log);

  /// Remove um registro
  Future<void> deleteHabitLog(String id);

  /// Conta total de ocorrências em um período
  Future<int> getTotalOccurrences(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Calcula dias sem ocorrência (streak)
  Future<int> getDaysWithoutOccurrence(String habitId);
}
