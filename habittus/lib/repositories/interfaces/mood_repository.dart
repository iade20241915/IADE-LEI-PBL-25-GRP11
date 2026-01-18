import '../../models/mood.dart';

abstract class MoodRepository {
  Future<MoodEntry?> getForDate(DateTime date);
  Future<void> save(MoodEntry entry);
}
