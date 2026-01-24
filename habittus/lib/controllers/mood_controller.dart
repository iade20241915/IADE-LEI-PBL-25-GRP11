import 'package:flutter/foundation.dart';
import '../models/mood.dart';
import '../repositories/interfaces/mood_repository.dart';

class MoodController extends ChangeNotifier {
  final MoodRepository _repo;

  MoodController(this._repo);

  DateTime selectedDate = DateTime.now();
  MoodEntry? _selectedEntry;
  MoodLevel? _selectedLevel;
  List<MoodEntry> weekLogs = const [];

  // Getters para compatibilidade com UI
  MoodEntry? get selected => _selectedEntry;
  MoodLevel? get selectedLevel => _selectedLevel;

  Future<void> load(DateTime date) async {
    selectedDate = _dateOnly(date);
    _selectedEntry = await _repo.getForDate(selectedDate);
    _selectedLevel = _selectedEntry?.level;
    await _loadWeek();
    notifyListeners();
  }

  Future<void> _loadWeek() async {
    final end = selectedDate;
    final start = end.subtract(const Duration(days: 6));
    final List<MoodEntry> logs = [];
    for (int i = 0; i < 7; i++) {
      final day = _dateOnly(start.add(Duration(days: i)));
      final log = await _repo.getForDate(day);
      if (log != null) logs.add(log);
    }
    weekLogs = List.unmodifiable(logs);
  }

  /// Seleciona um nível de humor (usado pelo UI)
  void select(MoodLevel level) {
    _selectedLevel = level;
    _selectedEntry = MoodEntry(date: selectedDate, level: level);
    notifyListeners();
  }

  Future<void> save(MoodEntry mood) async {
    await _repo.save(mood.copyWith(date: selectedDate));
    _selectedEntry = mood;
    _selectedLevel = mood.level;
    await _loadWeek();
    notifyListeners();
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
