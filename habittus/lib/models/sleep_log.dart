class SleepLog {
  final DateTime date;
  final int durationMinutes;
  final int quality;

  const SleepLog({
    required this.date,
    required this.durationMinutes,
    this.quality = 3,
  });

  Duration get sleepDuration => Duration(minutes: durationMinutes);
  int get minutes => durationMinutes;
}
