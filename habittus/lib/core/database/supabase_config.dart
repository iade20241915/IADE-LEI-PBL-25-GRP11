/// Configuração do Supabase
class SupabaseConfig {
  /// URL do projeto Supabase
  static const String url = 'https://uqilaikcvbnxqieqdtwp.supabase.co';

  /// Chave anónima (pública) do Supabase
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVxaWxhaWtjdmJueHFpZXFkdHdwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkwOTE1NTYsImV4cCI6MjA4NDY2NzU1Nn0.3lKphmO0YItpZu52ftBgUq5uYbjqe9BKNRdsf8AXILs';

  /// Credenciais do utilizador de serviço (para autenticar a app)
  static const String serviceEmail = 'app@habittus.com';
  static const String servicePassword = 'HabittusApp2025!';

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
