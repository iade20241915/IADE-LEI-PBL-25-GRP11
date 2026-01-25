import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/habit_controller.dart';
import '../models/habit.dart';
import '../widgets/habittus_app_bar.dart';
import '../widgets/habittus_card.dart';

class HabitDashboardScreen extends StatefulWidget {
  final Habit habit;
  final DateTime startDate;
  final double dailyCost;
  final String? motivation;

  const HabitDashboardScreen({
    super.key,
    required this.habit,
    required this.startDate,
    this.dailyCost = 5.0,
    this.motivation,
  });

  @override
  State<HabitDashboardScreen> createState() => _HabitDashboardScreenState();
}

class _HabitDashboardScreenState extends State<HabitDashboardScreen> {
  late Timer _timer;
  late Duration _timeSinceStart;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());

    // Carregar logs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitController>().loadHabitLogs(widget.habit.id);
    });
  }

  void _updateTime() {
    setState(() {
      _timeSinceStart = DateTime.now().difference(widget.startDate);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  double get moneySaved {
    return _timeSinceStart.inDays * widget.dailyCost;
  }

  Future<void> _registerRelapse() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFE4EAD8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF8B9A7D),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hábitos nocivos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Controlo e cessação de vícios...',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parabéns',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Estás a dar os primeiros passos para reconhecer e melhorar os teus hábitos. Vamos começar juntos.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Continuar',
              style: TextStyle(color: Color(0xFF2F5D2F)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Registrar recaída
      final log = HabitLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        habitId: widget.habit.id,
        userId: 'mock_user_123',
        timestamp: DateTime.now(),
        quantity: 1,
        notes: 'Recaída registada',
        mood: HabitMood.bad,
      );

      await context.read<HabitController>().addHabitLog(log);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não desistas! Cada dia é uma nova oportunidade.'),
            backgroundColor: Color(0xFF2F5D2F),
          ),
        );
      }
    }
  }

  Future<void> _addMotivation() async {
    final notesController = TextEditingController(text: widget.motivation);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFE4EAD8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.edit_note, color: Color(0xFF244A24)),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Porque estou a fazer isto',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'As minhas motivações...',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF8B9A7D)),
          ),
          child: TextField(
            controller: notesController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
              label: Text('Notas livres'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              notesController.clear();
            },
            child: const Text('Clear', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Gravar',
              style: TextStyle(color: Color(0xFF2F5D2F)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _timeSinceStart.inDays;
    final hours = _timeSinceStart.inHours % 24;
    final minutes = _timeSinceStart.inMinutes % 60;
    final seconds = _timeSinceStart.inSeconds % 60;

    return Scaffold(
      appBar: const HabittusAppBar(showBack: true),
      backgroundColor: const Color(0xFFF6F8F0),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'add',
            onPressed: _addMotivation,
            backgroundColor: const Color(0xFF2F5D2F),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'relapse',
            onPressed: _registerRelapse,
            backgroundColor: const Color(0xFFE4EAD8),
            icon: const Icon(Icons.refresh, color: Color(0xFF2F5D2F)),
            label: const Text(
              'Registar Vício',
              style: TextStyle(
                color: Color(0xFF2F5D2F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header com data
            Center(
              child: Text(
                '${widget.startDate.day} ${_monthName(widget.startDate.month)} ${widget.startDate.year}    ${TimeOfDay.now().format(context)}',
                style: const TextStyle(color: Colors.black54),
              ),
            ),
            const SizedBox(height: 24),

            // Saudação e contador principal
            Text(
              'Olá, user_name',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                children: [
                  const TextSpan(text: 'Estás livre de '),
                  TextSpan(
                    text: widget.habit.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: ' há:'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Contador grande
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TimeBox(value: days.toString().padLeft(2, '0'), label: 'Dias'),
                const SizedBox(width: 8),
                _TimeBox(
                  value: hours.toString().padLeft(2, '0'),
                  label: 'Horas',
                ),
                const SizedBox(width: 8),
                _TimeBox(
                  value: minutes.toString().padLeft(2, '0'),
                  label: 'Minutos',
                ),
                const SizedBox(width: 8),
                _TimeBox(
                  value: seconds.toString().padLeft(2, '0'),
                  label: 'Segundos',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '${widget.startDate.day} ${_monthName(widget.startDate.month)} ${widget.startDate.year}    ${widget.startDate.hour}:${widget.startDate.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),

            // Conquistas
            HabittusCard(
              title: 'Conquistas atuais...',
              subtitle: null,
              child: Row(
                children: [
                  _AchievementBadge(
                    icon: Icons.hourglass_bottom,
                    label: '24h',
                    achieved: days >= 1,
                  ),
                  const SizedBox(width: 12),
                  _AchievementBadge(
                    icon: Icons.event,
                    label: '3 Dias',
                    achieved: days >= 3,
                  ),
                  const SizedBox(width: 12),
                  _AchievementBadge(
                    icon: Icons.date_range,
                    label: '1 Semana',
                    achieved: days >= 7,
                  ),
                  const SizedBox(width: 12),
                  _AchievementBadge(
                    icon: Icons.calendar_today,
                    label: '1 Mês',
                    achieved: days >= 30,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dinheiro poupado
            HabittusCard(
              title: 'Dinheiro poupado',
              subtitle: null,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Gráfico circular
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: CircularProgressIndicator(
                            value: (moneySaved / 100).clamp(0.0, 1.0),
                            strokeWidth: 12,
                            backgroundColor: const Color(0xFFE4EAD8),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF8B9A7D),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${moneySaved.toStringAsFixed(0)}€',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Text(
                              'poupados',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Informação
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xFFE4EAD8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: const Text('Informação'),
                              content: Text(
                                'Informação com base no cálculo do valor gasto diariamente (${widget.dailyCost.toStringAsFixed(0)}€/dia).',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.info_outline, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Motivações
            HabittusCard(
              title: 'Porque estou a fazer isto',
              subtitle: 'As minhas motivações...',
              child: InkWell(
                onTap: _addMotivation,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F8F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.motivation ?? 'Adicionar motivação...',
                          style: TextStyle(
                            color: widget.motivation != null ? Colors.black87 : Colors.black54,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100), // Espaço para FAB
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}

/// Widget para caixa de tempo
class _TimeBox extends StatelessWidget {
  final String value;
  final String label;

  const _TimeBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4EAD8)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

/// Widget para badge de conquista
class _AchievementBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool achieved;

  const _AchievementBadge({
    required this.icon,
    required this.label,
    required this.achieved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: achieved ? const Color(0xFF2F5D2F) : const Color(0xFFE4EAD8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: achieved ? Colors.white : Colors.black38,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: achieved ? const Color(0xFF2F5D2F) : Colors.black54,
            fontWeight: achieved ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
