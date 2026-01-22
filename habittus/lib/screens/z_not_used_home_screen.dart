import 'package:flutter/material.dart';

import '../core/app_routes.dart';
import '../widgets/habittus_app_bar.dart';
import '../widgets/habittus_card.dart';
import '../widgets/habittus_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HabittusDrawer(userName: 'USER_NAME'),
      appBar: const HabittusAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            //const DateSelector(day: '25', month: 'September', year: '2025'),
            const SizedBox(height: 16),

            HabittusCard(
              title: 'Atalhos',
              subtitle: 'Aceder rapidamente aos registos',
              child: Row(
                children: [
                  Expanded(
                    child: _Shortcut(
                      label: 'Água',
                      icon: Icons.water_drop_outlined,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.water),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Shortcut(
                      label: 'Sono',
                      icon: Icons.bedtime_outlined,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.sleep),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Shortcut(
                      label: 'Mood',
                      icon: Icons.emoji_emotions_outlined,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.mood),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const HabittusCard(
              title: 'Fotos deste dia',
              subtitle: 'Imagens guardadas neste dia',
              child: SizedBox(height: 90, child: _PhotosPlaceholder()),
            ),

            const SizedBox(height: 16),

            const HabittusCard(
              title: 'Hidratação',
              subtitle: 'Histórico semanal',
              child: _ChartPlaceholder(height: 120),
            ),

            const SizedBox(height: 16),

            const HabittusCard(
              title: 'Horas de Descanso',
              subtitle: 'Histórico semanal',
              child: _ChartPlaceholder(height: 120),
            ),
          ],
        ),
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _Shortcut({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF3E3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.green.shade800),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _PhotosPlaceholder extends StatelessWidget {
  const _PhotosPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (_) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  final double height;
  const _ChartPlaceholder({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3E3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          'Gráfico (placeholder)',
          style: TextStyle(color: Colors.green.shade800, fontSize: 12),
        ),
      ),
    );
  }
}
