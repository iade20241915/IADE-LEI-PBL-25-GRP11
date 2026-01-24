import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/habittus_app.dart';
import 'core/database/supabase_service.dart';
import 'controllers/water_controller.dart';
import 'controllers/sleep_controller.dart';
import 'controllers/mood_controller.dart';
import 'controllers/activity_controller.dart';
import 'controllers/habit_controller.dart';
import 'controllers/cycle_controller.dart';

// Repositórios Mock
import 'repositories/mock/mock_water_repository.dart';
import 'repositories/mock/mock_sleep_repository.dart';
import 'repositories/mock/mock_mood_repository.dart';
import 'repositories/mock/mock_activity_repository.dart';
import 'repositories/mock/mock_habit_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await SupabaseService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WaterController(MockWaterRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => SleepController(MockSleepRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => MoodController(MockMoodRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ActivityController(MockActivityRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => HabitController(MockHabitRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => CycleController(),
        ),
      ],
      child: const HabittusApp(),
    ),
  );
}
