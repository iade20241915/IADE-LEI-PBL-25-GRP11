import 'package:flutter/material.dart';

import '../core/app_routes.dart';
import '../widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                'Habittus',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Login',
                onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                text: 'Registar',
                onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
