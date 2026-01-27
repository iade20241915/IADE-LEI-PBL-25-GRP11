import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/habit_controller.dart';
import '../core/database/supabase_service.dart';
import '../models/habit.dart';
import '../widgets/habittus_app_bar.dart';
import '../widgets/habittus_drawer.dart';
import 'add_habit_screen.dart';
import 'habit_detail_screen.dart';
import 'habit_setup_screen.dart';
import 'habit_dashboard_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String get userId => SupabaseService.instance.currentUserId?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Carrega hábitos iniciais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitController>().loadHabits(userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openAddHabit(HabitType type) async {
    // Usar tela de setup detalhada para vícios
    if (type == HabitType.negative) {
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(builder: (_) => HabitSetupScreen(type: type)),
      );

      if (result != null && mounted) {
        final habit = result['habit'] as Habit;
        final controller = context.read<HabitController>();
        await controller.addHabit(habit);
        _showSuccessSnackBar('Hábito adicionado com sucesso!');

        // Navegar para o dashboard do hábito
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HabitDashboardScreen(
                habit: habit,
                startDate: result['startDate'] as DateTime,
                dailyCost: (result['dailyCost'] as double?) ?? 5.0,
                motivation: result['motivation'] as String?,
              ),
            ),
          );
        }
      }
    } else {
      // Usar tela simples para hábitos positivos
      final result = await Navigator.push<Habit>(
        context,
        MaterialPageRoute(builder: (_) => AddHabitScreen(type: type)),
      );

      if (result != null && mounted) {
        final controller = context.read<HabitController>();
        await controller.addHabit(result);
        _showSuccessSnackBar('Hábito adicionado com sucesso!');
      }
    }
  }

  Future<void> _openHabitDetail(Habit habit) async {
    // Para vícios, abrir dashboard com contador
    if (habit.type == HabitType.negative) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HabitDashboardScreen(
            habit: habit,
            startDate: habit.createdAt, // Usar data de criação como início
            dailyCost: 5.0, // TODO: Guardar no modelo
          ),
        ),
      );
    } else {
      // Para hábitos positivos, usar tela de detalhes normal
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HabitDetailScreen(habit: habit)),
      );
    }

    // Recarrega após voltar
    if (mounted) {
      context.read<HabitController>().loadHabits(userId);
    }
  }

  Future<void> _deleteHabit(Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja remover o hábito "${habit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final controller = context.read<HabitController>();
      await controller.deleteHabit(habit.id);
      _showSuccessSnackBar('Hábito removido!');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2F5D2F),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HabittusDrawer(userName: 'USER_NAME'),
      appBar: const HabittusAppBar(showBack: true),
      backgroundColor: const Color(0xFFF6F8F0),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hábitos',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Acompanhe e controle seus hábitos',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),

                  // Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4EAD8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: const Color(0xFF2F5D2F),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black87,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      tabs: const [
                        Tab(text: '🚫 A Reduzir'),
                        Tab(text: '✅ Positivos'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Consumer<HabitController>(
                builder: (context, controller, child) {
                  if (controller.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(controller.error!),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => controller.loadHabits(userId),
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      // Hábitos negativos
                      _HabitsList(
                        habits: controller.negativeHabits,
                        emptyMessage: 'Nenhum hábito a reduzir',
                        emptyIcon: Icons.celebration_outlined,
                        onTap: _openHabitDetail,
                        onDelete: _deleteHabit,
                      ),

                      // Hábitos positivos
                      _HabitsList(
                        habits: controller.positiveHabits,
                        emptyMessage: 'Nenhum hábito positivo',
                        emptyIcon: Icons.add_circle_outline,
                        onTap: _openHabitDetail,
                        onDelete: _deleteHabit,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // FAB com menu
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(),
        backgroundColor: const Color(0xFF2F5D2F),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFFE4EAD8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Adicionar Hábito',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            _AddOptionTile(
              icon: Icons.warning_amber,
              title: 'Hábito a Reduzir',
              subtitle: 'Vícios ou hábitos negativos',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                _openAddHabit(HabitType.negative);
              },
            ),

            const SizedBox(height: 12),

            _AddOptionTile(
              icon: Icons.star,
              title: 'Hábito Positivo',
              subtitle: 'Hábitos saudáveis e produtivos',
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                _openAddHabit(HabitType.positive);
              },
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para lista de hábitos
class _HabitsList extends StatelessWidget {
  final List<Habit> habits;
  final String emptyMessage;
  final IconData emptyIcon;
  final Function(Habit) onTap;
  final Function(Habit) onDelete;

  const _HabitsList({
    required this.habits,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: Colors.black38),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            const Text(
              'Toca no + para adicionar',
              style: TextStyle(fontSize: 12, color: Colors.black38),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        return _HabitTile(
          habit: habit,
          onTap: () => onTap(habit),
          onDelete: () => onDelete(habit),
        );
      },
    );
  }
}

/// Widget para tile de hábito
class _HabitTile extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HabitTile({
    required this.habit,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE4EAD8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Emoji/Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: habit.type == HabitType.negative
                      ? Colors.orange.shade100
                      : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    habit.emoji ?? habit.category.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    if (habit.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        habit.description!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Actions
              Column(
                children: [
                  const Icon(Icons.chevron_right),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDDE6D3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline, size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget para opção de adicionar
class _AddOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AddOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8F0),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
