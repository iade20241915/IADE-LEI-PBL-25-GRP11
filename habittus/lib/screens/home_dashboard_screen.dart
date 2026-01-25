import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/water_controller.dart';
import '../controllers/sleep_controller.dart';
import '../controllers/activity_controller.dart';
import '../controllers/habit_controller.dart';
import '../controllers/cycle_controller.dart';
import '../controllers/meal_controller.dart';
import '../controllers/mood_controller.dart';
import '../controllers/user_controller.dart';
import '../models/cycle_entry.dart';
import '../models/mood.dart';
import '../widgets/date_pills.dart';
import '../widgets/habittus_app_bar.dart';
import '../widgets/habittus_drawer.dart';
import '../widgets/weeklywaveschart.dart';
import '../widgets/weeklybarschart.dart';
import '../widgets/weekly_activity_chart.dart';
import '../widgets/habittus_icons.dart';
import '../widgets/save_status_banner.dart';
import 'meals_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  DateTime d = DateTime.now();
  
  String get monthName => const [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ][d.month - 1];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final waterController = context.read<WaterController>();
    final sleepController = context.read<SleepController>();
    final activityController = context.read<ActivityController>();
    final habitController = context.read<HabitController>();
    final cycleController = context.read<CycleController>();
    final mealController = context.read<MealController>();
    final moodController = context.read<MoodController>();
    final userController = context.read<UserController>();
    
    final futures = <Future>[
      waterController.load(d),
      sleepController.load(d),
      activityController.load(d),
      habitController.load(),
      mealController.load(d),
      moodController.load(d),
    ];
    
    // Só carregar ciclo se for feminino
    if (userController.isFemale) {
      futures.add(cycleController.load(d));
    }
    
    await Future.wait(futures);
  }

  void _setDate(DateTime newDate) {
    setState(() => d = newDate);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final waterController = context.watch<WaterController>();
    final sleepController = context.watch<SleepController>();
    final activityController = context.watch<ActivityController>();
    final habitController = context.watch<HabitController>();
    final cycleController = context.watch<CycleController>();
    final mealController = context.watch<MealController>();
    final moodController = context.watch<MoodController>();
    final userController = context.watch<UserController>();
    final userName = userController.userName;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F0),
      drawer: HabittusDrawer(isDashboard: true),
      appBar: const HabittusAppBar(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              // Saudação
              Text(
                'Olá, $userName!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Acompanha os teus hábitos',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),

              // Date Pills
              DatePills(
                day: '${d.day}',
                month: monthName,
                year: '${d.year}',
                onDayPrev: () => _setDate(d.subtract(const Duration(days: 1))),
                onDayNext: () => _setDate(d.add(const Duration(days: 1))),
                onMonthPrev: () => _setDate(DateTime(d.year, d.month - 1, d.day)),
                onMonthNext: () => _setDate(DateTime(d.year, d.month + 1, d.day)),
                onYearPrev: () => _setDate(DateTime(d.year - 1, d.month, d.day)),
                onYearNext: () => _setDate(DateTime(d.year + 1, d.month, d.day)),
              ),
              const SizedBox(height: 16),

              // Card Hidratação
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/water'),
                borderRadius: BorderRadius.circular(14),
                child: _Card(
                  background: const Color(0xFFF3F5EA),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _CardTitle(
                              icon: HabittusIcons.water,
                              iconColor: HabittusIcons.waterColor,
                              title: 'Hidratação',
                              subtitle: '${waterController.totalMl}ml hoje',
                            ),
                          ),
                          SaveStatusIndicator(
                            isSaving: waterController.saveStatus == SaveStatus.saving,
                            isSuccess: waterController.saveStatus == SaveStatus.saved,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      waterController.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : WeeklyWavesChart(
                              values: waterController.weeklyChartValues,
                              labels: waterController.weeklyLabels,
                            ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Card Sono
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/sleep'),
                borderRadius: BorderRadius.circular(14),
                child: _Card(
                  background: const Color(0xFFF3F5EA),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _CardTitle(
                              icon: HabittusIcons.sleep,
                              iconColor: HabittusIcons.sleepColor,
                              title: 'Horas de Descanso',
                              subtitle: '${sleepController.sleepFormatted} hoje',
                            ),
                          ),
                          SaveStatusIndicator(
                            isSaving: sleepController.saveStatus == SleepSaveStatus.saving,
                            isSuccess: sleepController.saveStatus == SleepSaveStatus.saved,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      sleepController.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : WeeklyBarsChart(
                              values: sleepController.weeklyChartValues,
                              labels: sleepController.weeklyLabels,
                              hoursLabels: sleepController.weeklyHoursLabels,
                            ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Card Atividade Física
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/phisical'),
                borderRadius: BorderRadius.circular(14),
                child: _Card(
                  background: const Color(0xFFE8F5E9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _CardTitle(
                              icon: HabittusIcons.activity,
                              iconColor: const Color(0xFF4CAF50),
                              title: 'Atividade Física',
                              subtitle: '${activityController.todayMinutes}min hoje',
                            ),
                          ),
                          SaveStatusIndicator(
                            isSaving: activityController.saveStatus == ActivitySaveStatus.saving,
                            isSuccess: activityController.saveStatus == ActivitySaveStatus.saved,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      activityController.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : WeeklyActivityChart(
                              minutes: activityController.weeklyMinutes,
                              labels: activityController.weeklyLabels,
                            ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Card Hábitos
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/habits'),
                borderRadius: BorderRadius.circular(14),
                child: _Card(
                  background: const Color(0xFFFFF3E0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CardTitle(
                        icon: HabittusIcons.habit,
                        iconColor: const Color(0xFFFF9800),
                        title: 'Hábitos',
                        subtitle: '${habitController.totalHabits} registados',
                      ),
                      const SizedBox(height: 12),
                      habitController.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _HabitsSummary(
                              positive: habitController.totalPositive,
                              negative: habitController.totalNegative,
                            ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Card Mood / Estado de Espírito
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/mood'),
                borderRadius: BorderRadius.circular(14),
                child: _Card(
                  background: const Color(0xFFF3E5F5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _CardTitle(
                              icon: HabittusIcons.mood,
                              iconColor: HabittusIcons.moodColor,
                              title: 'Estado de Espírito',
                              subtitle: moodController.selectedLevel != null
                                  ? _getMoodLabel(moodController.selectedLevel!)
                                  : 'Sem registo hoje',
                            ),
                          ),
                          SaveStatusIndicator(
                            isSaving: moodController.saveStatus == MoodSaveStatus.saving,
                            isSuccess: moodController.saveStatus == MoodSaveStatus.saved,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      moodController.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _MoodIndicator(level: moodController.selectedLevel),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Card Alimentação
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MealsScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: _Card(
                  background: const Color(0xFFE8F5E9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _CardTitle(
                              icon: HabittusIcons.meal,
                              iconColor: HabittusIcons.foodColor,
                              title: 'Alimentação',
                              subtitle: '${mealController.todayCalories}kcal hoje',
                            ),
                          ),
                          SaveStatusIndicator(
                            isSaving: mealController.saveStatus == MealSaveStatus.saving,
                            isSuccess: mealController.saveStatus == MealSaveStatus.saved,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      mealController.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : WeeklyBarsChart(
                              values: mealController.weeklyChartValues,
                              labels: mealController.weeklyLabels,
                            ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Card Ciclo Menstrual - só para utilizadores femininos
              if (userController.isFemale)
                InkWell(
                  onTap: () => Navigator.pushNamed(context, '/menstrual-cycle'),
                  borderRadius: BorderRadius.circular(14),
                  child: _Card(
                    background: const Color(0xFFFCE4EC),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _CardTitle(
                                icon: HabittusIcons.cycle,
                                iconColor: HabittusIcons.cycleColor,
                                title: 'Ciclo Menstrual',
                                subtitle: cycleController.currentPhase?.label ?? 'Sem dados',
                              ),
                            ),
                            SaveStatusIndicator(
                              isSaving: cycleController.saveStatus == CycleSaveStatus.saving,
                              isSuccess: cycleController.saveStatus == CycleSaveStatus.saved,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        cycleController.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _CycleSummary(
                                daysUntilPeriod: cycleController.daysUntilNextPeriod,
                                currentPhase: cycleController.currentPhase,
                                menstruationDays: cycleController.menstruationDays,
                                month: d.month,
                                year: d.year,
                              ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------- WIDGETS AUXILIARES ---------- */

class _Card extends StatelessWidget {
  final Widget child;
  final Color background;

  const _Card({required this.child, this.background = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E6D4)),
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;

  const _CardTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: (iconColor ?? HabittusIcons.primaryColor).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: iconColor ?? HabittusIcons.primaryColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }
}

class _HabitsSummary extends StatelessWidget {
  final int positive;
  final int negative;

  const _HabitsSummary({required this.positive, required this.negative});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _HabitPill(
            label: 'Positivos',
            count: positive,
            color: Colors.green,
            icon: Icons.trending_up,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _HabitPill(
            label: 'A reduzir',
            count: negative,
            color: Colors.orange,
            icon: Icons.trending_down,
          ),
        ),
      ],
    );
  }
}

class _HabitPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _HabitPill({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CycleSummary extends StatelessWidget {
  final int? daysUntilPeriod;
  final dynamic currentPhase;
  final List<int> menstruationDays;
  final int month;
  final int year;

  const _CycleSummary({
    this.daysUntilPeriod,
    this.currentPhase,
    required this.menstruationDays,
    required this.month,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    if (daysUntilPeriod == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Regista o teu ciclo para ver previsões',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Gauge circular
        Center(
          child: SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: ((28 - daysUntilPeriod!) / 28).clamp(0.0, 1.0),
                  strokeWidth: 12,
                  backgroundColor: Colors.pink.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.pink.shade400),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$daysUntilPeriod',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.pink.shade700,
                      ),
                    ),
                    const Text(
                      'dias',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Mini calendário com dias de menstruação
        if (menstruationDays.isNotEmpty)
          Wrap(
            spacing: 6,
            children: menstruationDays.take(7).map((day) {
              return Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.pink.shade200,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '$day',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

/// Helper para obter label do mood
String _getMoodLabel(MoodLevel level) {
  switch (level) {
    case MoodLevel.veryBad:
      return 'Muito Mal';
    case MoodLevel.bad:
      return 'Mal';
    case MoodLevel.neutral:
      return 'Neutro';
    case MoodLevel.good:
      return 'Bem';
    case MoodLevel.veryGood:
      return 'Muito Bem';
  }
}

/// Widget indicador de Mood com emojis
class _MoodIndicator extends StatelessWidget {
  final MoodLevel? level;

  const _MoodIndicator({this.level});

  @override
  Widget build(BuildContext context) {
    final moods = [
      (MoodLevel.veryBad, '😢', 'Muito Mal'),
      (MoodLevel.bad, '😕', 'Mal'),
      (MoodLevel.neutral, '😐', 'Neutro'),
      (MoodLevel.good, '🙂', 'Bem'),
      (MoodLevel.veryGood, '😄', 'Muito Bem'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: moods.map((mood) {
        final isSelected = level == mood.$1;
        return Column(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? HabittusIcons.moodColor.withOpacity(0.2)
                    : const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(22),
                border: isSelected
                    ? Border.all(color: HabittusIcons.moodColor, width: 2)
                    : null,
              ),
              child: Text(
                mood.$2,
                style: TextStyle(
                  fontSize: isSelected ? 24 : 20,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mood.$3,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? HabittusIcons.moodColor : Colors.black54,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
