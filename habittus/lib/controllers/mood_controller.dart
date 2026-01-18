import 'package:flutter/foundation.dart';

import '../models/mood.dart';
import '../repositories/interfaces/mood_repository.dart';

class MoodController extends ChangeNotifier {
  final MoodRepository _repo;

  MoodController(this._repo);

  DateTime selectedDate = DateTime.now();
  MoodLevel? selected;

  Future<void> load(DateTime date) async {
    selectedDate = date;
    final entry = await _repo.getForDate(date);
    selected = entry?.level;
    notifyListeners();
  }

  Future<void> select(MoodLevel level) async {
    selected = level;
    await _repo.save(MoodEntry(date: selectedDate, level: level));
    notifyListeners();
  }
}
