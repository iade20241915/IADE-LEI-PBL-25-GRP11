class SleepLog {
  final DateTime date;
  final Duration sleepDuration;

  const SleepLog({
    required this.date,
    required this.sleepDuration,
  });

  int get minutes => sleepDuration.inMinutes;
}
