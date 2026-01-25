import 'package:flutter/foundation.dart';
import '../models/physical_activity.dart';
import '../repositories/interfaces/activity_repository.dart';
import '../repositories/supabase/supabase_activity_repository.dart';

enum ActivitySaveStatus { idle, saving, saved, error }

/// ============================================================
/// CONTROLLER DE ATIVIDADE FÍSICA
/// ============================================================
/// Gere o estado das atividades físicas e comunica com o repositório
/// Implementa cache para evitar queries redundantes
/// ============================================================
class ActivityController extends ChangeNotifier {
  final ActivityRepository _repo;

  ActivityController(this._repo);

  DateTime selectedDate = DateTime.now();
  List<PhysicalActivity> _activities = [];
  List<int> _weeklyMinutes = List.filled(7, 0);
  bool _isLoading = false;
  ActivitySaveStatus _saveStatus = ActivitySaveStatus.idle;
  String? _error;
  
  // Cache para evitar recarregamentos desnecessários
  DateTime? _lastLoadedDate;
  bool _hasLoadedOnce = false;

  List<PhysicalActivity> get activities => _activities;
  List<int> get weeklyMinutes => _weeklyMinutes;
  bool get isLoading => _isLoading;
  ActivitySaveStatus get saveStatus => _saveStatus;
  String? get error => _error;

  int get totalMinutes => _activities.fold(0, (sum, a) => sum + a.durationMinutes);
  int get totalCalories => _activities.fold(0, (sum, a) => sum + (a.caloriesBurned ?? 0));
  
  /// Minutos do dia selecionado (último dia da semana no array)
  int get todayMinutes {
    // Encontrar o índice do dia selecionado no array semanal
    final start = selectedDate.subtract(const Duration(days: 6));
    final dayIndex = selectedDate.difference(start).inDays;
    if (dayIndex >= 0 && dayIndex < 7) {
      return _weeklyMinutes[dayIndex];
    }
    return _weeklyMinutes.isNotEmpty ? _weeklyMinutes.last : 0;
  }

  /// Valores normalizados para gráfico (0.0 a 1.5, baseado em 60min ideal)
  List<double> get weeklyChartValues {
    return _weeklyMinutes.map((mins) => (mins / 60.0).clamp(0.0, 1.5)).toList();
  }

  /// Labels dos dias da semana
  List<String> get weeklyLabels {
    const dayNames = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    final labels = <String>[];
    final start = selectedDate.subtract(const Duration(days: 6));
    for (int i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));
      labels.add(dayNames[day.weekday % 7]);
    }
    return labels;
  }

  // ============================================================
  // LOAD - Carregar atividades para uma data
  // ============================================================
  Future<void> load(DateTime date, {bool forceReload = false}) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    // Cache: evitar recarregar mesma data
    if (!forceReload && _hasLoadedOnce && _lastLoadedDate == normalizedDate) {
      print('[ACTIVITY CONTROLLER] Cache hit para $normalizedDate - ignorando');
      return;
    }
    
    selectedDate = normalizedDate;
    _isLoading = true;
    _saveStatus = ActivitySaveStatus.idle;
    notifyListeners();

    print('[ACTIVITY CONTROLLER] Carregando para $selectedDate');

    try {
      // Carregar atividades do dia e semana em paralelo
      await Future.wait([
        _loadDayActivities(),
        _loadWeekMinutes(),
      ]);
      
      _lastLoadedDate = normalizedDate;
      _hasLoadedOnce = true;
      _error = null;
      
      print('[ACTIVITY CONTROLLER] Carregadas ${_activities.length} atividades, semana: $_weeklyMinutes');
    } catch (e) {
      _error = 'Erro ao carregar: $e';
      print('[ACTIVITY CONTROLLER ERROR] $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Carrega atividades do dia selecionado
  Future<void> _loadDayActivities() async {
    final dayStart = selectedDate;
    final dayEnd = selectedDate.add(const Duration(days: 1));
    _activities = await _repo.getActivitiesByDateRange('', dayStart, dayEnd);
  }

  /// Carrega minutos da semana para gráfico
  Future<void> _loadWeekMinutes() async {
    if (_repo is SupabaseActivityRepository) {
      _weeklyMinutes = await (_repo as SupabaseActivityRepository).getWeeklyMinutes(selectedDate);
    } else {
      // Fallback para outros repositórios
      _weeklyMinutes = List.filled(7, 0);
      final start = selectedDate.subtract(const Duration(days: 6));
      for (int i = 0; i < 7; i++) {
        final day = start.add(Duration(days: i));
        final dayStart = DateTime(day.year, day.month, day.day);
        final dayEnd = dayStart.add(const Duration(days: 1));
        final dayActivities = await _repo.getActivitiesByDateRange('', dayStart, dayEnd);
        _weeklyMinutes[i] = dayActivities.fold(0, (sum, a) => sum + a.durationMinutes);
      }
    }
  }

  /// Alias para compatibilidade com código existente
  Future<void> loadActivitiesByDateRange(String userId, DateTime start, DateTime end) async {
    await load(start);
  }

  /// Força recarga dos dados após alterações
  Future<void> _reloadData() async {
    print('[ACTIVITY CONTROLLER] Recarregando dados após alteração');
    try {
      await Future.wait([
        _loadDayActivities(),
        _loadWeekMinutes(),
      ]);
      _lastLoadedDate = selectedDate;
      _hasLoadedOnce = true;
    } catch (e) {
      print('[ACTIVITY CONTROLLER] Erro ao recarregar: $e');
    }
  }

  // ============================================================
  // ADD - Adicionar nova atividade
  // ============================================================
  Future<void> addActivity(PhysicalActivity activity) async {
    _saveStatus = ActivitySaveStatus.saving;
    notifyListeners();

    print('[ACTIVITY CONTROLLER] Adicionando ${activity.activityType.label}');

    try {
      await _repo.addActivity(activity);
      
      // Recarregar dados para atualizar gráfico
      await _reloadData();
      
      _saveStatus = ActivitySaveStatus.saved;
      _error = null;
      print('[ACTIVITY CONTROLLER] Atividade adicionada! Total: ${_activities.length}');
    } catch (e) {
      _saveStatus = ActivitySaveStatus.error;
      _error = 'Erro ao adicionar: $e';
      print('[ACTIVITY CONTROLLER ERROR] $e');
    }

    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      if (_saveStatus == ActivitySaveStatus.saved) {
        _saveStatus = ActivitySaveStatus.idle;
        notifyListeners();
      }
    });
  }

  // ============================================================
  // UPDATE - Atualizar atividade existente
  // ============================================================
  Future<void> updateActivity(PhysicalActivity activity) async {
    _saveStatus = ActivitySaveStatus.saving;
    notifyListeners();

    print('[ACTIVITY CONTROLLER] Atualizando activity_id=${activity.id}');

    try {
      await _repo.updateActivity(activity);
      
      // Recarregar dados para atualizar gráfico
      await _reloadData();
      
      _saveStatus = ActivitySaveStatus.saved;
      _error = null;
      print('[ACTIVITY CONTROLLER] Atividade atualizada!');
    } catch (e) {
      _saveStatus = ActivitySaveStatus.error;
      _error = 'Erro ao atualizar: $e';
      print('[ACTIVITY CONTROLLER ERROR] $e');
    }

    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      if (_saveStatus == ActivitySaveStatus.saved) {
        _saveStatus = ActivitySaveStatus.idle;
        notifyListeners();
      }
    });
  }

  // ============================================================
  // DELETE - Apagar atividade
  // ============================================================
  Future<void> deleteActivity(String id) async {
    print('[ACTIVITY CONTROLLER] Apagando activity_id=$id');
    
    try {
      await _repo.deleteActivity(id);
      
      // Recarregar dados para atualizar gráfico
      await _reloadData();
      
      print('[ACTIVITY CONTROLLER] Atividade apagada!');
    } catch (e) {
      _error = 'Erro ao remover: $e';
      print('[ACTIVITY CONTROLLER ERROR] $e');
    }
    
    notifyListeners();
  }

  void clearStatus() {
    _saveStatus = ActivitySaveStatus.idle;
    _error = null;
    notifyListeners();
  }
}
