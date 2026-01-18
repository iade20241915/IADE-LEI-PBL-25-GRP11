import 'package:flutter/foundation.dart';

import '../models/water_log.dart';
import '../repositories/interfaces/water_repository.dart';

class WaterController extends ChangeNotifier {
  final WaterRepository _repo;

  WaterController(this._repo);

  DateTime selectedDate = DateTime.now();
  static const int defaultMlPerCup = 250;

  int cups = 0;

  int get totalMl => cups * defaultMlPerCup;

  Future<void> load(DateTime date) async {
    selectedDate = date;
    final log = await _repo.getForDate(date);
    cups = log?.cups ?? 0;
    notifyListeners();
  }

  Future<void> toggleCup(int index, {required int gridSize}) async {
    // regra simples: index < cups => remove; senão adiciona até index+1
    if (index < cups) {
      cups = index;
    } else {
      cups = (index + 1).clamp(0, gridSize);
    }

    await _repo.save(
      WaterLog(date: selectedDate, mlPerCup: defaultMlPerCup, cups: cups),
    );
    notifyListeners();
  }
}
