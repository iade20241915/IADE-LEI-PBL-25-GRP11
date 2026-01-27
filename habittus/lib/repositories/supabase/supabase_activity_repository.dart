import '../../core/database/supabase_service.dart';
import '../../models/physical_activity.dart';
import '../interfaces/activity_repository.dart';

/// ============================================================
/// REPOSITÓRIO SUPABASE - ATIVIDADE FÍSICA
/// ============================================================
/// Este repositório implementa as operações CRUD para a tabela 'activity'
/// Utiliza queries SQL através da API do Supabase
/// Tabelas relacionadas: activity, activity_types, activity_track_points
/// ============================================================
class SupabaseActivityRepository implements ActivityRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  int get _userId => _supabase.currentUserId ?? 0;
  //String get _userIdStr => _userId.toString();

  // ============================================================
  // SELECT - Obter todas as atividades do utilizador
  // ============================================================
  // Query SQL equivalente:
  // SELECT a.*, at.* FROM activity a
  // LEFT JOIN activity_types at ON a.activity_type_id = at.activity_type_id
  // WHERE a.user_id = $1
  // ORDER BY a.created_at DESC;
  // ============================================================
  @override
  Future<List<PhysicalActivity>> getActivities(String userId) async {
    if (_userId == 0) {
      print('[ACTIVITY SELECT ALL] userId é 0, retornando lista vazia');
      return [];
    }

    print('[ACTIVITY SELECT ALL] Buscando atividades para user=$_userId');

    try {
      // ============================================================
      // QUERY: SELECT com JOIN para obter atividades e seus tipos
      // ============================================================
      final response = await _supabase
          .from('activity')
          .select('*, activity_types(*)') // JOIN com activity_types
          .eq('user_id', _userId) // WHERE user_id = $1
          .order('created_at', ascending: false); // ORDER BY created_at DESC

      //if (response == null) return [];

      final activities = (response as List)
          .map((json) => _fromJson(json))
          .toList();
      print(
        '[ACTIVITY SELECT ALL] Encontradas ${activities.length} atividades',
      );
      return activities;
    } catch (e) {
      print('[ACTIVITY SELECT ALL ERROR] $e');
      return [];
    }
  }

  // ============================================================
  // SELECT - Obter atividades por período de datas
  // ============================================================
  // Query SQL equivalente:
  // SELECT a.*, at.* FROM activity a
  // LEFT JOIN activity_types at ON a.activity_type_id = at.activity_type_id
  // WHERE a.user_id = $1
  //   AND a.created_at >= $2
  //   AND a.created_at <= $3
  // ORDER BY a.created_at DESC;
  // ============================================================
  @override
  Future<List<PhysicalActivity>> getActivitiesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (_userId == 0) {
      print('[ACTIVITY SELECT RANGE] userId é 0, retornando lista vazia');
      return [];
    }

    print(
      '[ACTIVITY SELECT RANGE] De $startDate a $endDate para user=$_userId',
    );

    try {
      // ============================================================
      // QUERY: SELECT com filtro de datas
      // ============================================================
      final response = await _supabase
          .from('activity')
          .select('*, activity_types(*)') // JOIN
          .eq('user_id', _userId) // WHERE user_id = $1
          .gte(
            'created_at',
            startDate.toIso8601String(),
          ) // AND created_at >= $2
          .lte('created_at', endDate.toIso8601String()) // AND created_at <= $3
          .order('created_at', ascending: false); // ORDER BY

      final activities = (response as List)
          .map((json) => _fromJson(json))
          .toList();
      print(
        '[ACTIVITY SELECT RANGE] Encontradas ${activities.length} atividades',
      );
      return activities;
    } catch (e) {
      print('[ACTIVITY SELECT RANGE ERROR] $e');
      return [];
    }
  }

  // ============================================================
  // SELECT - Obter atividade por ID
  // ============================================================
  // Query SQL equivalente:
  // SELECT a.*, at.* FROM activity a
  // LEFT JOIN activity_types at ON a.activity_type_id = at.activity_type_id
  // WHERE a.activity_id = $1
  // LIMIT 1;
  // ============================================================
  @override
  Future<PhysicalActivity?> getActivityById(String id) async {
    print('[ACTIVITY SELECT BY ID] Buscando activity_id=$id');

    try {
      // ============================================================
      // QUERY: SELECT por ID com JOIN
      // ============================================================
      final response = await _supabase
          .from('activity')
          .select('*, activity_types(*)') // JOIN
          .eq('activity_id', int.parse(id)) // WHERE activity_id = $1
          .maybeSingle(); // LIMIT 1

      if (response == null) {
        print('[ACTIVITY SELECT BY ID] Não encontrada');
        return null;
      }

      print('[ACTIVITY SELECT BY ID] Encontrada');
      return _fromJson(response);
    } catch (e) {
      print('[ACTIVITY SELECT BY ID ERROR] $e');
      return null;
    }
  }

  // ============================================================
  // INSERT - Adicionar nova atividade
  // ============================================================
  // Query SQL equivalente:
  // INSERT INTO activity (user_id, activity_type_id, duration_min, kcal, created_at)
  // VALUES ($1, $2, $3, $4, $5)
  // RETURNING activity_id;
  // ============================================================
  @override
  Future<void> addActivity(PhysicalActivity activity) async {
    if (_userId == 0) {
      print('[ACTIVITY INSERT] userId é 0, abortando');
      return;
    }

    print(
      '[ACTIVITY INSERT] Adicionando ${activity.activityType.label} para user=$_userId',
    );

    try {
      // Primeiro: obter ou criar o activity_type_id
      final typeId = await _getOrCreateActivityType(activity.activityType);
      print('[ACTIVITY INSERT] activity_type_id=$typeId');

      // ============================================================
      // QUERY: INSERT nova atividade
      // INSERT INTO activity (user_id, activity_type_id, duration_min, steps, kcal, created_at)
      // VALUES ($1, $2, $3, NULL, $4, $5) RETURNING activity_id;
      // ============================================================
      final result = await _supabase
          .from('activity')
          .insert({
            'user_id': _userId,
            'activity_type_id': typeId,
            'duration_min': activity.durationMinutes,
            'steps': null,
            'kcal': activity.caloriesBurned,
            'created_at': activity.timestamp.toIso8601String(),
          })
          .select('activity_id')
          .single();

      final activityId = result['activity_id'] as int;
      print('[ACTIVITY INSERT] Criada activity_id=$activityId');

      // ============================================================
      // INSERT track points se houver coordenadas GPS
      // INSERT INTO activity_track_points (activity_id, seq, lat, lng, altitude_m, recorded_at)
      // VALUES ($1, $2, $3, $4, $5, $6);
      // ============================================================
      if (activity.startLocation != null) {
        print('[ACTIVITY INSERT] Adicionando ponto GPS inicial');
        await _supabase
            .from('activity_track_points')
            .insert(activity.startLocation!.toJson(activityId));
      }
      if (activity.endLocation != null) {
        print('[ACTIVITY INSERT] Adicionando ponto GPS final');
        await _supabase
            .from('activity_track_points')
            .insert(activity.endLocation!.toJson(activityId));
      }

      print('[ACTIVITY INSERT] Sucesso!');
    } catch (e) {
      print('[ACTIVITY INSERT ERROR] $e');
      rethrow;
    }
  }

  // ============================================================
  // UPDATE - Atualizar atividade existente
  // ============================================================
  // Query SQL equivalente:
  // UPDATE activity
  // SET activity_type_id = $1, duration_min = $2, kcal = $3
  // WHERE activity_id = $4;
  // ============================================================
  @override
  Future<void> updateActivity(PhysicalActivity activity) async {
    print('[ACTIVITY UPDATE] Atualizando activity_id=${activity.id}');

    try {
      final typeId = await _getOrCreateActivityType(activity.activityType);

      // ============================================================
      // QUERY: UPDATE atividade
      // ============================================================
      await _supabase
          .from('activity')
          .update({
            'activity_type_id': typeId,
            'duration_min': activity.durationMinutes,
            'kcal': activity.caloriesBurned,
          })
          .eq('activity_id', int.parse(activity.id));

      print('[ACTIVITY UPDATE] Sucesso!');
    } catch (e) {
      print('[ACTIVITY UPDATE ERROR] $e');
      rethrow;
    }
  }

  // ============================================================
  // DELETE - Apagar atividade
  // ============================================================
  // Query SQL equivalente:
  // DELETE FROM activity WHERE activity_id = $1;
  // (track_points são apagados automaticamente por ON DELETE CASCADE)
  // ============================================================
  @override
  Future<void> deleteActivity(String id) async {
    print('[ACTIVITY DELETE] Apagando activity_id=$id');

    try {
      // ============================================================
      // QUERY: DELETE (CASCADE apaga track_points)
      // ============================================================
      await _supabase
          .from('activity')
          .delete()
          .eq('activity_id', int.parse(id));

      print('[ACTIVITY DELETE] Sucesso!');
    } catch (e) {
      print('[ACTIVITY DELETE ERROR] $e');
      rethrow;
    }
  }

  // ============================================================
  // SELECT com SUM - Total de minutos por período
  // ============================================================
  // Query SQL equivalente:
  // SELECT COALESCE(SUM(duration_min), 0) as total
  // FROM activity
  // WHERE user_id = $1 AND created_at >= $2 AND created_at <= $3;
  // ============================================================
  @override
  Future<int> getTotalMinutes(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    print('[ACTIVITY SUM MINUTES] De $startDate a $endDate');
    final activities = await getActivitiesByDateRange(
      userId,
      startDate,
      endDate,
    );
    final total = activities.fold<int>(0, (sum, a) => sum + a.durationMinutes);
    print('[ACTIVITY SUM MINUTES] Total: $total minutos');
    return total;
  }

  // ============================================================
  // SELECT com SUM - Total de calorias por período
  // ============================================================
  @override
  Future<int> getTotalCalories(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    print('[ACTIVITY SUM CALORIES] De $startDate a $endDate');
    final activities = await getActivitiesByDateRange(
      userId,
      startDate,
      endDate,
    );
    final total = activities.fold<int>(
      0,
      (sum, a) => sum + (a.caloriesBurned ?? 0),
    );
    print('[ACTIVITY SUM CALORIES] Total: $total kcal');
    return total;
  }

  // ============================================================
  // SELECT - Minutos da semana para gráfico (otimizado)
  // ============================================================
  // Query SQL equivalente:
  // SELECT DATE(created_at) as day, SUM(duration_min) as total
  // FROM activity
  // WHERE user_id = $1 AND created_at >= $2 AND created_at < $3
  // GROUP BY DATE(created_at)
  // ORDER BY day;
  // ============================================================
  Future<List<int>> getWeeklyMinutes(DateTime endDate) async {
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final start = end.subtract(const Duration(days: 6));

    print('[ACTIVITY WEEKLY] De $start a $end');

    try {
      // Buscar todas as atividades da semana numa query
      final response = await _supabase
          .from('activity')
          .select('duration_min, created_at')
          .eq('user_id', _userId)
          .gte('created_at', start.toIso8601String())
          .lt('created_at', end.add(const Duration(days: 1)).toIso8601String());

      // Inicializar array com 7 dias
      final minutes = List<int>.filled(7, 0);

      // Processar resultados
      for (final activity in response as List) {
        final createdAt = DateTime.parse(activity['created_at'] as String);
        final activityDate = DateTime(
          createdAt.year,
          createdAt.month,
          createdAt.day,
        );
        final dayIndex = activityDate.difference(start).inDays;

        if (dayIndex >= 0 && dayIndex < 7) {
          minutes[dayIndex] += (activity['duration_min'] as int? ?? 0);
        }
      }

      print('[ACTIVITY WEEKLY] Resultado: $minutes');
      return minutes;
    } catch (e) {
      print('[ACTIVITY WEEKLY ERROR] $e');
      return List.filled(7, 0);
    }
  }

  // ============================================================
  // SELECT / INSERT - Obter ou criar tipo de atividade
  // ============================================================
  // Tabela activity_types:
  //   activity_type_id SERIAL PRIMARY KEY
  //   activity_type VARCHAR(45) NOT NULL
  //   activity_type_group VARCHAR(45)
  //   kcal INT
  //   icon VARCHAR(45)
  //   color VARCHAR(45)
  // ============================================================
  Future<int> _getOrCreateActivityType(ActivityType type) async {
    final typeName = type.toString().split('.').last;
    print('[ACTIVITY_TYPE] Obtendo/criando tipo: $typeName');

    try {
      // ============================================================
      // QUERY: SELECT para verificar se tipo existe
      // SELECT activity_type_id FROM activity_types WHERE activity_type = $1;
      // ============================================================
      final existing = await _supabase
          .from('activity_types')
          .select('activity_type_id')
          .eq('activity_type', typeName)
          .maybeSingle();

      if (existing != null) {
        print(
          '[ACTIVITY_TYPE SELECT] Encontrado: ${existing['activity_type_id']}',
        );
        return existing['activity_type_id'] as int;
      }

      // ============================================================
      // QUERY: INSERT novo tipo de atividade
      // INSERT INTO activity_types (activity_type, activity_type_group, kcal, icon, color)
      // VALUES ($1, $2, $3, $4, $5) RETURNING activity_type_id;
      // ============================================================
      print('[ACTIVITY_TYPE INSERT] Criando novo tipo');

      // Determinar grupo e kcal baseado no tipo
      String group = 'other';
      int kcal = 300;
      String icon = 'fitness_center';
      String color = '#607D8B';

      switch (type) {
        case ActivityType.running:
          group = 'outdoor';
          kcal = 600;
          icon = 'directions_run';
          color = '#4CAF50';
          break;
        case ActivityType.walking:
          group = 'outdoor';
          kcal = 280;
          icon = 'directions_walk';
          color = '#8BC34A';
          break;
        case ActivityType.cycling:
          group = 'outdoor';
          kcal = 500;
          icon = 'directions_bike';
          color = '#FF9800';
          break;
        case ActivityType.hiking:
          group = 'outdoor';
          kcal = 450;
          icon = 'terrain';
          color = '#795548';
          break;
        case ActivityType.swimming:
          group = 'indoor';
          kcal = 550;
          icon = 'pool';
          color = '#2196F3';
          break;
        case ActivityType.gym:
          group = 'indoor';
          kcal = 400;
          icon = 'fitness_center';
          color = '#9C27B0';
          break;
        case ActivityType.yoga:
          group = 'indoor';
          kcal = 180;
          icon = 'self_improvement';
          color = '#E91E63';
          break;
        case ActivityType.dance:
          group = 'indoor';
          kcal = 350;
          icon = 'music_note';
          color = '#F44336';
          break;
        case ActivityType.soccer:
          group = 'sports';
          kcal = 600;
          icon = 'sports_soccer';
          color = '#4CAF50';
          break;
        case ActivityType.basketball:
          group = 'sports';
          kcal = 500;
          icon = 'sports_basketball';
          color = '#FF5722';
          break;
        case ActivityType.tennis:
          group = 'sports';
          kcal = 450;
          icon = 'sports_tennis';
          color = '#CDDC39';
          break;
        case ActivityType.other:
          group = 'other';
          kcal = 300;
          icon = 'fitness_center';
          color = '#607D8B';
          break;
      }

      final result = await _supabase
          .from('activity_types')
          .insert({
            'activity_type': typeName,
            'activity_type_group': group,
            'kcal': kcal,
            'icon': icon,
            'color': color,
          })
          .select('activity_type_id')
          .single();

      print('[ACTIVITY_TYPE INSERT] Criado: ${result['activity_type_id']}');
      return result['activity_type_id'] as int;
    } catch (e) {
      print('[ACTIVITY_TYPE ERROR] $e');
      return 1; // Fallback para tipo 'running'
    }
  }

  /// Converte JSON da BD para PhysicalActivity
  PhysicalActivity _fromJson(Map<String, dynamic> json) {
    final typeData = json['activity_types'] as Map<String, dynamic>?;
    final typeName = typeData?['activity_type'] as String? ?? 'other';

    return PhysicalActivity(
      id: (json['activity_id'] as int).toString(),
      userId: (json['user_id'] as int).toString(),
      timestamp: DateTime.parse(json['created_at'] as String),
      activityType: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == typeName,
        orElse: () => ActivityType.other,
      ),
      durationMinutes: json['duration_min'] as int? ?? 0,
      intensity: ActivityIntensity.moderate,
      caloriesBurned: json['kcal'] as int?,
    );
  }
}
