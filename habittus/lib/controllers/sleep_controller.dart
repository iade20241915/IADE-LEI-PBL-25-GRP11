import 'package:flutter/foundation.dart';

import '../models/sleep_log.dart';
import '../repositories/interfaces/sleep_repository.dart';

class SleepController extends ChangeNotifier {
  final SleepRepository _repo;

  SleepController(this._repo);

  DateTime selectedDate = DateTime.now();
  Duration sleepDuration = const Duration(hours: 5, minutes: 30);

  Future<void> load(DateTime date) async {
    selectedDate = date;
    final log = await _repo.getForDate(date);
    sleepDuration = log?.sleepDuration ?? sleepDuration;
    notifyListeners();
  }

  Future<void> setSleepDuration(Duration duration) async {
    sleepDuration = duration;
    await _repo.save(SleepLog(date: selectedDate, sleepDuration: sleepDuration));
    notifyListeners();
  }
}
