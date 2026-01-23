import 'package:flutter/foundation.dart';
import '../models/physical_activity.dart';
import '../repositories/interfaces/activity_repository.dart';

/// Controller para gerenciar atividades físicas usando Provider
class ActivityController extends ChangeNotifier {
  final ActivityRepository _repository;

  List<PhysicalActivity> _activities = [];
  bool _isLoading = false;
  String? _error;

  ActivityController(this._repository);

  List<PhysicalActivity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carrega todas as atividades do usuário
  Future<void> loadActivities(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activities = await _repository.getActivities(userId);
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar atividades: $e';
      _activities = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega atividades de um período específico
  Future<void> loadActivitiesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activities = await _repository.getActivitiesByDateRange(
        userId,
        startDate,
        endDate,
      );
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar atividades: $e';
      _activities = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adiciona uma nova atividade
  Future<void> addActivity(PhysicalActivity activity) async {
    try {
      await _repository.addActivity(activity);
      _activities.insert(0, activity);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao adicionar atividade: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Atualiza uma atividade existente
  Future<void> updateActivity(PhysicalActivity activity) async {
    try {
      await _repository.updateActivity(activity);
      final index = _activities.indexWhere((a) => a.id == activity.id);
      if (index != -1) {
        _activities[index] = activity;
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao atualizar atividade: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Remove uma atividade
  Future<void> deleteActivity(String id) async {
    try {
      await _repository.deleteActivity(id);
      _activities.removeWhere((a) => a.id == id);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao remover atividade: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Calcula total de minutos no período
  Future<int> getTotalMinutes(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _repository.getTotalMinutes(userId, startDate, endDate);
    } catch (e) {
      _error = 'Erro ao calcular minutos: $e';
      notifyListeners();
      return 0;
    }
  }

  /// Calcula total de calorias no período
  Future<int> getTotalCalories(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _repository.getTotalCalories(userId, startDate, endDate);
    } catch (e) {
      _error = 'Erro ao calcular calorias: $e';
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
