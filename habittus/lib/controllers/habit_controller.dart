import 'package:flutter/foundation.dart';
import '../models/habit.dart';
import '../repositories/interfaces/habit_repository.dart';

/// Controller para gerenciar hábitos e vícios usando Provider
class HabitController extends ChangeNotifier {
  final HabitRepository _repository;

  List<Habit> _habits = [];
  List<HabitLog> _currentLogs = [];
  bool _isLoading = false;
  String? _error;

  HabitController(this._repository);

  List<Habit> get habits => _habits;
  List<HabitLog> get currentLogs => _currentLogs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Hábitos negativos (vícios)
  List<Habit> get negativeHabits =>
      _habits.where((h) => h.type == HabitType.negative && h.isActive).toList();

  /// Hábitos positivos
  List<Habit> get positiveHabits =>
      _habits.where((h) => h.type == HabitType.positive && h.isActive).toList();

  /// Carrega todos os hábitos do usuário
  Future<void> loadHabits(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _habits = await _repository.getActiveHabits(userId);
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar hábitos: $e';
      _habits = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega hábitos por tipo
  Future<void> loadHabitsByType(String userId, HabitType type) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _habits = await _repository.getHabitsByType(userId, type);
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar hábitos: $e';
      _habits = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adiciona um novo hábito
  Future<void> addHabit(Habit habit) async {
    try {
      await _repository.addHabit(habit);
      _habits.insert(0, habit);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao adicionar hábito: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Atualiza um hábito existente
  Future<void> updateHabit(Habit habit) async {
    try {
      await _repository.updateHabit(habit);
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = habit;
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao atualizar hábito: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Remove um hábito
  Future<void> deleteHabit(String id) async {
    try {
      await _repository.deleteHabit(id);
      _habits.removeWhere((h) => h.id == id);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao remover hábito: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Carrega registros de um hábito
  Future<void> loadHabitLogs(String habitId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentLogs = await _repository.getHabitLogs(habitId);
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar registros: $e';
      _currentLogs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega registros em um período
  Future<void> loadHabitLogsByDateRange(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      _currentLogs = await _repository.getHabitLogsByDateRange(
        habitId,
        startDate,
        endDate,
      );
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar registros: $e';
      _currentLogs = [];
      notifyListeners();
    }
  }

  /// Adiciona um registro de ocorrência
  Future<void> addHabitLog(HabitLog log) async {
    try {
      await _repository.addHabitLog(log);
      _currentLogs.insert(0, log);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao adicionar registro: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Atualiza um registro
  Future<void> updateHabitLog(HabitLog log) async {
    try {
      await _repository.updateHabitLog(log);
      final index = _currentLogs.indexWhere((l) => l.id == log.id);
      if (index != -1) {
        _currentLogs[index] = log;
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao atualizar registro: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Remove um registro
  Future<void> deleteHabitLog(String id) async {
    try {
      await _repository.deleteHabitLog(id);
      _currentLogs.removeWhere((log) => log.id == id);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao remover registro: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Conta ocorrências em um período
  Future<int> getTotalOccurrences(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _repository.getTotalOccurrences(habitId, startDate, endDate);
    } catch (e) {
      _error = 'Erro ao calcular ocorrências: $e';
      notifyListeners();
      return 0;
    }
  }

  /// Dias sem ocorrência
  Future<int> getDaysWithoutOccurrence(String habitId) async {
    try {
      return await _repository.getDaysWithoutOccurrence(habitId);
    } catch (e) {
      _error = 'Erro ao calcular dias limpos: $e';
      notifyListeners();
      return 0;
    }
  }

  /// Limpa o erro
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
