import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/habittus_app.dart';
import 'controllers/mood_controller.dart';
import 'controllers/sleep_controller.dart';
import 'controllers/water_controller.dart';
import 'controllers/activity_controller.dart';
import 'controllers/habit_controller.dart';
import 'repositories/mock/mock_mood_repository.dart';
import 'repositories/mock/mock_sleep_repository.dart';
import 'repositories/mock/mock_water_repository.dart';
import 'repositories/mock/mock_activity_repository.dart';
import 'repositories/mock/mock_habit_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
      ],
      child: const HabittusApp(),
    ),
  );
}
