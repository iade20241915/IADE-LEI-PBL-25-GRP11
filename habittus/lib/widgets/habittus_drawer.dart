import 'package:flutter/material.dart';

class HabittusDrawer extends StatelessWidget {
  final String userName;

  const HabittusDrawer({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFFBFDFA8),
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4EAD8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                      'Olá, $userName',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _MenuItem(
                      icon: Icons.emoji_emotions_outlined,
                      label: 'Humor',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.water_drop_outlined,
                      label: 'Hidratação',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.restaurant_outlined,
                      label: 'Alimentação',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.bed_outlined,
                      label: 'Sono',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.directions_run_outlined,
                      label: 'Atividade Física',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.no_drinks_outlined,
                      label: 'Hábitos e Vícios',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.calendar_month_outlined,
                      label: 'Ciclo Menstrual',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.settings_outlined,
                      label: 'Configurações',
                      onTap: () {},
                    ),

                    const Divider(height: 32),

                    _MenuItem(
                      icon: Icons.arrow_back,
                      label: 'Voltar ao Dashboard',
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      onTap: () {
        Navigator.pop(context); // fecha drawer
        onTap();
      },
      horizontalTitleGap: 8,
    );
  }
}
