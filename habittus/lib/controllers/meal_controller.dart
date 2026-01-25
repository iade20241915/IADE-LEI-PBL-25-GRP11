import 'package:flutter/foundation.dart';
import '../repositories/supabase/supabase_meal_repository.dart';

enum MealSaveStatus { idle, saving, saved, error }

class MealController extends ChangeNotifier {
  final SupabaseMealRepository _repo = SupabaseMealRepository();

  DateTime selectedDate = DateTime.now();
  List<MealEntry> _meals = [];
  List<int> _weeklyCalories = List.filled(7, 0);
  bool _isLoading = false;
  MealSaveStatus _saveStatus = MealSaveStatus.idle;
  String? _errorMessage;
  
  // Cache para evitar chamadas redundantes
  DateTime? _lastLoadedDate;
  bool _hasLoadedOnce = false;

  List<MealEntry> get meals => _meals;
  List<int> get weeklyCalories => _weeklyCalories;
  bool get isLoading => _isLoading;
  MealSaveStatus get saveStatus => _saveStatus;
  String? get errorMessage => _errorMessage;

  int get todayCalories => _meals.fold<int>(0, (sum, m) => sum + m.totalKcal);
  int get mealsCount => _meals.length;

  /// Valores normalizados para gráfico (baseado em 2000kcal)
  List<double> get weeklyChartValues {
    return _weeklyCalories.map((cal) => (cal / 2000.0).clamp(0.0, 1.5)).toList();
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

  Future<void> load(DateTime date, {bool forceReload = false}) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    // Verificar se já carregou esta data (evitar chamadas redundantes)
    if (!forceReload && _hasLoadedOnce && _lastLoadedDate == normalizedDate) {
      print('MealController.load: Cache hit para $normalizedDate - ignorando');
      return;
    }
    
    selectedDate = normalizedDate;
    _isLoading = true;
    _saveStatus = MealSaveStatus.idle;
    notifyListeners();

    try {
      print('MealController.load: Carregando para $selectedDate');
      
      // Carregar em paralelo (2 queries em vez de 8)
      final results = await Future.wait([
        _repo.getForDate(selectedDate),
        _repo.getWeeklyCalories(selectedDate),
      ]);
      
      _meals = results[0] as List<MealEntry>;
      _weeklyCalories = results[1] as List<int>;
      
      _lastLoadedDate = normalizedDate;
      _hasLoadedOnce = true;
      _errorMessage = null;
      print('MealController.load: Carregadas ${_meals.length} refeições');
    } catch (e) {
      _errorMessage = 'Erro ao carregar: $e';
      print('MealController.load error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Força recarga dos dados (após adicionar/editar/apagar)
  Future<void> _reloadData() async {
    try {
      final results = await Future.wait([
        _repo.getForDate(selectedDate),
        _repo.getWeeklyCalories(selectedDate),
      ]);
      
      _meals = results[0] as List<MealEntry>;
      _weeklyCalories = results[1] as List<int>;
      
      // Manter cache válido após reload
      _lastLoadedDate = selectedDate;
      _hasLoadedOnce = true;
    } catch (e) {
      print('MealController._reloadData error: $e');
    }
  }

  Future<void> addMeal(MealEntry meal) async {
    _saveStatus = MealSaveStatus.saving;
    notifyListeners();

    try {
      print('MealController.addMeal: Adicionando ${meal.mealType} com ${meal.items.length} itens');
      await _repo.saveMealWithItems(meal);
      
      // Recarregar dados (2 queries em paralelo)
      await _reloadData();
      
      _saveStatus = MealSaveStatus.saved;
      _errorMessage = null;
      print('MealController.addMeal: Sucesso! Total refeições: ${_meals.length}');
    } catch (e) {
      _saveStatus = MealSaveStatus.error;
      _errorMessage = 'Erro ao adicionar: $e';
      print('MealController.addMeal error: $e');
    }

    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      if (_saveStatus == MealSaveStatus.saved) {
        _saveStatus = MealSaveStatus.idle;
        notifyListeners();
      }
    });
  }

  Future<void> updateMeal(MealEntry meal) async {
    _saveStatus = MealSaveStatus.saving;
    notifyListeners();

    try {
      print('MealController.updateMeal: Atualizando ${meal.id}');
      await _repo.updateMeal(meal);
      
      // Recarregar dados (2 queries em paralelo)
      await _reloadData();
      
      _saveStatus = MealSaveStatus.saved;
      _errorMessage = null;
      print('MealController.updateMeal: Sucesso!');
    } catch (e) {
      _saveStatus = MealSaveStatus.error;
      _errorMessage = 'Erro ao atualizar: $e';
      print('MealController.updateMeal error: $e');
    }

    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      if (_saveStatus == MealSaveStatus.saved) {
        _saveStatus = MealSaveStatus.idle;
        notifyListeners();
      }
    });
  }

  Future<void> deleteMeal(int mealId) async {
    try {
      print('MealController.deleteMeal: Apagando $mealId');
      await _repo.deleteMeal(mealId);
      _meals = _meals.where((m) => m.id != mealId).toList();
      
      // Recarregar só as calorias semanais
      _weeklyCalories = await _repo.getWeeklyCalories(selectedDate);
      
      notifyListeners();
      print('MealController.deleteMeal: Sucesso!');
    } catch (e) {
      _errorMessage = 'Erro ao remover: $e';
      print('MealController.deleteMeal error: $e');
      notifyListeners();
    }
  }

  void clearStatus() {
    _saveStatus = MealSaveStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
