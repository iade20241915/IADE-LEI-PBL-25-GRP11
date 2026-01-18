import '../../models/mood.dart';
import '../interfaces/mood_repository.dart';

class MockMoodRepository implements MoodRepository {
  final Map<String, MoodEntry> _store = {};

  String _key(DateTime d) => '${d.year}-${d.month}-${d.day}';

  @override
  Future<MoodEntry?> getForDate(DateTime date) async {
    return _store[_key(date)];
  }

  @override
  Future<void> save(MoodEntry entry) async {
    _store[_key(entry.date)] = entry;
  }
}
