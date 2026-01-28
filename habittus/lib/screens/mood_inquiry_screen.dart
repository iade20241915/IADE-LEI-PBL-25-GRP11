import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/mood_controller.dart';
import '../models/mood.dart';
import '../models/cycle_entry.dart';
import '../widgets/date_pills.dart';
import '../widgets/habittus_app_bar.dart';
import '../widgets/habittus_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/habittus_drawer.dart';
import '../widgets/habittus_icons.dart';

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

  // ====== Estado local do formulário ======
  String? sleepQuality;
  final Set<String> emotions = {};
  final Set<String> health = {};
  final Set<String> food = {};
  final Set<String> weather = {};
  final TextEditingController notesCtrl = TextEditingController();

  // ====== Dados femininos ======
  bool? tookPillToday;
  bool? hadSexToday;
  bool? usedProtection;
  final Set<String> menstruationSymptoms = {};
  String? menstrualFlow;

  @override
  void initState() {
    super.initState();
    d = _dateOnly(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadData();
    });
  }

  @override
  void dispose() {
    notesCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  DateTime _dateOnly(DateTime x) => DateTime(x.year, x.month, x.day);

  Future<void> _loadData() async {
    final controller = context.read<MoodController>();
    await controller.load(d);

    // Sincronizar estado local com controller (para edição)
    if (mounted) {
      setState(() {
        // ====== Dados de Mood ======
        sleepQuality = controller.sleepQuality;
        emotions.clear();
        emotions.addAll(controller.emotions);
        health.clear();
        health.addAll(controller.health);
        food.clear();
        food.addAll(controller.food);
        weather.clear();
        weather.addAll(controller.weather);
        notesCtrl.text = controller.notes ?? '';

        // ====== Dados de Ciclo (só se feminino) ======
        if (widget.isFemale) {
          tookPillToday = controller.tookPill ? true : null;
          hadSexToday = controller.hadSex ? true : null;
          usedProtection = controller.usedProtection ? true : null;

          // Carregar fluxo menstrual
          if (controller.menstrualFlow != null) {
            menstrualFlow = controller.menstrualFlow!.label;
          } else {
            menstrualFlow = null;
          }

          // Carregar sintomas
          menstruationSymptoms.clear();
          for (final symptom in controller.symptoms) {
            menstruationSymptoms.add(symptom.label);
          }
        }
      });
    }
  }

  void _setDate(DateTime newDate) {
    final nd = _dateOnly(newDate);
    setState(() {
      d = nd;
      // Limpar estado local
      sleepQuality = null;
      emotions.clear();
      health.clear();
      food.clear();
      weather.clear();
      notesCtrl.clear();
      tookPillToday = null;
      hadSexToday = null;
      usedProtection = null;
      menstruationSymptoms.clear();
      menstrualFlow = null;
    });

    _loadData();
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

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MoodController>();

    return Scaffold(
      drawer: const HabittusDrawer(),
      appBar: const HabittusAppBar(showBack: true),
      backgroundColor: const Color(0xFFF6F8F0),
      body: SafeArea(
        child: controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(16),
                children: [
                  DatePills(
                    day: '${d.day}',
                    month: monthName,
                    year: '${d.year}',
                    onDayPrev: () =>
                        _setDate(d.subtract(const Duration(days: 1))),
                    onDayNext: () => _setDate(d.add(const Duration(days: 1))),
                    onMonthPrev: () => _setDate(_safeMonthShift(d, -1)),
                    onMonthNext: () => _setDate(_safeMonthShift(d, 1)),
                    onYearPrev: () =>
                        _setDate(DateTime(d.year - 1, d.month, d.day)),
                    onYearNext: () =>
                        _setDate(DateTime(d.year + 1, d.month, d.day)),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [_SmallPill(text: _timeNow())],
                  ),

                  const SizedBox(height: 18),

                  // ====== HUMOR ======
                  HabittusCard(
                    title: 'Como te sentes hoje?',
                    subtitle: 'Seleciona uma opção',
                    child: Align(
                      alignment: Alignment.center,
                      child: _MoodGrid(
                        selected: controller.selectedLevel,
                        onSelect: controller.select,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ====== DETALHES (sempre visíveis) ======
                  _buildDetails(),

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
          icon: HabittusIcons.bed,
          iconColor: HabittusIcons.sleepColor,
          title: 'Qualidade do sono',
          subtitle: 'Como avalias a qualidade do teu sono na última noite?',
          child: _SingleChoiceGrid(
            items: const [
              _Choice(id: 'Muito Boa', icon: HabittusIcons.moodVeryGood),
              _Choice(id: 'Boa', icon: HabittusIcons.moodGood),
              _Choice(id: 'OK', icon: HabittusIcons.moodNeutral),
              _Choice(id: 'Má', icon: HabittusIcons.moodBad),
              _Choice(id: 'Muito Má', icon: HabittusIcons.moodVeryBad),
            ],
            selectedId: sleepQuality,
            onSelect: (id) => setState(() => sleepQuality = id),
          ),
        ),
        const SizedBox(height: 12),

        _SectionCard(
          icon: HabittusIcons.heart,
          iconColor: HabittusIcons.moodColor,
          title: 'Emoções',
          subtitle: 'Quais destas emoções sentiste ao longo do dia?',
          child: _MultiChoiceGrid(
            items: const [
              _Choice(id: 'Feliz', icon: HabittusIcons.moodGood),
              _Choice(id: 'Energia', icon: HabittusIcons.calories),
              _Choice(id: 'Grato', icon: HabittusIcons.heart),
              _Choice(id: 'Cansado', icon: HabittusIcons.bed),
              _Choice(id: 'Triste', icon: HabittusIcons.moodBad),
              _Choice(id: 'Aborrecido', icon: HabittusIcons.moodNeutral),
              _Choice(id: 'Ansioso', icon: HabittusIcons.psychology),
              _Choice(id: 'Calmo', icon: HabittusIcons.spa),
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
          icon: HabittusIcons.health,
          iconColor: HabittusIcons.activityColor,
          title: 'Saúde',
          subtitle: 'O que descreve melhor o teu estado de saúde hoje?',
          child: _MultiChoiceGrid(
            items: const [
              _Choice(id: 'Dores', icon: HabittusIcons.pain),
              _Choice(id: 'Exercício', icon: HabittusIcons.activity),
              _Choice(id: 'Doença', icon: HabittusIcons.sick),
              _Choice(id: 'Relaxado', icon: HabittusIcons.calm),
              _Choice(id: 'Stress', icon: HabittusIcons.stress),
              _Choice(id: 'Enxaqueca', icon: HabittusIcons.calories),
              _Choice(id: 'Alongamentos', icon: HabittusIcons.activity),
              _Choice(id: 'Bem', icon: HabittusIcons.check),
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
            icon: HabittusIcons.medication,
            iconColor: HabittusIcons.cycleColor,
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
            icon: HabittusIcons.heart,
            iconColor: HabittusIcons.cycleColor,
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
            icon: HabittusIcons.spa,
            iconColor: HabittusIcons.cycleColor,
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
            icon: HabittusIcons.water,
            iconColor: HabittusIcons.cycleColor,
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
          icon: HabittusIcons.meal,
          iconColor: HabittusIcons.foodColor,
          title: 'Alimentação',
          subtitle: 'Como foi a tua alimentação hoje?',
          child: _MultiChoiceGrid(
            items: const [
              _Choice(id: 'Equilibrada', icon: HabittusIcons.health),
              _Choice(id: 'Pouca água', icon: HabittusIcons.water),
              _Choice(id: 'Excessos', icon: HabittusIcons.food),
              _Choice(id: 'Saudável', icon: HabittusIcons.vegetable),
              _Choice(id: 'Doces', icon: HabittusIcons.cake),
              _Choice(id: 'Álcool', icon: HabittusIcons.alcohol),
              _Choice(id: 'Fruta', icon: HabittusIcons.fruit),
              _Choice(id: 'Vegetais', icon: HabittusIcons.vegetable),
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
          icon: HabittusIcons.sunny,
          iconColor: const Color(0xFFFF9800),
          title: 'Clima',
          subtitle: 'Como estava o tempo onde estiveste durante o dia?',
          child: _MultiChoiceGrid(
            items: const [
              _Choice(id: 'Sol', icon: HabittusIcons.sunny),
              _Choice(id: 'Nublado', icon: HabittusIcons.cloudy),
              _Choice(id: 'Chuva', icon: HabittusIcons.rainy),
              _Choice(id: 'Neve', icon: HabittusIcons.snowy),
              _Choice(id: 'Calor', icon: HabittusIcons.hot),
              _Choice(id: 'Tempest.', icon: HabittusIcons.storm),
              _Choice(id: 'Vento', icon: HabittusIcons.windy),
              _Choice(id: 'Frio', icon: HabittusIcons.cold),
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
          icon: HabittusIcons.notes,
          iconColor: const Color(0xFF607D8B),
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

        // Botão Gravar
        const SizedBox(height: 24),
        Center(
          child: SizedBox(
            width: 200,
            child: PrimaryButton(
              text: 'Gravar',
              onPressed: _canSave() ? _saveData : null,
            ),
          ),
        ),
      ],
    );
  }

  /// Verifica se pode gravar (pelo menos humor selecionado)
  bool _canSave() {
    final controller = context.read<MoodController>();
    return controller.selectedLevel != null;
  }

  /// Grava os dados do humor na base de dados
  Future<void> _saveData() async {
    final controller = context.read<MoodController>();

    // Limpar dados antigos do controller e definir novos
    controller.clearAllData();

    // Definir qualidade do sono
    controller.setSleepQuality(sleepQuality);

    // Definir notas
    controller.setNotes(notesCtrl.text.isNotEmpty ? notesCtrl.text : null);

    // Definir emoções
    for (final emotion in emotions) {
      controller.toggleEmotion(emotion);
    }

    // Definir saúde
    for (final item in health) {
      controller.toggleHealth(item);
    }

    // Definir comida
    for (final item in food) {
      controller.toggleFood(item);
    }

    // Definir tempo/clima
    for (final item in weather) {
      controller.toggleWeather(item);
    }

    // Definir dados femininos
    controller.setTookPill(tookPillToday == true);
    controller.setHadSex(hadSexToday == true);
    controller.setUsedProtection(usedProtection == true);

    // Definir fluxo menstrual
    if (menstrualFlow != null) {
      controller.setMenstrualFlowFromString(menstrualFlow!);
    }

    // Definir sintomas
    for (final symptom in menstruationSymptoms) {
      controller.toggleSymptomFromString(symptom);
    }

    print('[MOOD SCREEN] Dados a gravar:');
    print('  - Nível: ${controller.selectedLevel}');
    print('  - Sono: $sleepQuality');
    print('  - Emoções: $emotions');
    print('  - Saúde: $health');
    print('  - Comida: $food');
    print('  - Tempo: $weather');
    print('  - Notas: ${notesCtrl.text}');
    print('  - isFemale: ${widget.isFemale}');
    print('  - Fluxo menstrual (UI): $menstrualFlow');
    print('  - Sintomas menstruação (UI): $menstruationSymptoms');
    print('  - Tomou pílula: $tookPillToday');
    print('  - Atividade sexual: $hadSexToday');

    // Chamar save() do controller para gravar na BD
    await controller.save();

    // Mostrar feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                controller.saveStatus == MoodSaveStatus.saved
                    ? HabittusIcons.check
                    : Icons.error,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.saveStatus == MoodSaveStatus.saved
                      ? 'Humor do dia ${d.day}/${d.month} gravado com sucesso!'
                      : 'Erro ao gravar: ${controller.errorMessage}',
                ),
              ),
            ],
          ),
          backgroundColor: controller.saveStatus == MoodSaveStatus.saved
              ? const Color(0xFF2F5D2F)
              : Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
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
      _MoodItem('Péssimo', MoodLevel.veryBad, HabittusIcons.moodVeryBad),
      _MoodItem('Mau', MoodLevel.bad, HabittusIcons.moodBad),
      _MoodItem('Ok', MoodLevel.neutral, HabittusIcons.moodNeutral),
      _MoodItem('Bom', MoodLevel.good, HabittusIcons.moodGood),
      _MoodItem('Ótimo', MoodLevel.veryGood, HabittusIcons.moodVeryGood),
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
                        HabittusIcons.check,
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
  final Color? iconColor;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? HabittusIcons.primaryColor;
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
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
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 96,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE4EAD8) : const Color(0xFFF6F8F0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? HabittusIcons.primaryColor
                : const Color(0xFFD9E1D0),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? HabittusIcons.primaryColor.withOpacity(0.2)
                    : const Color(0xFFE4EAD8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected
                    ? HabittusIcons.primaryColor
                    : const Color(0xFF244A24),
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? HabittusIcons.primaryColor : Colors.black87,
              ),
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
    // Usar os mesmos labels do enum CycleSymptom
    const items = [
      _Choice(id: 'Cólicas', icon: HabittusIcons.cramps),
      _Choice(id: 'Dor de cabeça', icon: HabittusIcons.psychology),
      _Choice(id: 'Inchaço', icon: HabittusIcons.bloating),
      _Choice(id: 'Seios sensíveis', icon: HabittusIcons.heart),
      _Choice(id: 'Acne', icon: HabittusIcons.headache),
      _Choice(id: 'Fadiga', icon: HabittusIcons.sick),
      _Choice(id: 'Humor instável', icon: HabittusIcons.moodSwing),
      _Choice(id: 'Dor lombar', icon: HabittusIcons.pain),
      _Choice(id: 'Náusea', icon: HabittusIcons.sick),
      _Choice(id: 'Desejos', icon: HabittusIcons.meal),
      _Choice(id: 'Insónia', icon: HabittusIcons.sleep),
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
    // Usar os mesmos labels do enum MenstrualFlow
    const items = [
      _Choice(id: 'Nenhum', icon: HabittusIcons.water),
      _Choice(id: 'Spotting', icon: HabittusIcons.water),
      _Choice(id: 'Leve', icon: HabittusIcons.water),
      _Choice(id: 'Moderado', icon: HabittusIcons.water),
      _Choice(id: 'Intenso', icon: HabittusIcons.water),
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
