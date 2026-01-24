import 'package:flutter/foundation.dart';
import '../models/physical_activity.dart';
import '../repositories/interfaces/activity_repository.dart';

class ActivityController extends ChangeNotifier {
  final ActivityRepository _repo;

  ActivityController(this._repo);

  String _userId = 'mock_user_123';
  List<PhysicalActivity> _activities = [];
  bool _isLoading = false;
  String? _error;

  List<PhysicalActivity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalMinutes => _activities.fold(0, (sum, a) => sum + a.durationMinutes);
  int get totalCalories => _activities.fold(0, (sum, a) => sum + (a.caloriesBurned ?? 0));

  Future<void> loadActivitiesByDateRange(String userId, DateTime start, DateTime end) async {
    _userId = userId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activities = await _repo.getActivitiesByDateRange(userId, start, end);
    } catch (e) {
      _error = 'Erro ao carregar atividades: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addActivity(PhysicalActivity activity) async {
    try {
      await _repo.addActivity(activity);
      _activities = [..._activities, activity];
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao adicionar atividade: $e';
      notifyListeners();
    }
  }

  Future<void> updateActivity(PhysicalActivity activity) async {
    try {
      await _repo.updateActivity(activity);
      final index = _activities.indexWhere((a) => a.id == activity.id);
      if (index >= 0) {
        _activities = [..._activities]..[index] = activity;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erro ao atualizar atividade: $e';
      notifyListeners();
    }
  }

  Future<void> deleteActivity(String id) async {
    try {
      await _repo.deleteActivity(id);
      _activities = _activities.where((a) => a.id != id).toList();
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao remover atividade: $e';
      notifyListeners();
    }
  }
}
