enum MoodLevel {
  veryBad,
  bad,
  neutral,
  good,
  veryGood,
}

class MoodEntry {
  final DateTime date;
  final MoodLevel level;

  const MoodEntry({required this.date, required this.level});
}
