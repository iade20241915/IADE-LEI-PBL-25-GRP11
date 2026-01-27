import '../../core/database/supabase_service.dart';
import '../../models/cycle_entry.dart';

/// Implementação Supabase do repositório de ciclo menstrual
/// Alinhado com tabela: cycle_entry
class SupabaseCycleRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  int get _userId => _supabase.currentUserId ?? 0;

  /// Obtém entrada para uma data específica
  Future<CycleEntry?> getForDate(DateTime date) async {
    if (_userId == 0) {
      print('[CYCLE REPO] getForDate: userId é 0');
      return null;
    }

    final dateStr = _formatDate(date);

    print('[CYCLE REPO] === GET FOR DATE ===');
    print('[CYCLE REPO] userId: $_userId, date: $dateStr');

    try {
      final response = await _supabase
          .from('cycle_entry')
          .select()
          .eq('user_id', _userId)
          .eq('entry_date', dateStr)
          .maybeSingle();

      if (response == null) {
        print('[CYCLE REPO] Nenhum registo encontrado');
        return null;
      }

      print('[CYCLE REPO] Registo encontrado: $response');
      final entry = _fromJson(response);
      print(
        '[CYCLE REPO] Parsed: flow=${entry.menstrualFlow}, symptoms=${entry.symptoms}',
      );
      return entry;
    } catch (e) {
      print('[CYCLE REPO ERROR] getForDate: $e');
      return null;
    }
  }

  /// Obtém todas as entradas de um mês
  Future<List<CycleEntry>> getForMonth(int year, int month) async {
    if (_userId == 0) return [];

    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0); // Último dia do mês

    try {
      final response = await _supabase
          .from('cycle_entry')
          .select()
          .eq('user_id', _userId)
          .gte('entry_date', _formatDate(startDate))
          .lte('entry_date', _formatDate(endDate))
          .order('entry_date', ascending: true);

      return (response as List).map((json) => _fromJson(json)).toList();
    } catch (e) {
      print('Erro ao obter entradas do mês: $e');
      return [];
    }
  }

  /// Guarda ou atualiza entrada
  Future<void> save(CycleEntry entry) async {
    if (_userId == 0) {
      print('[CYCLE REPO] userId é 0, abortando save');
      return;
    }

    final dateStr = _formatDate(entry.entryDate);

    print('[CYCLE REPO] === SAVE ===');
    print('[CYCLE REPO] userId: $_userId');
    print('[CYCLE REPO] date: $dateStr');
    print('[CYCLE REPO] menstrualFlow: ${entry.menstrualFlow}');
    print('[CYCLE REPO] symptoms: ${entry.symptoms}');
    print('[CYCLE REPO] birthControlTaken: ${entry.birthControlTaken}');
    print('[CYCLE REPO] sexualActivity: ${entry.sexualActivity}');

    try {
      // Verificar se já existe
      final existing = await _supabase
          .from('cycle_entry')
          .select('cycle_entry_id')
          .eq('user_id', _userId)
          .eq('entry_date', dateStr)
          .maybeSingle();

      // Converter menstrualFlow para string
      String? flowStr;
      if (entry.menstrualFlow != null) {
        flowStr = entry.menstrualFlow.toString().split('.').last;
      }

      // Converter symptoms para string
      String symptomsStr = '';
      if (entry.symptoms.isNotEmpty) {
        symptomsStr = entry.symptoms
            .map((s) => s.toString().split('.').last)
            .join(',');
      }

      final data = {
        'entry_date': dateStr,
        'symptoms': symptomsStr.isNotEmpty ? symptomsStr : null,
        'menstrual_flow': flowStr,
        'birthcontrol_take': entry.birthControlTaken,
        'ovulation': entry.ovulation,
        'sexual_activity': entry.sexualActivity,
        'cycle_interval': entry.notes,
      };

      print('[CYCLE REPO] Data a gravar: $data');

      if (existing != null) {
        print(
          '[CYCLE REPO] UPDATE - cycle_entry_id: ${existing['cycle_entry_id']}',
        );
        await _supabase
            .from('cycle_entry')
            .update(data)
            .eq('cycle_entry_id', existing['cycle_entry_id']);
        print('[CYCLE REPO] UPDATE concluído!');
      } else {
        print('[CYCLE REPO] INSERT novo registo');
        await _supabase.from('cycle_entry').insert({
          'user_id': _userId,
          ...data,
        });
        print('[CYCLE REPO] INSERT concluído!');
      }
    } catch (e) {
      print('[CYCLE REPO ERROR] $e');
      rethrow;
    }
  }

  /// Apaga entrada
  Future<void> delete(DateTime date) async {
    if (_userId == 0) return;

    final dateStr = _formatDate(date);

    try {
      await _supabase
          .from('cycle_entry')
          .delete()
          .eq('user_id', _userId)
          .eq('entry_date', dateStr);
    } catch (e) {
      print('Erro ao apagar entrada: $e');
      rethrow;
    }
  }

  /// Obtém última menstruação
  Future<DateTime?> getLastPeriodStart() async {
    if (_userId == 0) return null;

    try {
      final response = await _supabase
          .from('cycle_entry')
          .select()
          .eq('user_id', _userId)
          .not('menstrual_flow', 'is', null)
          .neq('menstrual_flow', 'none')
          .order('entry_date', ascending: false)
          .limit(10);

      //if (response == null || (response as List).isEmpty) return null;
      if ((response as List).isEmpty) return null;

      // Encontrar início do último período
      final entries = response.map((json) => _fromJson(json)).toList();

      // Procurar a primeira entrada de um período (sequência de dias com fluxo)
      for (int i = 0; i < entries.length; i++) {
        final entry = entries[i];
        if (entry.menstrualFlow != null &&
            entry.menstrualFlow != MenstrualFlow.none) {
          // Verificar se é início (dia anterior sem fluxo ou não existe)
          if (i == entries.length - 1) {
            return entry.entryDate;
          }
          final prevEntry = entries[i + 1];
          final daysDiff = entry.entryDate
              .difference(prevEntry.entryDate)
              .inDays;
          if (daysDiff > 1 ||
              prevEntry.menstrualFlow == null ||
              prevEntry.menstrualFlow == MenstrualFlow.none) {
            return entry.entryDate;
          }
        }
      }

      return entries.first.entryDate;
    } catch (e) {
      print('Erro ao obter última menstruação: $e');
      return null;
    }
  }

  /// Obtém dados do ciclo para cálculos
  Future<CycleData> getCycleData() async {
    final lastPeriod = await getLastPeriodStart();

    return CycleData(
      cycleLength: 28, // Pode ser calculado com histórico
      periodLength: 5,
      lastPeriodStart: lastPeriod,
    );
  }

  /// Obtém dias com menstruação no mês
  Future<List<int>> getMenstruationDays(int year, int month) async {
    final entries = await getForMonth(year, month);
    return entries
        .where(
          (e) =>
              e.menstrualFlow != null && e.menstrualFlow != MenstrualFlow.none,
        )
        .map((e) => e.entryDate.day)
        .toList();
  }

  /// Obtém dias de ovulação no mês
  Future<List<int>> getOvulationDays(int year, int month) async {
    final entries = await getForMonth(year, month);
    return entries
        .where((e) => e.ovulation)
        .map((e) => e.entryDate.day)
        .toList();
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  CycleEntry _fromJson(Map<String, dynamic> json) {
    // Parsear sintomas
    final symptomsStr = json['symptoms'] as String? ?? '';
    final symptoms = symptomsStr.isNotEmpty
        ? symptomsStr.split(',').map((s) {
            return CycleSymptom.values.firstWhere(
              (e) => e.toString().split('.').last == s.trim(),
              orElse: () => CycleSymptom.cramps,
            );
          }).toList()
        : <CycleSymptom>[];

    // Parsear fluxo
    MenstrualFlow? flow;
    final flowStr = json['menstrual_flow'] as String?;
    if (flowStr != null) {
      flow = MenstrualFlow.values.firstWhere(
        (e) => e.toString().split('.').last == flowStr,
        orElse: () => MenstrualFlow.none,
      );
    }

    return CycleEntry(
      id: (json['cycle_entry_id'] as int).toString(),
      userId: (json['user_id'] as int).toString(),
      entryDate: DateTime.parse(json['entry_date'] as String),
      menstrualFlow: flow,
      symptoms: symptoms,
      birthControlTaken: json['birthcontrol_take'] as bool? ?? false,
      ovulation: json['ovulation'] as bool? ?? false,
      sexualActivity: json['sexual_activity'] as bool? ?? false,
      notes: json['cycle_interval'] as String?,
    );
  }
}
