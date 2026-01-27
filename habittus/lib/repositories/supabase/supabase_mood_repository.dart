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
/// Utiliza queries SQL através da API do Supabase
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
          .select('*, mood_types(*)')        // JOIN com mood_types
          .eq('user_id', _userId)            // WHERE user_id = $1
          .gte('created_at', startOfDay.toIso8601String())  // AND created_at >= $2
          .lt('created_at', endOfDay.toIso8601String())     // AND created_at < $3
          .order('created_at', ascending: false)  // ORDER BY created_at DESC
          .limit(1)                          // LIMIT 1
          .maybeSingle();                    // Retorna null se não existir

      if (response == null) {
        print('[MOOD SELECT] Nenhum registo encontrado');
        return null;
      }
      
      print('[MOOD SELECT] Encontrado: mood_id=${response['mood_id']}, type=${response['mood_type_id']}');
      return MoodEntry.fromJson(response);
    } catch (e) {
      print('[MOOD SELECT ERROR] $e');
      return null;
    }
  }

  // ============================================================
  // INSERT / UPDATE - Guardar ou atualizar mood (UPSERT)
  // ============================================================
  // Se já existe registo para o dia: UPDATE
  // Se não existe: INSERT
  // ============================================================
  Future<void> save(MoodEntry entry) async {
    if (_userId == 0) {
      print('[MOOD SAVE] userId é 0, abortando');
      return;
    }

    final startOfDay = DateTime(entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    print('[MOOD SAVE] Guardando mood_type=${entry.moodTypeId} para user=$_userId, data=$startOfDay');

    try {
      // ============================================================
      // QUERY: SELECT para verificar se já existe registo
      // SELECT mood_id FROM mood 
      // WHERE user_id = $1 AND created_at >= $2 AND created_at < $3
      // ============================================================
      final existing = await _supabase
          .from('mood')
          .select('mood_id')
          .eq('user_id', _userId)
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String())
          .maybeSingle();

      // Dados a guardar
      final data = {
        'mood_type_id': entry.moodTypeId,
        'intensity': entry.intensity,
        'notes': entry.notes,
      };

      if (existing != null) {
        // ============================================================
        // QUERY: UPDATE - Atualizar registo existente
        // UPDATE mood SET mood_type_id=$1, intensity=$2, notes=$3
        // WHERE mood_id = $4
        // ============================================================
        print('[MOOD UPDATE] Atualizando mood_id=${existing['mood_id']}');
        
        await _supabase
            .from('mood')
            .update(data)
            .eq('mood_id', existing['mood_id']);
            
        print('[MOOD UPDATE] Sucesso!');
      } else {
        // ============================================================
        // QUERY: INSERT - Criar novo registo
        // INSERT INTO mood (user_id, mood_type_id, created_at, intensity, notes)
        // VALUES ($1, $2, $3, $4, $5)
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
  // Query SQL:
  // SELECT * FROM mood_types ORDER BY mood_type_id
  // ============================================================
  Future<List<Map<String, dynamic>>> getMoodTypes() async {
    print('[MOOD_TYPES SELECT] Obtendo tipos de mood');
    
    try {
      // ============================================================
      // QUERY: SELECT todos os tipos de mood
      // ============================================================
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
  // SELECT / INSERT - Obter ou criar tipo de mood
  // ============================================================
  Future<int> getOrCreateMoodType(String moodName) async {
    print('[MOOD_TYPE] Obtendo/criando tipo: $moodName');
    
    try {
      // ============================================================
      // QUERY: SELECT para verificar se tipo existe
      // SELECT mood_type_id FROM mood_types WHERE mood = $1
      // ============================================================
      final existing = await _supabase
          .from('mood_types')
          .select('mood_type_id')
          .eq('mood', moodName)
          .maybeSingle();

      if (existing != null) {
        print('[MOOD_TYPE SELECT] Encontrado: ${existing['mood_type_id']}');
        return existing['mood_type_id'] as int;
      }

      // ============================================================
      // QUERY: INSERT novo tipo de mood
      // INSERT INTO mood_types (mood) VALUES ($1) RETURNING mood_type_id
      // ============================================================
      print('[MOOD_TYPE INSERT] Criando novo tipo');
      
      final result = await _supabase
          .from('mood_types')
          .insert({'mood': moodName})
          .select('mood_type_id')
          .single();

      print('[MOOD_TYPE INSERT] Criado: ${result['mood_type_id']}');
      return result['mood_type_id'] as int;
    } catch (e) {
      print('[MOOD_TYPE ERROR] $e');
      return 1;
    }
  }

  // ============================================================
  // SELECT - Obter moods da semana para gráfico
  // ============================================================
  // Query SQL:
  // SELECT * FROM mood 
  // WHERE user_id = $1 AND created_at >= $2 AND created_at < $3
  // ORDER BY created_at ASC
  // ============================================================
  Future<List<MoodEntry>> getWeekMoods(DateTime endDate) async {
    if (_userId == 0) return [];
    
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final start = end.subtract(const Duration(days: 6));
    
    print('[MOOD WEEK SELECT] De $start a $end');

    try {
      // ============================================================
      // QUERY: SELECT moods da semana com JOIN
      // ============================================================
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
  // Query SQL:
  // DELETE FROM mood WHERE mood_id = $1
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
