import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/habit_controller.dart';
import '../core/database/supabase_service.dart';
import '../models/habit.dart';
import '../widgets/habittus_app_bar.dart';
import '../widgets/habittus_card.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  String get userId => SupabaseService.instance.currentUserId?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitController>().loadHabitLogs(widget.habit.id);
    });
  }

  Future<void> _addLog() async {
    final quantityController = TextEditingController();
    final notesController = TextEditingController();
    HabitMood? selectedMood;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Registar Ocorrência'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade (opcional)',
                    hintText: 'Ex: 3 cigarros, 120 minutos',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notas (opcional)',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Como te sentes?'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: HabitMood.values.map((mood) {
                    return ChoiceChip(
                      label: Text(mood.emoji),
                      selected: selectedMood == mood,
                      onSelected: (selected) {
                        setDialogState(() => selectedMood = selected ? mood : null);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'quantity': quantityController.text.isEmpty
                      ? null
                      : int.tryParse(quantityController.text),
                  'notes': notesController.text.isEmpty ? null : notesController.text,
                  'mood': selectedMood,
                });
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      final log = HabitLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        habitId: widget.habit.id,
        userId: userId,
        timestamp: DateTime.now(),
        quantity: result['quantity'],
        notes: result['notes'],
        mood: result['mood'],
      );

      await context.read<HabitController>().addHabitLog(log);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocorrência registada!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HabittusAppBar(showBack: true),
      backgroundColor: const Color(0xFFF6F8F0),
      floatingActionButton: FloatingActionButton(
        onPressed: _addLog,
        backgroundColor: const Color(0xFF2F5D2F),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Consumer<HabitController>(
          builder: (context, controller, child) {
            final logs = controller.currentLogs;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: widget.habit.type == HabitType.negative
                            ? Colors.orange.shade100
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          widget.habit.emoji ?? widget.habit.category.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.habit.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (widget.habit.description != null)
                            Text(
                              widget.habit.description!,
                              style: const TextStyle(color: Colors.black54),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Stats
                HabittusCard(
                  title: 'Estatísticas',
                  subtitle: 'Últimos 30 dias',
                  child: Column(
                    children: [
                      _StatRow(
                        icon: Icons.event,
                        label: 'Ocorrências',
                        value: logs.length.toString(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Logs
                HabittusCard(
                  title: 'Histórico',
                  subtitle: '${logs.length} registo${logs.length != 1 ? 's' : ''}',
                  child: logs.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text('Nenhum registo ainda'),
                          ),
                        )
                      : Column(
                          children: logs.map((log) {
                            return _LogTile(
                              log: log,
                              onDelete: () async {
                                await controller.deleteHabitLog(log.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Registo removido!')),
                                );
                              },
                            );
                          }).toList(),
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

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF244A24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final HabitLog log;
  final VoidCallback onDelete;

  const _LogTile({required this.log, required this.onDelete});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hoje, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Ontem';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (log.mood != null)
            Text(log.mood!.emoji, style: const TextStyle(fontSize: 24)),
          if (log.mood != null) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(log.timestamp),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (log.quantity != null)
                  Text('Quantidade: ${log.quantity}'),
                if (log.notes != null)
                  Text(
                    log.notes!,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
