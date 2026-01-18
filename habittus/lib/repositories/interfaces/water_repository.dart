import '../../models/water_log.dart';

abstract class WaterRepository {
  Future<WaterLog?> getForDate(DateTime date);
  Future<void> save(WaterLog log);
}
