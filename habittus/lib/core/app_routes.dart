import 'package:flutter/material.dart';

//import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/mood_inquiry_screen.dart';
import '../screens/register_screen.dart';
import '../screens/sleep_time_screen.dart';
import '../screens/water_intake_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/home_dashboard_screen.dart';
import '../screens/meals_screen.dart';
import '../screens/physical_activity_screen.dart';
import '../screens/habits_screen.dart';
import '../screens/menstrual_cycle_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String water = '/water';
  static const String sleep = '/sleep';
  static const String mood = '/mood';
  static const String meals = '/meals';
  static const String phisical = '/phisical';
  static const String habits = '/habits';
  static const String menstrualCycle = '/menstrual-cycle';

  static final Map<String, WidgetBuilder> routes = {
    welcome: (_) => const WelcomeScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    home: (_) => const HomeDashboardScreen(),
    water: (_) => const WaterIntakeScreen(),
    sleep: (_) => const SleepTimeScreen(),
    mood: (_) => const MoodInquiryScreen(),
    meals: (_) => const MealsScreen(),
    phisical: (_) => const PhysicalActivityScreen(),
    habits: (_) => const HabitsScreen(),
    menstrualCycle: (_) => const MenstrualCycleScreen(),
  };
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // ponto único para lidar com rotas futuras (ex: parâmetros)
    return null;
  }
}
