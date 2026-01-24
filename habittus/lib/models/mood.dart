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

  MoodEntry copyWith({DateTime? date, MoodLevel? level}) {
    return MoodEntry(
      date: date ?? this.date,
      level: level ?? this.level,
    );
  }
}
