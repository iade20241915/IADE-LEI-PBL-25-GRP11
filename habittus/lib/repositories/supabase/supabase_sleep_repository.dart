import '../../core/database/supabase_service.dart';
import '../../core/database/supabase_config.dart';
import '../../models/sleep_log.dart';
import '../interfaces/sleep_repository.dart';

/// Implementação Supabase do repositório de sono
/// Alinhado com tabela sleep_session:
/// - sleep_session_id, sleep_date, start_time, end_time, duration_minutes, quality_score, user_id
class SupabaseSleepRepository implements SleepRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  int get _userId => _supabase.currentUserId ?? 0;

  @override
  Future<SleepLog?> getForDate(DateTime date) async {
    if (_userId == 0) return null;

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    try {
      final response = await _supabase
          .from(SupabaseConfig.sleepSessionTable)
          .select()
          .eq('user_id', _userId)
          .gte('sleep_date', startOfDay.toIso8601String())
          .lt('sleep_date', endOfDay.toIso8601String())
          .order('sleep_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      return SleepLog.fromJson(response);
    } catch (e) {
      print('Erro ao obter sono: $e');
      return null;
    }
  }

  @override
  Future<void> save(SleepLog log) async {
    if (_userId == 0) return;

    final startOfDay = DateTime(log.date.year, log.date.month, log.date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    try {
      // Calcular start_time e end_time baseado na duração
      // Assume que o utilizador dormiu e acordou no mesmo período
      final now = DateTime.now();
      final endTime = log.endTime ?? DateTime(log.date.year, log.date.month, log.date.day, now.hour, now.minute);
      final startTime = log.startTime ?? endTime.subtract(Duration(minutes: log.durationMinutes));

      // Verificar se já existe registo para este dia
      final existing = await _supabase
          .from(SupabaseConfig.sleepSessionTable)
          .select('sleep_session_id')
          .eq('user_id', _userId)
          .gte('sleep_date', startOfDay.toIso8601String())
          .lt('sleep_date', endOfDay.toIso8601String())
          .maybeSingle();

      final data = {
        'sleep_date': log.date.toIso8601String(),
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'duration_minutes': log.durationMinutes,
        'quality_score': log.quality,
      };

      if (existing != null) {
        // Atualizar
        await _supabase
            .from(SupabaseConfig.sleepSessionTable)
            .update(data)
            .eq('sleep_session_id', existing['sleep_session_id']);
      } else {
        // Inserir
        await _supabase
            .from(SupabaseConfig.sleepSessionTable)
            .insert({
              'user_id': _userId,
              ...data,
            });
      }
    } catch (e) {
      print('Erro ao guardar sono: $e');
      rethrow;
    }
  }

  /// Guarda sessão de sono com horários específicos
  Future<void> saveWithTimes({
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    required int quality,
  }) async {
    if (_userId == 0) return;

    final durationMinutes = endTime.difference(startTime).inMinutes;
    
    final log = SleepLog(
      date: date,
      startTime: startTime,
      endTime: endTime,
      durationMinutes: durationMinutes > 0 ? durationMinutes : 0,
      quality: quality,
    );

    await save(log);
  }

  /// Obtém dados da semana para gráfico
  Future<List<SleepLog>> getWeekLogs(DateTime endDate) async {
    final logs = <SleepLog>[];
    final start = endDate.subtract(const Duration(days: 6));

    for (int i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));
      final log = await getForDate(day);
      logs.add(log ?? SleepLog(date: day, durationMinutes: 0, quality: 0));
    }

    return logs;
  }

  /// Obtém última sessão de sono
  Future<SleepLog?> getLastSession() async {
    if (_userId == 0) return null;

    try {
      final response = await _supabase
          .from(SupabaseConfig.sleepSessionTable)
          .select()
          .eq('user_id', _userId)
          .order('sleep_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return SleepLog.fromJson(response);
    } catch (e) {
      print('Erro ao obter última sessão: $e');
      return null;
    }
  }
}
