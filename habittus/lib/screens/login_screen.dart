import 'package:flutter/material.dart';

import '../core/app_routes.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  'Habittus',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 48),
                _field(label: 'Login', hint: 'Your email or login', icon: Icons.person_outline),
                const SizedBox(height: 16),
                _field(label: 'Password', hint: '********', icon: Icons.lock_outline, obscure: true),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: 'Enter',
                  onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
                  width: double.infinity,
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: 'Voltar',
                  onPressed: () => Navigator.pop(context),
                  width: double.infinity,
                  filled: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 6),
        TextField(
          obscureText: obscure,
          decoration: InputDecoration(hintText: hint, suffixIcon: Icon(icon, color: Colors.green)),
        ),
      ],
    );
  }
}
