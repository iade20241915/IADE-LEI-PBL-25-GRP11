import 'package:flutter/material.dart';

import '../core/app_routes.dart';
import '../core/habittus_theme.dart';

class HabittusApp extends StatelessWidget {
  const HabittusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habittus',
      theme: HabittusTheme.light,
      initialRoute: AppRoutes.welcome,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
