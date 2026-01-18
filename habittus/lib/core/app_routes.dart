import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/mood_inquiry_screen.dart';
import '../screens/register_screen.dart';
import '../screens/sleep_time_screen.dart';
import '../screens/water_intake_screen.dart';
import '../screens/welcome_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String water = '/water';
  static const String sleep = '/sleep';
  static const String mood = '/mood';

  static final Map<String, WidgetBuilder> routes = {
    welcome: (_) => const WelcomeScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    home: (_) => const HomeScreen(),
    water: (_) => const WaterIntakeScreen(),
    sleep: (_) => const SleepTimeScreen(),
    mood: (_) => const MoodInquiryScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // ponto único para lidar com rotas futuras (ex: parâmetros)
    return null;
  }
}
