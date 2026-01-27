import '../../core/database/supabase_service.dart';
import '../../core/database/supabase_config.dart';
import '../../models/water_log.dart';
import '../interfaces/water_repository.dart';

/// Implementação Supabase do repositório de água
/// Alinhado com tabela water_intake:
/// - water_intake_id, intake_at, amount_ml, source, user_id
class SupabaseWaterRepository implements WaterRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  int get _userId => _supabase.currentUserId ?? 0;

  @override
  Future<WaterLog?> getForDate(DateTime date) async {
    if (_userId == 0) return null;

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      // Buscar todos os registos do dia e somar
      final response = await _supabase
          .from(SupabaseConfig.waterIntakeTable)
          .select()
          .eq('user_id', _userId)
          .gte('intake_at', startOfDay.toIso8601String())
          .lt('intake_at', endOfDay.toIso8601String());

      if ((response as List).isEmpty) {
        return WaterLog(date: date, amountMl: 0, cups: 0);
      }

      // Somar todos os registos do dia
      int totalMl = 0;
      for (final record in response) {
        totalMl += (record['amount_ml'] as int?) ?? 0;
      }

      return WaterLog(
        date: date,
        amountMl: totalMl,
        mlPerCup: 250,
        cups: totalMl ~/ 250,
        userId: _userId,
      );
    } catch (e) {
      print('Erro ao obter água: $e');
      return null;
    }
  }

  @override
  Future<void> save(WaterLog log) async {
    if (_userId == 0) return;

    try {
      // Inserir novo registo (cada save é uma nova entrada)
      await _supabase.from(SupabaseConfig.waterIntakeTable).insert({
        'user_id': _userId,
        'intake_at': log.date.toIso8601String(),
        'amount_ml': log.totalMl,
        'source': log.source.value,
      });
    } catch (e) {
      print('Erro ao guardar água: $e');
      rethrow;
    }
  }

  /// Guarda ou atualiza o total do dia (para uso com grid de copos)
  Future<void> saveOrUpdateDaily(WaterLog log) async {
    if (_userId == 0) return;

    final startOfDay = DateTime(log.date.year, log.date.month, log.date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      // Verificar se já existe registo para este dia
      final existing = await _supabase
          .from(SupabaseConfig.waterIntakeTable)
          .select('water_intake_id, amount_ml')
          .eq('user_id', _userId)
          .gte('intake_at', startOfDay.toIso8601String())
          .lt('intake_at', endOfDay.toIso8601String())
          .order('intake_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (existing != null) {
        // Atualizar registo existente
        await _supabase
            .from(SupabaseConfig.waterIntakeTable)
            .update({'amount_ml': log.totalMl})
            .eq('water_intake_id', existing['water_intake_id']);
      } else {
        // Inserir novo registo
        await _supabase.from(SupabaseConfig.waterIntakeTable).insert({
          'user_id': _userId,
          'intake_at': log.date.toIso8601String(),
          'amount_ml': log.totalMl,
          'source': log.source.value,
        });
      }
    } catch (e) {
      print('Erro ao guardar água: $e');
      rethrow;
    }
  }

  /// Adiciona quantidade de água (cria novo registo)
  Future<void> addWater(
    int amountMl, {
    WaterSource source = WaterSource.manual,
  }) async {
    if (_userId == 0) return;

    try {
      await _supabase.from(SupabaseConfig.waterIntakeTable).insert({
        'user_id': _userId,
        'intake_at': DateTime.now().toIso8601String(),
        'amount_ml': amountMl,
        'source': source.value,
      });
    } catch (e) {
      print('Erro ao adicionar água: $e');
      rethrow;
    }
  }

  /// Obtém dados da semana para gráfico
  Future<List<WaterLog>> getWeekLogs(DateTime endDate) async {
    final logs = <WaterLog>[];
    final start = endDate.subtract(const Duration(days: 6));

    for (int i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));
      final log = await getForDate(day);
      logs.add(log ?? WaterLog(date: day, amountMl: 0, cups: 0));
    }

    return logs;
  }
}
