/// Configuração do Supabase
/// 
/// Este ficheiro contém as credenciais de acesso ao Supabase.
/// NOTA: Em produção, estas credenciais devem estar em variáveis de ambiente.
class SupabaseConfig {
  /// URL do projeto Supabase
  static const String url = 'https://uqilaikcvbnxqieqdtwp.supabase.co';

  /// Chave anónima (pública) do Supabase
  static const String anonKey = 'sb_publishable_muRerJu8naPm6EKqWxET-Q_XBKO21Gh';

  /// Tabelas da base de dados
  static const String usersTable = 'users';
  static const String waterIntakeTable = 'water_intake';
  static const String mealTable = 'meal';
  static const String mealItemTable = 'meal_item';
  static const String foodTable = 'food';
  static const String sleepSessionTable = 'sleep_session';
  static const String moodTable = 'mood';
  static const String moodTypesTable = 'mood_types';
  static const String activityTable = 'activity';
  static const String activityTypesTable = 'activity_types';
  static const String activityTrackPointsTable = 'activity_track_points';
  static const String habitsTable = 'habits';
  static const String habitTypesTable = 'habit_types';
  static const String cycleEntryTable = 'cycle_entry';
  static const String goalTable = 'goal';
  static const String reminderTable = 'reminder';
  static const String fotosTable = 'fotos';
}
