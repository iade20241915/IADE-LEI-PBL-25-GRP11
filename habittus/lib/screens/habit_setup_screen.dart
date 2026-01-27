import 'package:flutter/material.dart';
import '../core/database/supabase_service.dart';
import '../models/habit.dart';
import '../widgets/habittus_app_bar.dart';
import '../widgets/primary_button.dart';

class HabitSetupScreen extends StatefulWidget {
  final HabitType type;

  const HabitSetupScreen({super.key, required this.type});

  @override
  State<HabitSetupScreen> createState() => _HabitSetupScreenState();
}

class _HabitSetupScreenState extends State<HabitSetupScreen> {
  // Controladores
  final habitNameController = TextEditingController();
  final motivationController = TextEditingController();

  // Estado
  HabitCategory? selectedCategory;
  DateTime? startDate;
  HabitMood? initialMood;
  int daysPerWeek = 3;
  int timesPerDay = 15;
  double dailyCost = 5.0;
  List<String> selectedGoals = [];
  String? nextMilestone;

  final goals = [
    {'id': 'health', 'label': 'Saúde Mental', 'icon': Icons.psychology},
    {'id': 'energy', 'label': 'Mais energia', 'icon': Icons.bolt},
    {'id': 'control', 'label': 'Mais controlo', 'icon': Icons.tune},
    {'id': 'relations', 'label': 'Relações', 'icon': Icons.people},
    {'id': 'anxiety', 'label': 'Ansiedade', 'icon': Icons.sentiment_neutral},
    {'id': 'sleep', 'label': 'Sono', 'icon': Icons.bedtime},
  ];

  final milestones = [
    {'id': '24h', 'label': '24h', 'icon': Icons.hourglass_bottom},
    {'id': '3days', 'label': '3 Dias', 'icon': Icons.event},
    {'id': '1week', 'label': '1 Semana', 'icon': Icons.date_range},
    {'id': '1month', 'label': '1 Mês', 'icon': Icons.calendar_today},
    {'id': '3months', 'label': '3 Meses', 'icon': Icons.emoji_events},
  ];

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2F5D2F)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => startDate = picked);
    }
  }

  void _submit() {
    if (selectedCategory == null) {
      _showError('Por favor, selecione um hábito');
      return;
    }
    if (startDate == null) {
      _showError('Por favor, indique quando começou');
      return;
    }

    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: SupabaseService.instance.currentUserId?.toString() ?? '',
      name: habitNameController.text.isEmpty
          ? selectedCategory!.label
          : habitNameController.text,
      type: widget.type,
      category: selectedCategory!,
      description: motivationController.text.isEmpty
          ? null
          : motivationController.text,
      emoji: selectedCategory!.emoji,
      createdAt: DateTime.now(),
    );

    // Retorna o hábito com dados extras
    Navigator.pop(context, {
      'habit': habit,
      'startDate': startDate,
      'initialMood': initialMood,
      'daysPerWeek': daysPerWeek,
      'timesPerDay': timesPerDay,
      'dailyCost': dailyCost,
      'goals': selectedGoals,
      'nextMilestone': nextMilestone,
      'motivation': motivationController.text,
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    habitNameController.dispose();
    motivationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HabittusAppBar(showBack: true),
      backgroundColor: const Color(0xFFF6F8F0),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header com data/hora
            Center(
              child: Text(
                '${DateTime.now().day} ${_monthName(DateTime.now().month)} ${DateTime.now().year}    ${TimeOfDay.now().format(context)}',
                style: const TextStyle(color: Colors.black54),
              ),
            ),
            const SizedBox(height: 24),

            // 1. Seleção do hábito
            _SectionCard(
              icon: Icons.playlist_remove,
              title: 'O que queres deixar?',
              subtitle: 'Escolhe o hábito que queres trabalhar.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo de texto para busca/nome personalizado
                  TextField(
                    controller: habitNameController,
                    decoration: InputDecoration(
                      hintText: 'Lista de hábitos...',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            habitNameController.clear();
                            selectedCategory = null;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Categorias de vícios
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: HabitCategory.values
                        .where((c) => c.isNegative)
                        .map((cat) {
                          final isSelected = selectedCategory == cat;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedCategory = cat;
                                habitNameController.text =
                                    cat.label; // Preenche automaticamente
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF2F5D2F)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF2F5D2F)
                                      : Colors.black12,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(cat.emoji),
                                  const SizedBox(width: 6),
                                  Text(
                                    cat.label,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        })
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Data de início
            _SectionCard(
              icon: Icons.calendar_today,
              title: 'Quando começaste a mudar?',
              subtitle: 'Indica a data em que deixaste este hábito.',
              child: InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B9A7D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        startDate != null
                            ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                            : 'mm/dd/yyyy',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Estado emocional inicial
            _SectionCard(
              icon: Icons.emoji_emotions,
              title: 'Como te sentias nesse dia?',
              subtitle: null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: HabitMood.values.map((mood) {
                  final isSelected = initialMood == mood;
                  return InkWell(
                    onTap: () => setState(() => initialMood = mood),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2F5D2F)
                                : const Color(0xFFE4EAD8),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              mood.emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mood.label,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? const Color(0xFF2F5D2F)
                                : Colors.black54,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 4. Frequência semanal
            _SectionCard(
              icon: Icons.calendar_view_week,
              title: 'Quantos dias por semana fazias este hábito?',
              subtitle: 'Indica a frequência semanal.',
              child: Column(
                children: [
                  _FrequencySelector(
                    value: daysPerWeek,
                    min: 1,
                    max: 7,
                    onChanged: (v) => setState(() => daysPerWeek = v),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$daysPerWeek Dias',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. Frequência diária
            _SectionCard(
              icon: Icons.repeat,
              title: 'Nos dias que o fazias, quantas vezes por dia?',
              subtitle: 'Indica a frequência diária.',
              child: Column(
                children: [
                  _FrequencySelector(
                    value: timesPerDay,
                    min: 1,
                    max: 30,
                    onChanged: (v) => setState(() => timesPerDay = v),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$timesPerDay Vezes/dia',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 6. Custo diário
            _SectionCard(
              icon: Icons.euro,
              title: 'Quanto gastas diariamente?',
              subtitle: 'Indica o valor diário gasto.',
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF8B9A7D),
                      inactiveTrackColor: const Color(0xFFE4EAD8),
                      thumbColor: const Color(0xFF2F5D2F),
                      overlayColor: const Color(0xFF2F5D2F).withOpacity(0.2),
                    ),
                    child: Slider(
                      value: dailyCost,
                      min: 0,
                      max: 50,
                      divisions: 50,
                      onChanged: (v) => setState(() => dailyCost = v),
                    ),
                  ),
                  Text(
                    '${dailyCost.toStringAsFixed(0)}€',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 7. Objetivos de melhoria
            _SectionCard(
              icon: Icons.flag,
              title: 'O que gostarias de melhorar na tua vida?',
              subtitle: null,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: goals.map((goal) {
                  final isSelected = selectedGoals.contains(goal['id']);
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedGoals.remove(goal['id']);
                        } else {
                          selectedGoals.add(goal['id'] as String);
                        }
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2F5D2F)
                                : const Color(0xFFE4EAD8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            goal['icon'] as IconData,
                            color: isSelected ? Colors.white : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 60,
                          child: Text(
                            goal['label'] as String,
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 8. Próximo marco
            _SectionCard(
              icon: Icons.emoji_events,
              title: 'Qual é o teu próximo marco?',
              subtitle: null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: milestones.map((m) {
                  final isSelected = nextMilestone == m['id'];
                  return InkWell(
                    onTap: () =>
                        setState(() => nextMilestone = m['id'] as String),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2F5D2F)
                                : const Color(0xFFE4EAD8),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            m['icon'] as IconData,
                            color: isSelected ? Colors.white : Colors.black54,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 9. Motivação
            _SectionCard(
              icon: Icons.lightbulb_outline,
              title: 'Recorda-te porque estás a fazer isto...',
              subtitle: 'Escreve a tua motivação aqui.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF8B9A7D)),
                    ),
                    child: TextField(
                      controller: motivationController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Placeholder',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                        label: Text('Notas livres'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => motivationController.clear(),
                        child: const Text(
                          'Clear',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Gravar',
                          style: TextStyle(color: Color(0xFF2F5D2F)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botão submeter
            Center(
              child: PrimaryButton(text: 'Submeter', onPressed: _submit),
            ),
            const SizedBox(height: 32),
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

/// Card de seção com ícone
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE4EAD8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF244A24)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Seletor de frequência com botões - e +
class _FrequencySelector extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final Function(int) onChanged;

  const _FrequencySelector({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botão -
        InkWell(
          onTap: value > min ? () => onChanged(value - 1) : null,
          child: Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF8B9A7D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5,
                (i) => Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.white54,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Botão +
        InkWell(
          onTap: value < max ? () => onChanged(value + 1) : null,
          child: Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFD5DBC8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5,
                (i) => Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
