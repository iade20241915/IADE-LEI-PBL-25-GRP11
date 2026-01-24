import 'package:flutter/foundation.dart';
import '../models/water_log.dart';
import '../repositories/interfaces/water_repository.dart';

class WaterController extends ChangeNotifier {
  final WaterRepository _repo;

  WaterController(this._repo);

  DateTime selectedDate = DateTime.now();
  static const int defaultMlPerCup = 250;

  int cups = 0;
  List<WaterLog> weekLogs = const [];

  int get totalMl => cups * defaultMlPerCup;

  Future<void> load(DateTime date) async {
    selectedDate = _dateOnly(date);
    final log = await _repo.getForDate(selectedDate);
    cups = log?.cups ?? 0;
    await _loadWeek();
    notifyListeners();
  }

  Future<void> _loadWeek() async {
    final end = selectedDate;
    final start = end.subtract(const Duration(days: 6));
    final List<WaterLog> logs = [];
    for (int i = 0; i < 7; i++) {
      final day = _dateOnly(start.add(Duration(days: i)));
      final log = await _repo.getForDate(day);
      logs.add(log ?? WaterLog(date: day, mlPerCup: defaultMlPerCup, cups: 0));
    }
    weekLogs = List.unmodifiable(logs);
  }

  Future<void> toggleCup(int index, {required int gridSize}) async {
    if (index < cups) {
      cups = index;
    } else {
      cups = (index + 1).clamp(0, gridSize);
    }
    await _repo.save(WaterLog(date: selectedDate, mlPerCup: defaultMlPerCup, cups: cups));
    await _loadWeek();
    notifyListeners();
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
