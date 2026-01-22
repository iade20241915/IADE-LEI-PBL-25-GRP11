// lib/services/dashboard_data_service.dart
// Mock agora. Depois estas funções chamam as classes do UML (Factory/Repos) que ligam à BD Supabase.
class DashboardDataService {
  Future<List<double>> loadHydrationWeek(DateTime day) async {
    // TODO: UML -> WaterIntake repo -> Supabase
    // Deve devolver 7 valores normalizados 0..1 (para o gráfico)
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const [0.9, 0.8, 0.7, 0.9, 0.85, 0.65, 0.95];
  }

  Future<List<double>> loadSleepWeek(DateTime day) async {
    // TODO: UML -> SleepSession repo -> Supabase
    // Deve devolver 7 valores normalizados 0..1 (para o gráfico)
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const [0.95, 0.75, 0.85, 0.9, 0.8, 0.88, 0.92];
  }
}
