import 'package:flutter/material.dart';

import '../core/app_routes.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Habittus',
                  style: TextStyle(fontSize: 42, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 24),
              _field('Name', 'escreva o seu nome aqui'),
              _field('Birthday', '08/11/2023'),
              _field('Email', 'escreva o seu email'),
              _field('Confirm Email', 'confirme o seu email'),
              _field('Password', 'defina uma password', obscure: true),
              _field('Confirm Password', 'confirme a password', obscure: true),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 140,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('Submeter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, String hint, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: hint,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: Colors.green),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
