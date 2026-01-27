import 'package:flutter/foundation.dart';
import '../models/water_log.dart';
import '../repositories/interfaces/water_repository.dart';
import '../repositories/supabase/supabase_water_repository.dart';

enum SaveStatus { idle, saving, saved, error }

class WaterController extends ChangeNotifier {
  final WaterRepository _repo;

  WaterController(this._repo);

  DateTime selectedDate = DateTime.now();
  static const int defaultMlPerCup = 250;
  static const int dailyGoalMl = 2000;

  int _totalMl = 0;
  List<WaterLog> weekLogs = const [];
  bool _isLoading = false;
  SaveStatus _saveStatus = SaveStatus.idle;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  SaveStatus get saveStatus => _saveStatus;
  String? get errorMessage => _errorMessage;
  int get totalMl => _totalMl;
  int get cups => _totalMl ~/ defaultMlPerCup;
  double get progress => (totalMl / dailyGoalMl).clamp(0.0, 1.0);

  /// Valores normalizados para gráfico (0.0 a 1.0)
  List<double> get weeklyChartValues {
    return weekLogs.map((log) {
      return (log.totalMl / dailyGoalMl).clamp(0.0, 1.0);
    }).toList();
  }

  /// Labels dos dias da semana
  List<String> get weeklyLabels {
    const dayNames = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    return weekLogs.map((log) => dayNames[log.date.weekday % 7]).toList();
  }

  Future<void> load(DateTime date) async {
    _isLoading = true;
    _saveStatus = SaveStatus.idle;
    notifyListeners();

    selectedDate = DateTime(date.year, date.month, date.day);
    final log = await _repo.getForDate(selectedDate);
    _totalMl = log?.totalMl ?? 0;
    await _loadWeek();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadWeek() async {
    final end = selectedDate;
    final start = end.subtract(const Duration(days: 6));
    final List<WaterLog> logs = [];
    for (int i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));
      final log = await _repo.getForDate(day);
      logs.add(log ?? WaterLog(date: day, amountMl: 0, cups: 0));
    }
    weekLogs = List.unmodifiable(logs);
  }

  /// Toggle de copo (para grid de copos)
  Future<void> toggleCup(int index, {required int gridSize}) async {
    final newCups = index < cups ? index : (index + 1).clamp(0, gridSize);
    final newTotalMl = newCups * defaultMlPerCup;

    _totalMl = newTotalMl;
    _saveStatus = SaveStatus.saving;
    notifyListeners();

    try {
      // Usar saveOrUpdateDaily se disponível
      if (_repo is SupabaseWaterRepository) {
        await (_repo).saveOrUpdateDaily(
          WaterLog(date: selectedDate, amountMl: newTotalMl, cups: newCups),
        );
      } else {
        await _repo.save(
          WaterLog(date: selectedDate, amountMl: newTotalMl, cups: newCups),
        );
      }
      await _loadWeek();
      _saveStatus = SaveStatus.saved;
      _errorMessage = null;
    } catch (e) {
      _saveStatus = SaveStatus.error;
      _errorMessage = 'Erro ao guardar: $e';
    }

    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      if (_saveStatus == SaveStatus.saved) {
        _saveStatus = SaveStatus.idle;
        notifyListeners();
      }
    });
  }

  /// Adiciona quantidade de água
  Future<void> addMl(int ml, {WaterSource source = WaterSource.manual}) async {
    _totalMl += ml;
    _saveStatus = SaveStatus.saving;
    notifyListeners();

    try {
      if (_repo is SupabaseWaterRepository) {
        await (_repo).addWater(ml, source: source);
      } else {
        await _repo.save(WaterLog(date: selectedDate, amountMl: _totalMl));
      }
      await _loadWeek();
      _saveStatus = SaveStatus.saved;
      _errorMessage = null;
    } catch (e) {
      _totalMl -= ml; // Reverter
      _saveStatus = SaveStatus.error;
      _errorMessage = 'Erro ao guardar: $e';
    }

    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      if (_saveStatus == SaveStatus.saved) {
        _saveStatus = SaveStatus.idle;
        notifyListeners();
      }
    });
  }

  void clearStatus() {
    _saveStatus = SaveStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
