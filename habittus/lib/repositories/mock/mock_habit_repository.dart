import '../interfaces/habit_repository.dart';
import '../../models/habit.dart';

/// Implementação mock do repositório de hábitos
class MockHabitRepository implements HabitRepository {
  final List<Habit> _habits = [];
  final List<HabitLog> _logs = [];

  MockHabitRepository() {
    _populateMockData();
  }

  void _populateMockData() {
    final now = DateTime.now();
    final userId = 'mock_user_123';

    // Hábitos negativos (vícios)
    _habits.addAll([
      Habit(
        id: '1',
        userId: userId,
        name: 'Fumar',
        type: HabitType.negative,
        category: HabitCategory.smoking,
        description: 'Reduzir consumo de cigarros',
        emoji: '🚬',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Habit(
        id: '2',
        userId: userId,
        name: 'Álcool',
        type: HabitType.negative,
        category: HabitCategory.alcohol,
        description: 'Controlar consumo de bebidas alcoólicas',
        emoji: '🍺',
        createdAt: now.subtract(const Duration(days: 25)),
      ),
      Habit(
        id: '3',
        userId: userId,
        name: 'Redes Sociais',
        type: HabitType.negative,
        category: HabitCategory.socialMedia,
        description: 'Reduzir tempo em redes sociais',
        emoji: '📱',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
    ]);

    // Registros mock dos últimos dias
    _logs.addAll([
      // Fumar
      HabitLog(
        id: 'log1',
        habitId: '1',
        userId: userId,
        timestamp: now.subtract(const Duration(days: 1)),
        quantity: 5,
        mood: HabitMood.bad,
      ),
      HabitLog(
        id: 'log2',
        habitId: '1',
        userId: userId,
        timestamp: now.subtract(const Duration(days: 2)),
        quantity: 8,
        mood: HabitMood.veryBad,
      ),
      
      // Álcool
      HabitLog(
        id: 'log3',
        habitId: '2',
        userId: userId,
        timestamp: now.subtract(const Duration(days: 3)),
        quantity: 2,
        notes: 'Jantar com amigos',
        mood: HabitMood.neutral,
      ),

      // Redes Sociais
      HabitLog(
        id: 'log4',
        habitId: '3',
        userId: userId,
        timestamp: now.subtract(const Duration(hours: 5)),
        quantity: 120, // minutos
        mood: HabitMood.bad,
      ),
    ]);
  }

  @override
  Future<List<Habit>> getHabits(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _habits.where((h) => h.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<Habit>> getActiveHabits(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _habits
        .where((h) => h.userId == userId && h.isActive)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<Habit>> getHabitsByType(String userId, HabitType type) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _habits
        .where((h) => h.userId == userId && h.type == type && h.isActive)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Habit?> getHabitById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _habits.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addHabit(Habit habit) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _habits.add(habit);
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index] = _habits[index].copyWith(isActive: false);
    }
  }

  @override
  Future<List<HabitLog>> getHabitLogs(String habitId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _logs.where((log) => log.habitId == habitId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<List<HabitLog>> getHabitLogsByDateRange(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _logs
        .where((log) =>
            log.habitId == habitId &&
            log.timestamp.isAfter(startDate) &&
            log.timestamp.isBefore(endDate))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<void> addHabitLog(HabitLog log) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logs.add(log);
  }

  @override
  Future<void> updateHabitLog(HabitLog log) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _logs.indexWhere((l) => l.id == log.id);
    if (index != -1) {
      _logs[index] = log;
    }
  }

  @override
  Future<void> deleteHabitLog(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logs.removeWhere((log) => log.id == id);
  }

  @override
  Future<int> getTotalOccurrences(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final logs = await getHabitLogsByDateRange(habitId, startDate, endDate);
    return logs.length;
  }

  @override
  Future<int> getDaysWithoutOccurrence(String habitId) async {
    final logs = await getHabitLogs(habitId);
    if (logs.isEmpty) return 0;

    final lastOccurrence = logs.first.timestamp;
    final now = DateTime.now();
    return now.difference(lastOccurrence).inDays;
  }
}
