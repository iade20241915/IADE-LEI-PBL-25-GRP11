import '../../models/water_log.dart';
import '../interfaces/water_repository.dart';

class MockWaterRepository implements WaterRepository {
  final Map<String, WaterLog> _store = {};

  String _key(DateTime d) => '${d.year}-${d.month}-${d.day}';

  @override
  Future<WaterLog?> getForDate(DateTime date) async {
    return _store[_key(date)];
  }

  @override
  Future<void> save(WaterLog log) async {
    _store[_key(log.date)] = log;
  }
}
