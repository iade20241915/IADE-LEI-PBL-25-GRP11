import '../../core/database/supabase_service.dart';

/// Modelo de dados para registo de Mood
class MoodEntry {
  final int? id;
  final int? userId;
  final int moodTypeId;
  final DateTime createdAt;
  final int? intensity;
  final String? notes;
  
  // Dados adicionais (campos separados na BD)
  final String? sleepQuality;
  final List<String> emotions;
  final List<String> health;
  final List<String> food;
  final List<String> weather;

  const MoodEntry({
    this.id,
    this.userId,
    required this.moodTypeId,
    required this.createdAt,
    this.intensity,
    this.notes,
    this.sleepQuality,
    this.emotions = const [],
    this.health = const [],
    this.food = const [],
    this.weather = const [],
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    // Parse de listas separadas por vírgula
    List<String> parseList(String? value) {
      if (value == null || value.isEmpty) return [];
      return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    
    return MoodEntry(
      id: json['mood_id'] as int?,
      userId: json['user_id'] as int?,
      moodTypeId: json['mood_type_id'] as int? ?? 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      intensity: json['intensity'] as int?,
      notes: json['notes'] as String?,
      sleepQuality: json['sleep_quality'] as String?,
      emotions: parseList(json['emotions'] as String?),
      health: parseList(json['health'] as String?),
      food: parseList(json['food'] as String?),
      weather: parseList(json['weather'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'mood_id': id,
      'mood_type_id': moodTypeId,
      'created_at': createdAt.toIso8601String(),
      if (intensity != null) 'intensity': intensity,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (sleepQuality != null) 'sleep_quality': sleepQuality,
      if (emotions.isNotEmpty) 'emotions': emotions.join(','),
      if (health.isNotEmpty) 'health': health.join(','),
      if (food.isNotEmpty) 'food': food.join(','),
      if (weather.isNotEmpty) 'weather': weather.join(','),
    };
  }
}

/// ============================================================
/// REPOSITÓRIO SUPABASE - MOOD (Estado de Espírito)
/// ============================================================
/// Este repositório implementa as operações CRUD para a tabela 'mood'
/// 
/// ESTRUTURA DA TABELA mood:
/// - mood_id          SERIAL PRIMARY KEY
/// - user_id          INT (FK para users)
/// - mood_type_id     INT (FK para mood_types: 1-5)
/// - created_at       TIMESTAMP
/// - intensity        INT (1-5)
/// - notes            VARCHAR(500) - Notas livres
/// - sleep_quality    VARCHAR(50) - 'Muito Boa', 'Boa', 'OK', 'Má', 'Muito Má'
/// - emotions         VARCHAR(500) - Lista separada por vírgula
/// - health           VARCHAR(500) - Lista separada por vírgula
/// - food             VARCHAR(500) - Lista separada por vírgula
/// - weather          VARCHAR(200) - Lista separada por vírgula
/// ============================================================
class SupabaseMoodRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  int get _userId => _supabase.currentUserId ?? 0;

  // ============================================================
  // SELECT - Obter mood para uma data específica
  // ============================================================
  // Query SQL equivalente:
  // SELECT m.*, mt.* FROM mood m
  // LEFT JOIN mood_types mt ON m.mood_type_id = mt.mood_type_id
  // WHERE m.user_id = $1
  //   AND m.created_at >= $2 AND m.created_at < $3
  // ORDER BY m.created_at DESC LIMIT 1;
  // ============================================================
  Future<MoodEntry?> getForDate(DateTime date) async {
    if (_userId == 0) {
      print('[MOOD SELECT] userId é 0, retornando null');
      return null;
    }

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    print('[MOOD SELECT] Buscando mood para user=$_userId, data=$startOfDay');

    try {
      // ============================================================
      // QUERY: SELECT com JOIN para obter mood e mood_type
      // ============================================================
      final response = await _supabase
          .from('mood')
          .select('*, mood_types(*)')
          .eq('user_id', _userId)
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String())
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        print('[MOOD SELECT] Nenhum registo encontrado');
        return null;
      }
      
      print('[MOOD SELECT] Encontrado: mood_id=${response['mood_id']}, type=${response['mood_type_id']}');
      print('[MOOD SELECT] Dados extras: sleep=${response['sleep_quality']}, emotions=${response['emotions']}');
      return MoodEntry.fromJson(response);
    } catch (e) {
      print('[MOOD SELECT ERROR] $e');
      return null;
    }
  }

  // ============================================================
  // INSERT / UPDATE - Guardar ou atualizar mood (UPSERT)
  // ============================================================
  Future<void> save(MoodEntry entry) async {
    if (_userId == 0) {
      print('[MOOD SAVE] userId é 0, abortando');
      return;
    }

    final startOfDay = DateTime(entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    print('[MOOD SAVE] Guardando para user=$_userId, data=$startOfDay');
    print('[MOOD SAVE] Dados: type=${entry.moodTypeId}, sleep=${entry.sleepQuality}');
    print('[MOOD SAVE] Listas: emotions=${entry.emotions}, health=${entry.health}');

    try {
      // Verificar se já existe registo
      final existing = await _supabase
          .from('mood')
          .select('mood_id')
          .eq('user_id', _userId)
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String())
          .maybeSingle();

      // ============================================================
      // DADOS A GUARDAR (todos os campos)
      // ============================================================
      final data = {
        'mood_type_id': entry.moodTypeId,
        'intensity': entry.intensity,
        'notes': entry.notes,
        'sleep_quality': entry.sleepQuality,
        'emotions': entry.emotions.isNotEmpty ? entry.emotions.join(',') : null,
        'health': entry.health.isNotEmpty ? entry.health.join(',') : null,
        'food': entry.food.isNotEmpty ? entry.food.join(',') : null,
        'weather': entry.weather.isNotEmpty ? entry.weather.join(',') : null,
      };

      if (existing != null) {
        // ============================================================
        // UPDATE - Atualizar registo existente
        // ============================================================
        print('[MOOD UPDATE] Atualizando mood_id=${existing['mood_id']}');
        
        await _supabase
            .from('mood')
            .update(data)
            .eq('mood_id', existing['mood_id']);
            
        print('[MOOD UPDATE] Sucesso!');
      } else {
        // ============================================================
        // INSERT - Criar novo registo
        // ============================================================
        print('[MOOD INSERT] Criando novo registo');
        
        await _supabase
            .from('mood')
            .insert({
              'user_id': _userId,
              'created_at': entry.createdAt.toIso8601String(),
              ...data,
            });
            
        print('[MOOD INSERT] Sucesso!');
      }
    } catch (e) {
      print('[MOOD SAVE ERROR] $e');
      rethrow;
    }
  }

  // ============================================================
  // SELECT - Obter tipos de mood disponíveis
  // ============================================================
  Future<List<Map<String, dynamic>>> getMoodTypes() async {
    print('[MOOD_TYPES SELECT] Obtendo tipos de mood');
    
    try {
      final response = await _supabase
          .from('mood_types')
          .select()
          .order('mood_type_id');

      print('[MOOD_TYPES SELECT] Encontrados ${(response as List).length} tipos');
      return response.cast<Map<String, dynamic>>();
    } catch (e) {
      print('[MOOD_TYPES SELECT ERROR] $e');
      return [];
    }
  }

  // ============================================================
  // SELECT - Obter moods da semana para gráfico
  // ============================================================
  Future<List<MoodEntry>> getWeekMoods(DateTime endDate) async {
    if (_userId == 0) return [];
    
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final start = end.subtract(const Duration(days: 6));
    
    print('[MOOD WEEK SELECT] De $start a $end');

    try {
      final response = await _supabase
          .from('mood')
          .select('*, mood_types(*)')
          .eq('user_id', _userId)
          .gte('created_at', start.toIso8601String())
          .lt('created_at', end.add(const Duration(days: 1)).toIso8601String())
          .order('created_at');

      final moods = (response as List)
          .map((e) => MoodEntry.fromJson(e))
          .toList();
          
      print('[MOOD WEEK SELECT] Encontrados ${moods.length} registos');
      return moods;
    } catch (e) {
      print('[MOOD WEEK SELECT ERROR] $e');
      return [];
    }
  }

  // ============================================================
  // DELETE - Apagar registo de mood
  // ============================================================
  Future<void> delete(int moodId) async {
    print('[MOOD DELETE] Apagando mood_id=$moodId');
    
    try {
      await _supabase
          .from('mood')
          .delete()
          .eq('mood_id', moodId);
          
      print('[MOOD DELETE] Sucesso!');
    } catch (e) {
      print('[MOOD DELETE ERROR] $e');
      rethrow;
    }
  }
}
