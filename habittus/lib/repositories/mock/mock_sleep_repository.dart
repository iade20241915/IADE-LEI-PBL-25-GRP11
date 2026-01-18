import '../../models/sleep_log.dart';
import '../interfaces/sleep_repository.dart';

class MockSleepRepository implements SleepRepository {
  final Map<String, SleepLog> _store = {};

  String _key(DateTime d) => '${d.year}-${d.month}-${d.day}';

  @override
  Future<SleepLog?> getForDate(DateTime date) async {
    return _store[_key(date)];
  }

  @override
  Future<void> save(SleepLog log) async {
    _store[_key(log.date)] = log;
  }
}
