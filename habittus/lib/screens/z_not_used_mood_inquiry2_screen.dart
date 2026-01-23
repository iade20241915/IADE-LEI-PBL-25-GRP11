import 'package:flutter/material.dart';

import '../widgets/habittus_app_bar.dart';
import '../widgets/habittus_drawer.dart';
import '../widgets/date_pills.dart';

class MoodInquiry2Screen extends StatefulWidget {
  const MoodInquiry2Screen({super.key});

  @override
  State<MoodInquiry2Screen> createState() => _MoodInquiry2ScreenState();
}

class _MoodInquiry2ScreenState extends State<MoodInquiry2Screen> {
  DateTime d = DateTime(2025, 9, 25);

  String? sleepQuality; // single
  final Set<String> emotions = {};
  final Set<String> health = {};
  final Set<String> food = {};
  final Set<String> weather = {};

  final TextEditingController notesCtrl = TextEditingController();

  String _monthName(int m) => const [
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
  ][m - 1];

  String _timeNow() {
    final t = TimeOfDay.now();
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  void _dayPrev() => setState(() => d = d.subtract(const Duration(days: 1)));
  void _dayNext() => setState(() => d = d.add(const Duration(days: 1)));

  void _monthPrev() => setState(() => d = DateTime(d.year, d.month - 1, d.day));
  void _monthNext() => setState(() => d = DateTime(d.year, d.month + 1, d.day));

  void _yearPrev() => setState(() => d = DateTime(d.year - 1, d.month, d.day));
  void _yearNext() => setState(() => d = DateTime(d.year + 1, d.month, d.day));

  @override
  void dispose() {
    notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HabittusDrawer(userName: 'USER_NAME'),
      appBar: const HabittusAppBar(),
      backgroundColor: const Color(0xFFF6F8F0),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Row(
            children: [
              Expanded(
                child: DatePills(
                  day: '${d.day}',
                  month: _monthName(d.month),
                  year: '${d.year}',
                  onDayPrev: _dayPrev,
                  onDayNext: _dayNext,
                  onMonthPrev: _monthPrev,
                  onMonthNext: _monthNext,
                  onYearPrev: _yearPrev,
                  onYearNext: _yearNext,
                ),
              ),
              const SizedBox(width: 10),
              _SmallPill(text: _timeNow()),
            ],
          ),
          const SizedBox(height: 12),

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
                _Choice(id: 'Razoável', icon: Icons.sentiment_neutral_outlined),
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
                _Choice(
                  id: 'Aborrecido',
                  icon: Icons.sentiment_neutral_outlined,
                ),
                _Choice(id: 'Ansioso', icon: Icons.psychology_outlined),
                _Choice(id: 'Calmo', icon: Icons.spa_outlined),
                _Choice(id: 'Irritado', icon: Icons.mood_bad_outlined),
                _Choice(id: 'Motivado', icon: Icons.rocket_launch_outlined),
              ],
              selected: emotions,
              onToggle: (id) => setState(() {
                emotions.contains(id) ? emotions.remove(id) : emotions.add(id);
              }),
            ),
          ),

          const SizedBox(height: 12),

          _SectionCard(
            icon: Icons.health_and_safety_outlined,
            title: 'Saúde',
            subtitle: 'Como te sentiste fisicamente hoje?',
            child: _MultiChoiceGrid(
              items: const [
                _Choice(id: 'Exercício', icon: Icons.fitness_center),
                _Choice(id: 'Saudável', icon: Icons.eco_outlined),
                _Choice(id: 'Água', icon: Icons.water_drop_outlined),
                _Choice(id: 'Caminhar', icon: Icons.directions_walk_outlined),
                _Choice(id: 'Desporto', icon: Icons.sports_soccer_outlined),
                _Choice(id: 'Dormir', icon: Icons.bed_outlined),
                _Choice(id: 'Dor', icon: Icons.healing_outlined),
                _Choice(id: 'Medicação', icon: Icons.medication_outlined),
                _Choice(id: 'Stress', icon: Icons.warning_amber_outlined),
                _Choice(id: 'Relaxar', icon: Icons.self_improvement_outlined),
              ],
              selected: health,
              onToggle: (id) => setState(() {
                health.contains(id) ? health.remove(id) : health.add(id);
              }),
            ),
          ),

          const SizedBox(height: 12),

          _SectionCard(
            icon: Icons.restaurant_outlined,
            title: 'Alimentação',
            subtitle: 'Como caracterizas a tua alimentação de hoje?',
            child: _MultiChoiceGrid(
              items: const [
                _Choice(id: 'Fast Food', icon: Icons.fastfood_outlined),
                _Choice(id: 'Caseira', icon: Icons.home_outlined),
                _Choice(id: 'Restaurante', icon: Icons.storefront_outlined),
                _Choice(id: 'Take-Away', icon: Icons.shopping_bag_outlined),
                _Choice(
                  id: 'Sem Doces',
                  icon: Icons.emoji_food_beverage_outlined,
                ),
                _Choice(id: 'Sem Refrig.', icon: Icons.no_drinks_outlined),
                _Choice(id: 'Vegan', icon: Icons.spa_outlined),
                _Choice(id: 'Sem Álcool', icon: Icons.no_drinks_outlined),
                _Choice(id: 'Comi de mais', icon: Icons.add_circle_outline),
                _Choice(id: 'Comi pouco', icon: Icons.remove_circle_outline),
              ],
              selected: food,
              onToggle: (id) => setState(() {
                food.contains(id) ? food.remove(id) : food.add(id);
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
                _Choice(
                  id: 'Calor',
                  icon: Icons.local_fire_department_outlined,
                ),
                _Choice(id: 'Tempest.', icon: Icons.thunderstorm_outlined),
                _Choice(id: 'Vento', icon: Icons.air_outlined),
                _Choice(id: 'Frio', icon: Icons.severe_cold_outlined),
                _Choice(id: 'Húmido', icon: Icons.water_outlined),
                _Choice(id: 'Seco', icon: Icons.waves_outlined),
              ],
              selected: weather,
              onToggle: (id) => setState(() {
                weather.contains(id) ? weather.remove(id) : weather.add(id);
              }),
            ),
          ),

          const SizedBox(height: 12),

          _NotesCard(
            controller: notesCtrl,
            onClear: () => setState(() => notesCtrl.clear()),
            onSave: () {
              // TODO: persistir depois (UML -> Repo -> Supabase)
            },
          ),

          const SizedBox(height: 12),

          _ActionRowCard(
            title: 'Anexar foto',
            subtitle: 'Adiciona uma foto ao teu registo.',
            leftIcon: Icons.camera_alt_outlined,
            rightIcon: Icons.image_outlined,
            onLeft: () {},
            onRight: () {},
          ),

          const SizedBox(height: 10),

          _ActionRowCard(
            title: 'Nota de voz',
            subtitle: 'Grava um pensamento rapidamente.',
            leftIcon: Icons.mic_none,
            rightIcon: Icons.radio_button_checked,
            onLeft: () {},
            onRight: () {},
          ),

          const SizedBox(height: 18),

          Center(
            child: SizedBox(
              height: 44,
              width: 160,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDDECCF),
                  foregroundColor: const Color(0xFF244A24),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pop(); // por agora volta (ajustas depois)
                },
                child: const Text(
                  'Continuar',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

/* ===================== UI ===================== */

class _SmallPill extends StatelessWidget {
  final String text;
  const _SmallPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6E6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBFCDB2), width: 0.6),
      ),
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6DDC9), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF244A24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;
  final VoidCallback onSave;

  const _NotesCard({
    required this.controller,
    required this.onClear,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5EA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6DDC9), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFFDDECCF),
                child: Text(
                  'A',
                  style: TextStyle(
                    color: Color(0xFF244A24),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Text('Notas', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Adiciona notas sobre o teu dia.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBFCDB2), width: 0.6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notas livres',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: controller,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Placeholder',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton(onPressed: onClear, child: const Text('Clear')),
              const Spacer(),
              TextButton(onPressed: onSave, child: const Text('Gravar')),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionRowCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData leftIcon;
  final IconData rightIcon;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  const _ActionRowCard({
    required this.title,
    required this.subtitle,
    required this.leftIcon,
    required this.rightIcon,
    required this.onLeft,
    required this.onRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6DDC9), width: 0.8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _CircleIconButton(icon: leftIcon, onTap: onLeft),
          const SizedBox(width: 10),
          _CircleIconButton(icon: rightIcon, onTap: onRight),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFDDECCF),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, color: const Color(0xFF244A24)),
        ),
      ),
    );
  }
}

/* ===================== CHOICE GRIDS ===================== */

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
      spacing: 14,
      runSpacing: 14,
      children: items.map((c) {
        final selected = c.id == selectedId;
        return _ChoiceButton(
          icon: c.icon,
          label: c.id,
          selected: selected,
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
      spacing: 14,
      runSpacing: 14,
      children: items.map((c) {
        final isOn = selected.contains(c.id);
        return _ChoiceButton(
          icon: c.icon,
          label: c.id,
          selected: isOn,
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
    final bg = selected ? const Color(0xFF2F5B2F) : const Color(0xFFDDECCF);
    final fg = selected ? Colors.white : const Color(0xFF244A24);

    return SizedBox(
      width: 68,
      child: Column(
        children: [
          Material(
            color: bg,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(icon, color: fg),
              ),
            ),
          ),
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
    );
  }
}
