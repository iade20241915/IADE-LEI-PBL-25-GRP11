import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/sleep_controller.dart';
import '../widgets/date_pills.dart';
import '../widgets/habittus_app_bar.dart';
import '../widgets/habittus_card.dart';
import '../widgets/habittus_drawer.dart';
import '../widgets/sleepdurationpicker.dart';
import '../widgets/weeklywaveschart.dart';

class SleepTimeScreen extends StatefulWidget {
  const SleepTimeScreen({super.key});

  @override
  State<SleepTimeScreen> createState() => _SleepTimeScreenState();
}

class _SleepTimeScreenState extends State<SleepTimeScreen> {
  late DateTime d;

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

  @override
  void initState() {
    super.initState();
    d = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SleepController>().load(d);
    });
  }

  void _setDate(DateTime newDate) {
    setState(() => d = newDate);
    context.read<SleepController>().load(newDate);
  }

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

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SleepController>();

    return Scaffold(
      drawer: const HabittusDrawer(userName: 'USER_NAME'),
      appBar: const HabittusAppBar(showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
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
            const SizedBox(height: 16),

            HabittusCard(
              title: 'Tempo de sono',
              subtitle: 'Arrasta o slider para registar o teu descanso.',
              child: SleepDurationPicker(
                duration: controller.sleepDuration,
                onPick: (dur) => controller.setSleepDuration(dur),
              ),
            ),

            const SizedBox(height: 16),

            const HabittusCard(
              title: 'Histórico semanal',
              subtitle: 'Últimos 7 dias',
              child: WeeklyWavesChart(),
            ),
          ],
        ),
      ),
    );
  }
}
