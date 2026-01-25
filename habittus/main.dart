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
import 'controllers/meal_controller.dart';
import 'controllers/user_controller.dart';

// Repositórios Supabase
import 'repositories/supabase/supabase_water_repository.dart';
import 'repositories/supabase/supabase_sleep_repository.dart';
import 'repositories/supabase/supabase_activity_repository.dart';
import 'repositories/supabase/supabase_habit_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await SupabaseService.initialize();

  runApp(
    MultiProvider(
      providers: [
        // UserController - carregado após login
        ChangeNotifierProvider(create: (_) => UserController()),
        
        // Outros controllers
        ChangeNotifierProvider(
          create: (_) => WaterController(SupabaseWaterRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => SleepController(SupabaseSleepRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ActivityController(SupabaseActivityRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => HabitController(SupabaseHabitRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => CycleController(),
        ),
        ChangeNotifierProvider(
          create: (_) => MoodController(),
        ),
        ChangeNotifierProvider(
          create: (_) => MealController(),
        ),
      ],
      child: const HabittusApp(),
    ),
  );
}
