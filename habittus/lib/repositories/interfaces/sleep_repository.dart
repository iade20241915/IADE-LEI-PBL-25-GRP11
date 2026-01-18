import '../../models/sleep_log.dart';

abstract class SleepRepository {
  Future<SleepLog?> getForDate(DateTime date);
  Future<void> save(SleepLog log);
}
