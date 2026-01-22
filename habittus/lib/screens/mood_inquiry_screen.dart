import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/mood_controller.dart';
import '../models/mood.dart';
import '../widgets/date_pills.dart';
import '../widgets/habittus_app_bar.dart';
import '../widgets/habittus_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/habittus_drawer.dart';

class MoodInquiryScreen extends StatefulWidget {
  /// ✅ Define se o utilizador é do sexo feminino.
  /// (temporário até existir ProfileController / género vindo do Supabase)
  final bool isFemale;

  const MoodInquiryScreen({super.key, this.isFemale = true});

  @override
  State<MoodInquiryScreen> createState() => _MoodInquiryScreenState();
}

class _MoodInquiryScreenState extends State<MoodInquiryScreen> {
  late DateTime d;
  final ScrollController _scrollCtrl = ScrollController();

  bool _showDetails = false;

  // ====== (antigo mood_inquiry2) estado local ======
  String? sleepQuality; // single
  final Set<String> emotions = {};
  final Set<String> health = {};
  final Set<String> food = {};
  final Set<String> weather = {};
  final TextEditingController notesCtrl = TextEditingController();

  // ====== (NOVO) sexo feminino ======
  bool? tookPillToday; // contraceção
  bool? hadSexToday; // atividade sexual
  bool? usedProtection; // proteção (só faz sentido se hadSexToday == true)

  final Set<String> menstruationSymptoms = {}; // multi
  String? menstrualFlow; // single

  @override
  void initState() {
    super.initState();
    d = _dateOnly(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MoodController>().load(d);
    });
  }

  @override
  void dispose() {
    notesCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  DateTime _dateOnly(DateTime x) => DateTime(x.year, x.month, x.day);

  void _setDate(DateTime newDate) {
    final nd = _dateOnly(newDate);
    setState(() {
      d = nd;
      _showDetails = false;
    });

    context.read<MoodController>().load(nd);

    // limpar detalhes ao mudar de dia
    sleepQuality = null;
    emotions.clear();
    health.clear();
    food.clear();
    weather.clear();
    notesCtrl.clear();

    // limpar feminino
    tookPillToday = null;
    hadSexToday = null;
    usedProtection = null;
    menstruationSymptoms.clear();
    menstrualFlow = null;
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
  ][d.month - 1];

  DateTime _safeMonthShift(DateTime date, int deltaMonths) {
    final targetMonth = DateTime(date.year, date.month + deltaMonths, 1);
    final lastDayOfTargetMonth = DateTime(
      targetMonth.year,
      targetMonth.month + 1,
      0,
    ).day;

    final day = date.day.clamp(1, lastDayOfTargetMonth);
    return DateTime(targetMonth.year, targetMonth.month, day);
  }

  String _timeNow() {
    final t = TimeOfDay.now();
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<void> _goToDetails() async {
    setState(() => _showDetails = true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MoodController>();

    return Scaffold(
      drawer: const HabittusDrawer(userName: 'USER_NAME'),
      appBar: const HabittusAppBar(showBack: true),
      backgroundColor: const Color(0xFFF6F8F0),
      body: SafeArea(
        child: ListView(
          controller: _scrollCtrl,
          padding: const EdgeInsets.all(16),
          children: [
            DatePills(
              day: '${d.day}',
              month: monthName,
              year: '${d.year}',
              onDayPrev: () => _setDate(d.subtract(const Duration(days: 1))),
              onDayNext: () => _setDate(d.add(const Duration(days: 1))),
              onMonthPrev: () => _setDate(_safeMonthShift(d, -1)),
              onMonthNext: () => _setDate(_safeMonthShift(d, 1)),
              onYearPrev: () => _setDate(DateTime(d.year - 1, d.month, d.day)),
              onYearNext: () => _setDate(DateTime(d.year + 1, d.month, d.day)),
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [_SmallPill(text: _timeNow())],
            ),

            const SizedBox(height: 18),

            // ====== PASSO 1 ======
            HabittusCard(
              title: 'Como te sentes hoje?',
              subtitle: 'Seleciona uma opção',
              child: Align(
                alignment: Alignment.center,
                child: _MoodGrid(
                  selected: controller.selected,
                  onSelect: controller.select,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: SizedBox(
                width: 180,
                child: PrimaryButton(
                  text: _showDetails ? 'Detalhes (aberto)' : 'Continuar',
                  onPressed: controller.selected == null
                      ? null
                      : () {
                          if (_showDetails) return;
                          _goToDetails();
                        },
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ====== PASSO 2 (antigo mood_inquiry2) ======
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildDetails(),
              crossFadeState: _showDetails
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionCard(
          icon: Icons.bed_outlined,
          title: 'Qualidade do sono',
          subtitle: 'Como avalias a qualidade do teu sono na última noite?',
          child: _SingleChoiceGrid(
            items: const [
              _Choice(
                id: 'Muito Boa',
                icon: Icons.sentiment_very_satisfied_outlined,
              ),
              _Choice(id: 'Boa', icon: Icons.sentiment_satisfied_outlined),
              _Choice(id: 'OK', icon: Icons.sentiment_neutral_outlined),
              _Choice(id: 'Má', icon: Icons.sentiment_dissatisfied_outlined),
              _Choice(
                id: 'Muito Má',
                icon: Icons.sentiment_very_dissatisfied_outlined,
              ),
            ],
            selectedId: sleepQuality,
            onSelect: (id) => setState(() => sleepQuality = id),
          ),
        ),
        const SizedBox(height: 12),

        _SectionCard(
          icon: Icons.favorite_border,
          title: 'Emoções',
          subtitle: 'Quais destas emoções sentiste ao longo do dia?',
          child: _MultiChoiceGrid(
            items: const [
              _Choice(id: 'Feliz', icon: Icons.sentiment_satisfied_outlined),
              _Choice(id: 'Energia', icon: Icons.bolt_outlined),
              _Choice(id: 'Grato', icon: Icons.favorite_border),
              _Choice(id: 'Cansado', icon: Icons.bed_outlined),
              _Choice(
                id: 'Triste',
                icon: Icons.sentiment_dissatisfied_outlined,
              ),
              _Choice(id: 'Aborrecido', icon: Icons.sentiment_neutral_outlined),
              _Choice(id: 'Ansioso', icon: Icons.psychology_outlined),
              _Choice(id: 'Calmo', icon: Icons.spa_outlined),
            ],
            selected: emotions,
            onToggle: (id) => setState(() {
              if (emotions.contains(id)) {
                emotions.remove(id);
              } else {
                emotions.add(id);
              }
            }),
          ),
        ),
        const SizedBox(height: 12),

        _SectionCard(
          icon: Icons.health_and_safety_outlined,
          title: 'Saúde',
          subtitle: 'O que descreve melhor o teu estado de saúde hoje?',
          child: _MultiChoiceGrid(
            items: const [
              _Choice(id: 'Dores', icon: Icons.healing_outlined),
              _Choice(id: 'Exercício', icon: Icons.fitness_center_outlined),
              _Choice(id: 'Doença', icon: Icons.sick_outlined),
              _Choice(id: 'Relaxado', icon: Icons.self_improvement_outlined),
              _Choice(id: 'Stress', icon: Icons.psychology_alt_outlined),
              _Choice(id: 'Enxaqueca', icon: Icons.bolt_outlined),
              _Choice(
                id: 'Alongamentos',
                icon: Icons.accessibility_new_outlined,
              ),
              _Choice(id: 'Bem', icon: Icons.check_circle_outline),
            ],
            selected: health,
            onToggle: (id) => setState(() {
              if (health.contains(id)) {
                health.remove(id);
              } else {
                health.add(id);
              }
            }),
          ),
        ),

        // =========================
        // ✅ NOVO: Secção feminina
        // =========================
        if (widget.isFemale) ...[
          const SizedBox(height: 12),

          _SectionCard(
            icon: Icons.medication_outlined,
            title: 'Contraceção',
            subtitle: 'Marca se tomaste a pílula hoje.',
            child: _YesNoToggle(
              question: 'Tomaste a pílula hoje?',
              value: tookPillToday,
              onChanged: (v) => setState(() => tookPillToday = v),
            ),
          ),

          const SizedBox(height: 12),

          _SectionCard(
            icon: Icons.favorite_outline,
            title: 'Atividade sexual',
            subtitle: 'Regista se tiveste relações sexuais hoje.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _YesNoToggle(
                  question: 'Tiveste atividade sexual hoje?',
                  value: hadSexToday,
                  onChanged: (v) => setState(() {
                    hadSexToday = v;
                    // se não houve, remove a proteção
                    if (v != true) usedProtection = null;
                  }),
                ),
                const SizedBox(height: 10),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: _YesNoToggle(
                    question: 'Usaste proteção?',
                    value: usedProtection,
                    onChanged: (v) => setState(() => usedProtection = v),
                  ),
                  crossFadeState: hadSexToday == true
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 160),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          _SectionCard(
            icon: Icons.spa_outlined,
            title: 'Sintomas da menstruação',
            subtitle: 'Que alterações sentiste durante a menstruação?',
            child: _MenstruationSymptomsGrid(
              selected: menstruationSymptoms,
              onToggle: (id) => setState(() {
                if (menstruationSymptoms.contains(id)) {
                  menstruationSymptoms.remove(id);
                } else {
                  menstruationSymptoms.add(id);
                }
              }),
            ),
          ),

          const SizedBox(height: 12),

          _SectionCard(
            icon: Icons.water_drop_outlined,
            title: 'Fluxo menstrual',
            subtitle: 'Como classificas o teu fluxo?',
            child: _MenstrualFlowGrid(
              selectedId: menstrualFlow,
              onSelect: (id) => setState(() => menstrualFlow = id),
            ),
          ),
        ],

        const SizedBox(height: 12),

        _SectionCard(
          icon: Icons.restaurant_outlined,
          title: 'Alimentação',
          subtitle: 'Como foi a tua alimentação hoje?',
          child: _MultiChoiceGrid(
            items: const [
              _Choice(id: 'Equilibrada', icon: Icons.balance_outlined),
              _Choice(id: 'Pouca água', icon: Icons.water_drop_outlined),
              _Choice(id: 'Excessos', icon: Icons.fastfood_outlined),
              _Choice(id: 'Saudável', icon: Icons.eco_outlined),
              _Choice(id: 'Doces', icon: Icons.cake_outlined),
              _Choice(id: 'Álcool', icon: Icons.wine_bar_outlined),
              _Choice(id: 'Fruta', icon: Icons.apple_outlined),
              _Choice(id: 'Vegetais', icon: Icons.grass_outlined),
            ],
            selected: food,
            onToggle: (id) => setState(() {
              if (food.contains(id)) {
                food.remove(id);
              } else {
                food.add(id);
              }
            }),
          ),
        ),
        const SizedBox(height: 12),

        _SectionCard(
          icon: Icons.wb_sunny_outlined,
          title: 'Clima',
          subtitle: 'Como estava o tempo onde estiveste durante o dia?',
          child: _MultiChoiceGrid(
            items: const [
              _Choice(id: 'Sol', icon: Icons.wb_sunny_outlined),
              _Choice(id: 'Nublado', icon: Icons.cloud_outlined),
              _Choice(id: 'Chuva', icon: Icons.umbrella_outlined),
              _Choice(id: 'Neve', icon: Icons.ac_unit_outlined),
              _Choice(id: 'Calor', icon: Icons.local_fire_department_outlined),
              _Choice(id: 'Tempest.', icon: Icons.thunderstorm_outlined),
              _Choice(id: 'Vento', icon: Icons.air_outlined),
              _Choice(id: 'Frio', icon: Icons.severe_cold_outlined),
            ],
            selected: weather,
            onToggle: (id) => setState(() {
              if (weather.contains(id)) {
                weather.remove(id);
              } else {
                weather.add(id);
              }
            }),
          ),
        ),
        const SizedBox(height: 12),

        _SectionCard(
          icon: Icons.edit_note_outlined,
          title: 'Notas',
          subtitle: 'Queres registar algum detalhe?',
          child: TextField(
            controller: notesCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Escreve aqui (opcional)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/* ===================== PASSO 1 UI (mood) ===================== */

class _MoodGrid extends StatelessWidget {
  final MoodLevel? selected;
  final ValueChanged<MoodLevel> onSelect;

  const _MoodGrid({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const items = [
      _MoodItem(
        'Péssimo',
        MoodLevel.veryBad,
        Icons.sentiment_very_dissatisfied,
      ),
      _MoodItem('Mau', MoodLevel.bad, Icons.sentiment_dissatisfied),
      _MoodItem('Ok', MoodLevel.neutral, Icons.sentiment_neutral),
      _MoodItem('Bom', MoodLevel.good, Icons.sentiment_satisfied),
      _MoodItem('Ótimo', MoodLevel.veryGood, Icons.sentiment_very_satisfied),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: items.map((it) {
            final isSelected = selected == it.level;

            return ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 120),
              child: OutlinedButton(
                onPressed: () => onSelect(it.level),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                  side: BorderSide(
                    width: 2,
                    color: isSelected
                        ? Colors.green.shade700
                        : Colors.grey.shade400,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(it.icon, color: Colors.black87),
                    const SizedBox(width: 10),
                    Text(
                      it.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.green.shade900
                            : Colors.black87,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green.shade700,
                      ),
                    ] else ...[
                      const SizedBox(width: 22),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _MoodItem {
  final String label;
  final MoodLevel level;
  final IconData icon;
  const _MoodItem(this.label, this.level, this.icon);
}

/* ===================== UI helpers ===================== */

class _SmallPill extends StatelessWidget {
  final String text;
  const _SmallPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFE4EAD8),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF244A24)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        height: 1.25,
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

class _Choice {
  final String id;
  final IconData icon;
  const _Choice({required this.id, required this.icon});
}

class _SingleChoiceGrid extends StatelessWidget {
  final List<_Choice> items;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  const _SingleChoiceGrid({
    required this.items,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: items.map((c) {
        final isSelected = c.id == selectedId;
        return _ChoiceButton(
          icon: c.icon,
          label: c.id,
          selected: isSelected,
          onTap: () => onSelect(c.id),
        );
      }).toList(),
    );
  }
}

class _MultiChoiceGrid extends StatelessWidget {
  final List<_Choice> items;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _MultiChoiceGrid({
    required this.items,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: items.map((c) {
        final isSelected = selected.contains(c.id);
        return _ChoiceButton(
          icon: c.icon,
          label: c.id,
          selected: isSelected,
          onTap: () => onToggle(c.id),
        );
      }).toList(),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 92,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE4EAD8) : const Color(0xFFF6F8F0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? const Color(0xFF7FA57F) : const Color(0xFFD9E1D0),
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF244A24)),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== NOVO: Feminino ===================== */

class _YesNoToggle extends StatelessWidget {
  final String question;
  final bool? value;
  final ValueChanged<bool?> onChanged;

  const _YesNoToggle({
    required this.question,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final yesSelected = value == true;
    final noSelected = value == false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _PillChoice(
                text: 'Sim',
                selected: yesSelected,
                onTap: () => onChanged(true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PillChoice(
                text: 'Não',
                selected: noSelected,
                onTap: () => onChanged(false),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PillChoice extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _PillChoice({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE4EAD8) : const Color(0xFFF6F8F0),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFF7FA57F) : const Color(0xFFD9E1D0),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _MenstruationSymptomsGrid extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _MenstruationSymptomsGrid({
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      _Choice(id: 'Dor lombar', icon: Icons.back_hand_outlined),
      _Choice(id: 'Barriga inchada', icon: Icons.bubble_chart_outlined),
      _Choice(id: 'Aumento do apetite', icon: Icons.restaurant_outlined),
      _Choice(id: 'Dor de cabeça', icon: Icons.psychology_outlined),
      _Choice(id: 'Tonturas', icon: Icons.sync_alt_outlined),
      _Choice(id: 'Enjoos', icon: Icons.sick_outlined),
      _Choice(id: 'Borbulhas', icon: Icons.blur_on_outlined),
      _Choice(id: 'Cólicas', icon: Icons.airline_seat_recline_normal_outlined),
      _Choice(id: 'Seios sensíveis', icon: Icons.favorite_border),
      _Choice(id: 'Sangramento', icon: Icons.water_drop_outlined),
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: items.map((c) {
        final isSelected = selected.contains(c.id);
        return _RoundIconChoice(
          label: c.id,
          icon: c.icon,
          selected: isSelected,
          onTap: () => onToggle(c.id),
        );
      }).toList(),
    );
  }
}

class _MenstrualFlowGrid extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<String> onSelect;

  const _MenstrualFlowGrid({required this.selectedId, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const items = [
      _Choice(id: 'Spots', icon: Icons.water_drop_outlined),
      _Choice(id: 'Muito leve', icon: Icons.water_drop_outlined),
      _Choice(id: 'Leve', icon: Icons.water_drop_outlined),
      _Choice(id: 'Moderado', icon: Icons.water_drop_outlined),
      _Choice(id: 'Intenso', icon: Icons.water_drop_outlined),
      _Choice(id: 'Muito intenso', icon: Icons.water_drop_outlined),
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: items.map((c) {
        final isSelected = selectedId == c.id;
        return _RoundIconChoice(
          label: c.id,
          icon: c.icon,
          selected: isSelected,
          onTap: () => onSelect(c.id),
        );
      }).toList(),
    );
  }
}

class _RoundIconChoice extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoundIconChoice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 96,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE4EAD8) : const Color(0xFFF6F8F0),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFF7FA57F) : const Color(0xFFD9E1D0),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFE4EAD8),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF244A24), size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
