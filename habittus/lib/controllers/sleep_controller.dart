import 'package:flutter/foundation.dart';
import '../models/sleep_log.dart';
import '../repositories/interfaces/sleep_repository.dart';

enum SleepSaveStatus { idle, saving, saved, error }

class SleepController extends ChangeNotifier {
  final SleepRepository _repo;

  SleepController(this._repo);

  DateTime selectedDate = DateTime.now();
  Duration sleepDuration = const Duration(hours: 7, minutes: 30);
  DateTime? _startTime;
  DateTime? _endTime;
  int qualityScore = 3;
  List<SleepLog> weekLogs = const [];
  bool _isLoading = false;
  SleepSaveStatus _saveStatus = SleepSaveStatus.idle;
  String? _errorMessage;

  static const int idealSleepMinutes = 480; // 8 horas

  bool get isLoading => _isLoading;
  SleepSaveStatus get saveStatus => _saveStatus;
  String? get errorMessage => _errorMessage;
  int get sleepMinutes => sleepDuration.inMinutes;
  DateTime? get startTime => _startTime;
  DateTime? get endTime => _endTime;
  
  String get sleepFormatted {
    final hours = sleepDuration.inHours;
    final mins = sleepDuration.inMinutes % 60;
    return '${hours}h${mins.toString().padLeft(2, '0')}';
  }

  /// Valores normalizados para gráfico (0.0 a 1.0, baseado em 8h ideal)
  List<double> get weeklyChartValues {
    return weekLogs.map((log) {
      return (log.durationMinutes / idealSleepMinutes).clamp(0.0, 1.2);
    }).toList();
  }

  /// Labels dos dias da semana
  List<String> get weeklyLabels {
    const dayNames = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    return weekLogs.map((log) => dayNames[log.date.weekday % 7]).toList();
  }

  /// Horas formatadas para mostrar no gráfico
  List<String> get weeklyHoursLabels {
    return weekLogs.map((log) {
      if (log.durationMinutes == 0) return '';
      final hours = log.durationMinutes ~/ 60;
      final mins = log.durationMinutes % 60;
      return '${hours}h${mins > 0 ? mins.toString().padLeft(2, '0') : ''}';
    }).toList();
  }

  Future<void> load(DateTime date) async {
    _isLoading = true;
    _saveStatus = SleepSaveStatus.idle;
    notifyListeners();

    selectedDate = DateTime(date.year, date.month, date.day);
    final log = await _repo.getForDate(selectedDate);
    if (log != null) {
      sleepDuration = Duration(minutes: log.durationMinutes);
      qualityScore = log.quality;
      _startTime = log.startTime;
      _endTime = log.endTime;
    } else {
      sleepDuration = const Duration(hours: 7, minutes: 30);
      qualityScore = 3;
      _startTime = null;
      _endTime = null;
    }
    await _loadWeek();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadWeek() async {
    final end = selectedDate;
    final start = end.subtract(const Duration(days: 6));
    final List<SleepLog> logs = [];
    for (int i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));
      final log = await _repo.getForDate(day);
      logs.add(log ?? SleepLog(date: day, durationMinutes: 0, quality: 0));
    }
    weekLogs = List.unmodifiable(logs);
  }

  void setSleepDuration(Duration duration) {
    sleepDuration = duration;
    notifyListeners();
  }

  void setTimes(DateTime start, DateTime end) {
    _startTime = start;
    _endTime = end;
    sleepDuration = Duration(minutes: end.difference(start).inMinutes.abs());
    notifyListeners();
  }

  void setQuality(int quality) {
    qualityScore = quality;
    notifyListeners();
  }

  Future<void> save() async {
    _saveStatus = SleepSaveStatus.saving;
    notifyListeners();

    try {
      // Calcular horários se não definidos
      final now = DateTime.now();
      final endTime = _endTime ?? DateTime(selectedDate.year, selectedDate.month, selectedDate.day, now.hour, now.minute);
      final startTime = _startTime ?? endTime.subtract(sleepDuration);

      await _repo.save(SleepLog(
        date: selectedDate,
        startTime: startTime,
        endTime: endTime,
        durationMinutes: sleepDuration.inMinutes,
        quality: qualityScore,
      ));
      await _loadWeek();
      _saveStatus = SleepSaveStatus.saved;
      _errorMessage = null;
    } catch (e) {
      _saveStatus = SleepSaveStatus.error;
      _errorMessage = 'Erro ao guardar: $e';
    }
    
    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      if (_saveStatus == SleepSaveStatus.saved) {
        _saveStatus = SleepSaveStatus.idle;
        notifyListeners();
      }
    });
  }

  void clearStatus() {
    _saveStatus = SleepSaveStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
