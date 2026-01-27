import '../../core/database/supabase_service.dart';
import '../../models/water_log.dart';
import '../interfaces/water_repository.dart';

/// Implementação Supabase do repositório de água usando SQL Raw
/// 
/// Esta versão usa queries SQL completas em vez da API do Supabase client,
/// permitindo maior controlo e visibilidade das queries executadas.
/// 
/// As queries são executadas via RPC (Remote Procedure Call) que permite
/// executar funções SQL ou queries raw no PostgreSQL.
class SupabaseWaterRepositorySQL implements WaterRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  int get _userId => _supabase.currentUserId ?? 0;

  // ============================================================
  // QUERY: Obter consumo de água para uma data
  // ============================================================
  // SQL Equivalente:
  // SELECT COALESCE(SUM(amount_ml), 0) as total_ml
  // FROM water_intake
  // WHERE user_id = $1
  //   AND intake_at >= $2
  //   AND intake_at < $3
  // ============================================================
  @override
  Future<WaterLog?> getForDate(DateTime date) async {
    if (_userId == 0) return null;

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    try {
      // Usando RPC para executar query SQL
      final response = await _supabase.client.rpc(
        'get_water_for_date',
        params: {
          'p_user_id': _userId,
          'p_start_date': startOfDay.toIso8601String(),
          'p_end_date': endOfDay.toIso8601String(),
        },
      );

      final totalMl = (response as int?) ?? 0;

      return WaterLog(
        date: date,
        amountMl: totalMl,
        mlPerCup: 250,
        cups: totalMl ~/ 250,
        userId: _userId,
      );
    } catch (e) {
      print('[WATER SQL] Erro em getForDate: $e');
      // Fallback para query direta se RPC não existir
      return await _getForDateDirect(date);
    }
  }

  /// Fallback usando query direta (sem RPC)
  Future<WaterLog?> _getForDateDirect(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      // Query direta usando o cliente Supabase
      // SQL: SELECT * FROM water_intake WHERE user_id = X AND intake_at BETWEEN ...
      final response = await _supabase.client
          .from('water_intake')
          .select('amount_ml')
          .eq('user_id', _userId)
          .gte('intake_at', startOfDay.toIso8601String())
          .lt('intake_at', endOfDay.toIso8601String());

      int totalMl = 0;
      for (final record in (response as List)) {
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
      print('[WATER SQL] Erro em _getForDateDirect: $e');
      return WaterLog(date: date, amountMl: 0, cups: 0);
    }
  }

  // ============================================================
  // QUERY: Inserir registo de água
  // ============================================================
  // SQL Equivalente:
  // INSERT INTO water_intake (user_id, intake_at, amount_ml, source)
  // VALUES ($1, $2, $3, $4)
  // RETURNING water_intake_id
  // ============================================================
  @override
  Future<void> save(WaterLog log) async {
    if (_userId == 0) return;

    try {
      await _supabase.client.rpc(
        'insert_water_intake',
        params: {
          'p_user_id': _userId,
          'p_intake_at': log.date.toIso8601String(),
          'p_amount_ml': log.totalMl,
          'p_source': log.source.value,
        },
      );
      print('[WATER SQL] INSERT executado: ${log.totalMl}ml');
    } catch (e) {
      print('[WATER SQL] Erro em save, usando fallback: $e');
      await _saveDirect(log);
    }
  }

  /// Fallback usando insert direto
  Future<void> _saveDirect(WaterLog log) async {
    // SQL: INSERT INTO water_intake (user_id, intake_at, amount_ml, source) VALUES (...)
    await _supabase.client
        .from('water_intake')
        .insert({
          'user_id': _userId,
          'intake_at': log.date.toIso8601String(),
          'amount_ml': log.totalMl,
          'source': log.source.value,
        });
  }

  // ============================================================
  // QUERY: Guardar ou atualizar total diário
  // ============================================================
  // SQL Equivalente (UPSERT):
  // INSERT INTO water_intake (user_id, intake_at, amount_ml, source)
  // VALUES ($1, $2, $3, $4)
  // ON CONFLICT (user_id, DATE(intake_at))
  // DO UPDATE SET amount_ml = $3
  // ============================================================
  Future<void> saveOrUpdateDaily(WaterLog log) async {
    if (_userId == 0) return;

    final startOfDay = DateTime(log.date.year, log.date.month, log.date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      // Tentar usar função RPC para upsert
      await _supabase.client.rpc(
        'upsert_water_daily',
        params: {
          'p_user_id': _userId,
          'p_date': startOfDay.toIso8601String(),
          'p_amount_ml': log.totalMl,
          'p_source': log.source.value,
        },
      );
      print('[WATER SQL] UPSERT executado: ${log.totalMl}ml para ${startOfDay.toString().split(' ')[0]}');
    } catch (e) {
      print('[WATER SQL] Erro em upsert, usando fallback: $e');
      await _saveOrUpdateDailyDirect(log, startOfDay, endOfDay);
    }
  }

  /// Fallback para saveOrUpdateDaily
  Future<void> _saveOrUpdateDailyDirect(WaterLog log, DateTime startOfDay, DateTime endOfDay) async {
    // SQL: SELECT water_intake_id FROM water_intake WHERE user_id = X AND intake_at BETWEEN ...
    final existing = await _supabase.client
        .from('water_intake')
        .select('water_intake_id')
        .eq('user_id', _userId)
        .gte('intake_at', startOfDay.toIso8601String())
        .lt('intake_at', endOfDay.toIso8601String())
        .limit(1)
        .maybeSingle();

    if (existing != null) {
      // SQL: UPDATE water_intake SET amount_ml = X WHERE water_intake_id = Y
      await _supabase.client
          .from('water_intake')
          .update({'amount_ml': log.totalMl})
          .eq('water_intake_id', existing['water_intake_id']);
      print('[WATER SQL] UPDATE executado');
    } else {
      // SQL: INSERT INTO water_intake (...) VALUES (...)
      await _supabase.client
          .from('water_intake')
          .insert({
            'user_id': _userId,
            'intake_at': log.date.toIso8601String(),
            'amount_ml': log.totalMl,
            'source': log.source.value,
          });
      print('[WATER SQL] INSERT executado');
    }
  }

  // ============================================================
  // QUERY: Adicionar água (novo registo)
  // ============================================================
  // SQL:
  // INSERT INTO water_intake (user_id, intake_at, amount_ml, source)
  // VALUES ($1, NOW(), $2, $3)
  // ============================================================
  Future<void> addWater(int amountMl, {WaterSource source = WaterSource.manual}) async {
    if (_userId == 0) return;

    try {
      // SQL: INSERT INTO water_intake (user_id, intake_at, amount_ml, source) VALUES (...)
      await _supabase.client
          .from('water_intake')
          .insert({
            'user_id': _userId,
            'intake_at': DateTime.now().toIso8601String(),
            'amount_ml': amountMl,
            'source': source.value,
          });
      print('[WATER SQL] INSERT addWater: ${amountMl}ml');
    } catch (e) {
      print('[WATER SQL] Erro em addWater: $e');
      rethrow;
    }
  }

  // ============================================================
  // QUERY: Obter dados da semana para gráfico
  // ============================================================
  // SQL Equivalente:
  // SELECT DATE(intake_at) as dia, SUM(amount_ml) as total_ml
  // FROM water_intake
  // WHERE user_id = $1
  //   AND intake_at >= $2
  //   AND intake_at < $3
  // GROUP BY DATE(intake_at)
  // ORDER BY dia
  // ============================================================
  Future<List<WaterLog>> getWeekLogs(DateTime endDate) async {
    if (_userId == 0) {
      return List.generate(7, (i) => WaterLog(
        date: endDate.subtract(Duration(days: 6 - i)),
        amountMl: 0,
        cups: 0,
      ));
    }

    final start = DateTime(endDate.year, endDate.month, endDate.day)
        .subtract(const Duration(days: 6));
    final end = DateTime(endDate.year, endDate.month, endDate.day)
        .add(const Duration(days: 1));

    try {
      // Tentar usar RPC para query agregada
      final response = await _supabase.client.rpc(
        'get_water_week_summary',
        params: {
          'p_user_id': _userId,
          'p_start_date': start.toIso8601String(),
          'p_end_date': end.toIso8601String(),
        },
      );

      // Processar resposta do RPC
      final Map<String, int> dailyTotals = {};
      for (final row in (response as List)) {
        final dateStr = row['dia'] as String;
        final total = row['total_ml'] as int;
        dailyTotals[dateStr] = total;
      }

      // Criar lista de 7 dias
      return List.generate(7, (i) {
        final day = start.add(Duration(days: i));
        final dateStr = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        final totalMl = dailyTotals[dateStr] ?? 0;
        return WaterLog(
          date: day,
          amountMl: totalMl,
          mlPerCup: 250,
          cups: totalMl ~/ 250,
          userId: _userId,
        );
      });
    } catch (e) {
      print('[WATER SQL] Erro em getWeekLogs, usando fallback: $e');
      return await _getWeekLogsDirect(endDate);
    }
  }

  /// Fallback para getWeekLogs (query individual por dia)
  Future<List<WaterLog>> _getWeekLogsDirect(DateTime endDate) async {
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
