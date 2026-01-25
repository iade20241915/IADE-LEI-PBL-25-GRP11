import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/activity_controller.dart';
import '../models/physical_activity.dart';
import '../widgets/habittus_app_bar.dart';
import '../widgets/habittus_drawer.dart';
import '../widgets/habittus_card.dart';
import '../widgets/date_pills.dart';
import '../widgets/weekly_activity_chart.dart';
import '../widgets/habittus_icons.dart';
import 'add_activity_screen.dart';

class PhysicalActivityScreen extends StatefulWidget {
  const PhysicalActivityScreen({super.key});

  @override
  State<PhysicalActivityScreen> createState() => _PhysicalActivityScreenState();
}

class _PhysicalActivityScreenState extends State<PhysicalActivityScreen> {
  late DateTime selectedDate;
  final String visitorId = 'mock_user_123'; // TODO: Pegar do auth

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);

    // Carrega atividades iniciais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadActivities();
    });
  }

  void _loadActivities() {
    final controller = context.read<ActivityController>();
    controller.load(selectedDate, forceReload: true);
  }

  String get monthName => const [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ][selectedDate.month - 1];

  void _changeDate(DateTime newDate) {
    setState(() {
      selectedDate = DateTime(newDate.year, newDate.month, newDate.day);
    });
    _loadActivities();
  }

  Future<void> _openAddActivity() async {
    final result = await Navigator.push<PhysicalActivity>(
      context,
      MaterialPageRoute(builder: (_) => AddActivityScreen(date: selectedDate)),
    );

    if (result != null && mounted) {
      final controller = context.read<ActivityController>();
      await controller.addActivity(result);
      _showSuccessSnackBar('Atividade adicionada com sucesso!');
    }
  }

  Future<void> _editActivity(PhysicalActivity activity) async {
    final result = await Navigator.push<PhysicalActivity>(
      context,
      MaterialPageRoute(
        builder: (_) => AddActivityScreen(
          date: activity.timestamp,
          activityToEdit: activity,
        ),
      ),
    );

    if (result != null && mounted) {
      final controller = context.read<ActivityController>();
      await controller.updateActivity(result);
      _showSuccessSnackBar('Atividade atualizada com sucesso!');
    }
  }

  Future<void> _deleteActivity(PhysicalActivity activity) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
          'Deseja remover a atividade "${activity.activityType.label}"?',
        ),
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
      final controller = context.read<ActivityController>();
      await controller.deleteActivity(activity.id);
      _showSuccessSnackBar('Atividade removida!');
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
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddActivity,
        backgroundColor: const Color(0xFF2F5D2F),
        child: const Icon(HabittusIcons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Consumer<ActivityController>(
          builder: (context, controller, child) {
            if (controller.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      HabittusIcons.info,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(controller.error!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadActivities,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            // Filtra atividades do dia selecionado
            final activitiesToday = controller.activities.where((a) {
              return a.timestamp.year == selectedDate.year &&
                  a.timestamp.month == selectedDate.month &&
                  a.timestamp.day == selectedDate.day;
            }).toList();

            // Calcula totais do dia
            final totalMinutes = activitiesToday.fold<int>(
              0,
              (sum, a) => sum + a.durationMinutes,
            );
            final totalCalories = activitiesToday.fold<int>(
              0,
              (sum, a) => sum + (a.caloriesBurned ?? 0),
            );

            // Dados para gráfico semanal
            final weeklyValues = controller.weeklyChartValues;
            final weekLabels = controller.weeklyLabels;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Seletor de data
                DatePills(
                  day: '${selectedDate.day}',
                  month: monthName,
                  year: '${selectedDate.year}',
                  onDayPrev: () => _changeDate(
                    selectedDate.subtract(const Duration(days: 1)),
                  ),
                  onDayNext: () =>
                      _changeDate(selectedDate.add(const Duration(days: 1))),
                  onMonthPrev: () => _changeDate(
                    DateTime(
                      selectedDate.year,
                      selectedDate.month - 1,
                      selectedDate.day,
                    ),
                  ),
                  onMonthNext: () => _changeDate(
                    DateTime(
                      selectedDate.year,
                      selectedDate.month + 1,
                      selectedDate.day,
                    ),
                  ),
                  onYearPrev: () => _changeDate(
                    DateTime(
                      selectedDate.year - 1,
                      selectedDate.month,
                      selectedDate.day,
                    ),
                  ),
                  onYearNext: () => _changeDate(
                    DateTime(
                      selectedDate.year + 1,
                      selectedDate.month,
                      selectedDate.day,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Card de resumo do dia
                HabittusCard(
                  title: 'Resumo do dia',
                  subtitle: 'Atividade física',
                  child: Column(
                    children: [
                      _SummaryRow(
                        icon: HabittusIcons.timer,
                        label: 'Duração total',
                        value: '$totalMinutes min',
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        icon: HabittusIcons.calories,
                        label: 'Calorias queimadas',
                        value: '$totalCalories kcal',
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        icon: HabittusIcons.activity,
                        label: 'Atividades',
                        value: '${activitiesToday.length}',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Lista de atividades do dia
                HabittusCard(
                  title: 'Atividades realizadas',
                  subtitle: controller.isLoading
                      ? 'Carregando...'
                      : '${activitiesToday.length} atividade${activitiesToday.length != 1 ? 's' : ''}',
                  child: controller.isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : activitiesToday.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  HabittusIcons.run,
                                  size: 48,
                                  color: Colors.black38,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Nenhuma atividade registada',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Toca no + para adicionar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: activitiesToday
                              .map(
                                (activity) => _ActivityTile(
                                  activity: activity,
                                  onTap: () => _editActivity(activity),
                                  onDelete: () => _deleteActivity(activity),
                                ),
                              )
                              .toList(),
                        ),
                ),

                const SizedBox(height: 14),

                // Gráfico semanal
                HabittusCard(
                  title: 'Progresso semanal',
                  subtitle: 'Últimos 7 dias',
                  child: WeeklyActivityChart(
                    minutes: controller.weeklyMinutes,
                    labels: weekLabels,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Widget para linha de resumo
class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE4EAD8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF244A24), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: Color(0xFF2F5D2F),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para tile de atividade
class _ActivityTile extends StatelessWidget {
  final PhysicalActivity activity;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ActivityTile({
    required this.activity,
    required this.onTap,
    required this.onDelete,
  });

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE4EAD8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Ícone da atividade
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2F5D2F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    activity.activityType.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Informações
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.activityType.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${activity.durationMinutes} min',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const Text(
                          ' • ',
                          style: TextStyle(color: Colors.black54),
                        ),
                        Text(
                          activity.intensity.label,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        if (activity.caloriesBurned != null) ...[
                          const Text(
                            ' • ',
                            style: TextStyle(color: Colors.black54),
                          ),
                          Text(
                            '${activity.caloriesBurned} kcal',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Hora
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(activity.timestamp),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDDE6D3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(HabittusIcons.delete, size: 16),
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
