import '../../models/physical_activity.dart';

/// Interface para repositório de atividades físicas
abstract class ActivityRepository {
  /// Busca todas as atividades de um usuário
  Future<List<PhysicalActivity>> getActivities(String userId);

  /// Busca atividades de um usuário em um período específico
  Future<List<PhysicalActivity>> getActivitiesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Busca uma atividade específica por ID
  Future<PhysicalActivity?> getActivityById(String id);

  /// Adiciona uma nova atividade
  Future<void> addActivity(PhysicalActivity activity);

  /// Atualiza uma atividade existente
  Future<void> updateActivity(PhysicalActivity activity);

  /// Remove uma atividade
  Future<void> deleteActivity(String id);

  /// Calcula total de minutos de atividade em um período
  Future<int> getTotalMinutes(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Calcula total de calorias queimadas em um período
  Future<int> getTotalCalories(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
}
