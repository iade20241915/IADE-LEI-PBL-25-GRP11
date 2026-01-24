import 'package:flutter/foundation.dart';
import '../models/habit.dart';
import '../repositories/interfaces/habit_repository.dart';

class HabitController extends ChangeNotifier {
  final HabitRepository _repo;

  HabitController(this._repo);

  String _userId = 'mock_user_123';
  List<Habit> _habits = [];
  List<HabitLog> _currentLogs = [];
  bool _isLoading = false;
  String? _error;

  List<Habit> get habits => _habits;
  List<Habit> get positiveHabits => _habits.where((h) => h.type == HabitType.positive).toList();
  List<Habit> get negativeHabits => _habits.where((h) => h.type == HabitType.negative).toList();
  List<HabitLog> get currentLogs => _currentLogs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHabits(String userId) async {
    _userId = userId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _habits = await _repo.getActiveHabits(userId);
    } catch (e) {
      _error = 'Erro ao carregar hábitos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHabitLogs(String habitId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      _currentLogs = await _repo.getHabitLogsByDateRange(habitId, startOfMonth, now);
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar logs: $e';
      notifyListeners();
    }
  }

  Future<void> addHabit(Habit habit) async {
    try {
      await _repo.addHabit(habit);
      await loadHabits(_userId);
    } catch (e) {
      _error = 'Erro ao adicionar hábito: $e';
      notifyListeners();
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await _repo.updateHabit(habit);
      await loadHabits(_userId);
    } catch (e) {
      _error = 'Erro ao atualizar hábito: $e';
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String id) async {
    try {
      await _repo.deleteHabit(id);
      await loadHabits(_userId);
    } catch (e) {
      _error = 'Erro ao remover hábito: $e';
      notifyListeners();
    }
  }

  Future<void> addHabitLog(HabitLog log) async {
    try {
      await _repo.addHabitLog(log);
      await loadHabitLogs(log.habitId);
    } catch (e) {
      _error = 'Erro ao adicionar log: $e';
      notifyListeners();
    }
  }

  Future<void> deleteHabitLog(String id) async {
    try {
      await _repo.deleteHabitLog(id);
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao remover log: $e';
      notifyListeners();
    }
  }

  Future<int> getDaysWithoutOccurrence(String habitId) async {
    try {
      return await _repo.getDaysWithoutOccurrence(habitId);
    } catch (e) {
      _error = 'Erro ao calcular dias: $e';
      return 0;
    }
  }
}
