import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import '../screens/mood_inquiry_screen.dart';
import '../screens/water_intake_screen.dart';
import '../screens/sleep_time_screen.dart';
import '../screens/meals_screen.dart';
import '../screens/physical_activity_screen.dart';
import '../screens/habits_screen.dart';
import '../screens/menstrual_cycle_screen.dart';
import '../screens/home_dashboard_screen.dart';
import '../screens/profile_screen.dart';
import 'habittus_icons.dart';

class HabittusDrawer extends StatelessWidget {
  final String? userName;
  final bool isDashboard;

  const HabittusDrawer({
    super.key,
    this.userName,
    this.isDashboard = false,
  });

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>();
    final displayName = userName ?? userController.userName;
    final userInitials = userController.userInitials;
    final isFemale = userController.isFemale;
    final label = isDashboard ? 'Voltar ao Login' : 'Voltar';

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar clicável
              InkWell(
                onTap: () {
                  Navigator.pop(context); // Fechar drawer
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(40),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF2F5D2F),
                  child: Text(
                    userInitials,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4EAD8),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          'Olá, $displayName',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Mural / Dashboard
                        _MenuItem(
                          icon: HabittusIcons.dashboard,
                          label: 'Mural',
                          color: HabittusIcons.primaryColor,
                          onTap: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const HomeDashboardScreen(),
                              ),
                              (route) => false,
                            );
                          },
                        ),

                        const Divider(height: 16, indent: 16, endIndent: 16),

                        _MenuItem(
                          icon: HabittusIcons.emotion,
                          label: 'Humor',
                          color: HabittusIcons.moodColor,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MoodInquiryScreen(isFemale: isFemale),
                              ),
                            );
                          },
                        ),
                        _MenuItem(
                          icon: HabittusIcons.water,
                          label: 'Hidratação',
                          color: HabittusIcons.waterColor,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const WaterIntakeScreen(),
                              ),
                            );
                          },
                        ),
                        _MenuItem(
                          icon: HabittusIcons.meal,
                          label: 'Alimentação',
                          color: HabittusIcons.foodColor,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const MealsScreen(),
                              ),
                            );
                          },
                        ),
                        _MenuItem(
                          icon: HabittusIcons.sleep,
                          label: 'Sono',
                          color: HabittusIcons.sleepColor,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SleepTimeScreen(),
                              ),
                            );
                          },
                        ),
                        _MenuItem(
                          icon: HabittusIcons.activity,
                          label: 'Atividade Física',
                          color: HabittusIcons.activityColor,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PhysicalActivityScreen(),
                              ),
                            );
                          },
                        ),
                        _MenuItem(
                          icon: HabittusIcons.habit,
                          label: 'Hábitos e Vícios',
                          color: HabittusIcons.habitColor,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const HabitsScreen(),
                              ),
                            );
                          },
                        ),
                        
                        // ✅ Ciclo Menstrual - só para utilizadores femininos
                        if (isFemale)
                          _MenuItem(
                            icon: HabittusIcons.cycle,
                            label: 'Ciclo Menstrual',
                            color: HabittusIcons.cycleColor,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const MenstrualCycleScreen(),
                                ),
                              );
                            },
                          ),

                        const Divider(height: 32, indent: 16, endIndent: 16),

                        _MenuItem(
                          icon: HabittusIcons.back,
                          label: label,
                          color: Colors.black54,
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
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
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        Navigator.pop(context); // fecha drawer
        onTap();
      },
      horizontalTitleGap: 8,
    );
  }
}
