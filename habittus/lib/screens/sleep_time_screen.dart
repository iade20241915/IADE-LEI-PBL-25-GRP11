import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';

import '../controllers/sleep_controller.dart';
import '../widgets/date_selector.dart';
import '../widgets/habittus_app_bar.dart';
import '../widgets/habittus_card.dart';
import '../widgets/habittus_drawer.dart';

class SleepTimeScreen extends StatefulWidget {
  const SleepTimeScreen({super.key});

  @override
  State<SleepTimeScreen> createState() => _SleepTimeScreenState();
}

class _SleepTimeScreenState extends State<SleepTimeScreen> {
  @override
  void initState() {
    super.initState();
    /*   WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SleepController>().load(DateTime.now());
    });*/
  }

  @override
  Widget build(BuildContext context) {
    //final controller = context.watch<SleepController>();

    return Scaffold(
      drawer: const HabittusDrawer(userName: 'USER_NAME'),
      appBar: const HabittusAppBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade800,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const DateSelector(day: '25', month: 'September', year: '2025'),
            const SizedBox(height: 12),

            HabittusCard(
              title: 'Tempo de sono',
              subtitle: 'Ajuste o valor do descanso',
              child: _SleepDurationPicker(
                /*                duration: controller.sleepDuration,
                onPick: (d) => controller.setSleepDuration(d),*/
                duration: const Duration(hours: 8),
                onPick: (d) => 0,
              ),
            ),

            const SizedBox(height: 16),

            const HabittusCard(
              title: 'Histórico semanal',
              subtitle: 'Últimos 7 dias',
              child: _ChartPlaceholder(height: 140),
            ),
          ],
        ),
      ),
    );
  }
}

class _SleepDurationPicker extends StatelessWidget {
  final Duration duration;
  final ValueChanged<Duration> onPick;

  const _SleepDurationPicker({required this.duration, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay(
      hour: duration.inHours,
      minute: duration.inMinutes.remainder(60),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFDDEACF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.bedtime_outlined, color: Colors.green),
          const SizedBox(width: 10),
          const Text(
            'BED TIME',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: time,
              );
              if (picked == null) return;
              onPick(Duration(hours: picked.hour, minutes: picked.minute));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                time.format(context),
                style: TextStyle(
                  color: Colors.green.shade900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  final double height;
  const _ChartPlaceholder({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3E3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          'Gráfico semanal (placeholder)',
          style: TextStyle(color: Colors.green.shade800, fontSize: 12),
        ),
      ),
    );
  }
}
