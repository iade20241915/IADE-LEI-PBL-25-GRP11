import '../interfaces/activity_repository.dart';
import '../../models/physical_activity.dart';

/// Implementação mock do repositório de atividades físicas
class MockActivityRepository implements ActivityRepository {
  final List<PhysicalActivity> _activities = [];

  MockActivityRepository() {
    _populateMockData();
  }

  void _populateMockData() {
    final now = DateTime.now();
    final userId = 'mock_user_123';

    // Dados mock dos últimos 7 dias
    _activities.addAll([
      PhysicalActivity(
        id: '1',
        userId: userId,
        timestamp: now.subtract(const Duration(days: 1)),
        activityType: ActivityType.running,
        durationMinutes: 30,
        intensity: ActivityIntensity.moderate,
        distanceKm: 5.2,
        caloriesBurned: 320,
      ),
      PhysicalActivity(
        id: '2',
        userId: userId,
        timestamp: now.subtract(const Duration(days: 2)),
        activityType: ActivityType.gym,
        durationMinutes: 60,
        intensity: ActivityIntensity.high,
        caloriesBurned: 450,
      ),
      PhysicalActivity(
        id: '3',
        userId: userId,
        timestamp: now.subtract(const Duration(days: 3)),
        activityType: ActivityType.yoga,
        durationMinutes: 45,
        intensity: ActivityIntensity.low,
        caloriesBurned: 150,
      ),
      PhysicalActivity(
        id: '4',
        userId: userId,
        timestamp: now.subtract(const Duration(days: 4)),
        activityType: ActivityType.cycling,
        durationMinutes: 40,
        intensity: ActivityIntensity.moderate,
        distanceKm: 15.0,
        caloriesBurned: 280,
      ),
      PhysicalActivity(
        id: '5',
        userId: userId,
        timestamp: now.subtract(const Duration(days: 6)),
        activityType: ActivityType.swimming,
        durationMinutes: 35,
        intensity: ActivityIntensity.high,
        caloriesBurned: 400,
      ),
    ]);
  }

  @override
  Future<List<PhysicalActivity>> getActivities(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simula latência
    return _activities.where((a) => a.userId == userId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<List<PhysicalActivity>> getActivitiesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _activities
        .where(
          (a) =>
              a.userId == userId &&
              a.timestamp.isAfter(startDate) &&
              a.timestamp.isBefore(endDate),
        )
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<PhysicalActivity?> getActivityById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _activities.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addActivity(PhysicalActivity activity) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _activities.add(activity);
  }

  @override
  Future<void> updateActivity(PhysicalActivity activity) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _activities.indexWhere((a) => a.id == activity.id);
    if (index != -1) {
      _activities[index] = activity;
    }
  }

  @override
  Future<void> deleteActivity(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _activities.removeWhere((a) => a.id == id);
  }

  @override
  Future<int> getTotalMinutes(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final activities = await getActivitiesByDateRange(
      userId,
      startDate,
      endDate,
    );
    return activities.fold<int>(
      0,
      (sum, a) => sum + a.durationMinutes,
    ); // ← <int> IMPORTANTE
  }

  @override
  Future<int> getTotalCalories(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final activities = await getActivitiesByDateRange(
      userId,
      startDate,
      endDate,
    );
    return activities.fold<int>(
      0,
      (sum, a) => sum + (a.caloriesBurned ?? 0),
    ); // ← <int> IMPORTANTE
  }
}
