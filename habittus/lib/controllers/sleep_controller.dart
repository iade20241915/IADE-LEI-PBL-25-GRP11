import 'package:flutter/foundation.dart';
import '../models/sleep_log.dart';
import '../repositories/interfaces/sleep_repository.dart';

class SleepController extends ChangeNotifier {
  final SleepRepository _repo;

  SleepController(this._repo);

  DateTime selectedDate = DateTime.now();
  Duration sleepDuration = const Duration(hours: 7, minutes: 30);
  int qualityScore = 3;
  List<SleepLog> weekLogs = const [];

  int get sleepMinutes => sleepDuration.inMinutes;
  
  String get sleepFormatted {
    final hours = sleepDuration.inHours;
    final mins = sleepDuration.inMinutes % 60;
    return '${hours}h${mins.toString().padLeft(2, '0')}';
  }

  Future<void> load(DateTime date) async {
    selectedDate = _dateOnly(date);
    final log = await _repo.getForDate(selectedDate);
    if (log != null) {
      sleepDuration = Duration(minutes: log.durationMinutes);
      qualityScore = log.quality;
    } else {
      sleepDuration = const Duration(hours: 7, minutes: 30);
      qualityScore = 3;
    }
    await _loadWeek();
    notifyListeners();
  }

  Future<void> _loadWeek() async {
    final end = selectedDate;
    final start = end.subtract(const Duration(days: 6));
    final List<SleepLog> logs = [];
    for (int i = 0; i < 7; i++) {
      final day = _dateOnly(start.add(Duration(days: i)));
      final log = await _repo.getForDate(day);
      logs.add(log ?? SleepLog(date: day, durationMinutes: 0, quality: 0));
    }
    weekLogs = List.unmodifiable(logs);
  }

  void setSleepDuration(Duration duration) {
    sleepDuration = duration;
    notifyListeners();
  }

  void setQuality(int quality) {
    qualityScore = quality;
    notifyListeners();
  }

  Future<void> save() async {
    await _repo.save(SleepLog(
      date: selectedDate,
      durationMinutes: sleepDuration.inMinutes,
      quality: qualityScore,
    ));
    await _loadWeek();
    notifyListeners();
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
