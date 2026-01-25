import 'package:flutter/foundation.dart';
import '../models/habit.dart';
import '../repositories/interfaces/habit_repository.dart';

enum HabitSaveStatus { idle, saving, saved, error }

class HabitController extends ChangeNotifier {
  final HabitRepository _repo;

  HabitController(this._repo);

  List<Habit> _habits = [];
  List<HabitLog> _currentLogs = [];
  String? _currentHabitId;
  bool _isLoading = false;
  HabitSaveStatus _saveStatus = HabitSaveStatus.idle;
  String? _error;

  List<Habit> get habits => _habits;
  List<HabitLog> get currentLogs => _currentLogs;
  List<Habit> get positiveHabits => _habits.where((h) => h.type == HabitType.positive).toList();
  List<Habit> get negativeHabits => _habits.where((h) => h.type == HabitType.negative).toList();
  bool get isLoading => _isLoading;
  HabitSaveStatus get saveStatus => _saveStatus;
  String? get error => _error;

  int get totalHabits => _habits.length;
  int get totalPositive => positiveHabits.length;
  int get totalNegative => negativeHabits.length;

  /// Dados para gráfico de categorias
  Map<String, int> get categoryCount {
    final counts = <String, int>{};
    for (final habit in _habits) {
      final cat = habit.category.label;
      counts[cat] = (counts[cat] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> load() async {
    _isLoading = true;
    _saveStatus = HabitSaveStatus.idle;
    notifyListeners();

    try {
      _habits = await _repo.getHabits('');
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar hábitos: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Alias para compatibilidade
  Future<void> loadHabits(String userId) async {
    await load();
  }

  /// Carrega logs de um hábito específico
  Future<void> loadHabitLogs(String habitId) async {
    _currentHabitId = habitId;
    _isLoading = true;
    notifyListeners();

    try {
      _currentLogs = await _repo.getHabitLogs(habitId);
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar registos: $e';
      _currentLogs = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Adiciona log de hábito
  Future<void> addHabitLog(HabitLog log) async {
    _saveStatus = HabitSaveStatus.saving;
    notifyListeners();

    try {
      await _repo.addHabitLog(log);
      _currentLogs = [..._currentLogs, log];
      _saveStatus = HabitSaveStatus.saved;
      _error = null;
    } catch (e) {
      _saveStatus = HabitSaveStatus.error;
      _error = 'Erro ao adicionar registo: $e';
    }

    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      if (_saveStatus == HabitSaveStatus.saved) {
        _saveStatus = HabitSaveStatus.idle;
        notifyListeners();
      }
    });
  }

  /// Remove log de hábito
  Future<void> deleteHabitLog(String logId) async {
    try {
      await _repo.deleteHabitLog(logId);
      _currentLogs = _currentLogs.where((l) => l.id != logId).toList();
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao remover registo: $e';
      notifyListeners();
    }
  }

  Future<void> addHabit(Habit habit) async {
    _saveStatus = HabitSaveStatus.saving;
    notifyListeners();

    try {
      await _repo.addHabit(habit);
      _habits = [..._habits, habit];
      _saveStatus = HabitSaveStatus.saved;
      _error = null;
    } catch (e) {
      _saveStatus = HabitSaveStatus.error;
      _error = 'Erro ao adicionar: $e';
    }

    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      if (_saveStatus == HabitSaveStatus.saved) {
        _saveStatus = HabitSaveStatus.idle;
        notifyListeners();
      }
    });
  }

  Future<void> updateHabit(Habit habit) async {
    _saveStatus = HabitSaveStatus.saving;
    notifyListeners();

    try {
      await _repo.updateHabit(habit);
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index >= 0) {
        _habits = [..._habits]..[index] = habit;
      }
      _saveStatus = HabitSaveStatus.saved;
      _error = null;
    } catch (e) {
      _saveStatus = HabitSaveStatus.error;
      _error = 'Erro ao atualizar: $e';
    }

    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      if (_saveStatus == HabitSaveStatus.saved) {
        _saveStatus = HabitSaveStatus.idle;
        notifyListeners();
      }
    });
  }

  Future<void> deleteHabit(String id) async {
    try {
      await _repo.deleteHabit(id);
      _habits = _habits.where((h) => h.id != id).toList();
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao remover: $e';
      notifyListeners();
    }
  }

  Future<int> getDaysWithoutHabit(String habitId) async {
    return _repo.getDaysWithoutOccurrence(habitId);
  }

  void clearStatus() {
    _saveStatus = HabitSaveStatus.idle;
    _error = null;
    notifyListeners();
  }
}
