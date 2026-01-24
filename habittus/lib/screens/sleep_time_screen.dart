import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/sleep_controller.dart';
import '../widgets/date_pills.dart';
import '../widgets/habittus_app_bar.dart';
import '../widgets/habittus_card.dart';
import '../widgets/habittus_drawer.dart';
import '../widgets/sleepdurationpicker.dart';
import '../widgets/weeklywaveschart.dart';
import '../widgets/habittus_icons.dart';

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

  Future<void> _showAddSleepDialog() async {
    final controller = context.read<SleepController>();
    Duration tempDuration = controller.sleepDuration;
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFF6F8F0),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: HabittusIcons.sleepColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        HabittusIcons.sleep,
                        color: HabittusIcons.sleepColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Registar sono',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Quantas horas dormiste?',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Duration picker
                SleepDurationPicker(
                  duration: tempDuration,
                  onPick: (dur) => setSheetState(() => tempDuration = dur),
                ),
                
                const SizedBox(height: 24),
                
                // Quick options
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _QuickSleepOption(
                      hours: 6,
                      isSelected: tempDuration.inMinutes == 360,
                      onTap: () => setSheetState(() => tempDuration = const Duration(hours: 6)),
                    ),
                    _QuickSleepOption(
                      hours: 7,
                      isSelected: tempDuration.inMinutes == 420,
                      onTap: () => setSheetState(() => tempDuration = const Duration(hours: 7)),
                    ),
                    _QuickSleepOption(
                      hours: 8,
                      isSelected: tempDuration.inMinutes == 480,
                      onTap: () => setSheetState(() => tempDuration = const Duration(hours: 8)),
                    ),
                    _QuickSleepOption(
                      hours: 9,
                      isSelected: tempDuration.inMinutes == 540,
                      onTap: () => setSheetState(() => tempDuration = const Duration(hours: 9)),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.setSleepDuration(tempDuration);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(HabittusIcons.check, color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              Text('${tempDuration.inHours}h ${tempDuration.inMinutes % 60}min registado!'),
                            ],
                          ),
                          backgroundColor: HabittusIcons.sleepColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HabittusIcons.sleepColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Guardar',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ),
                
                SizedBox(height: MediaQuery.of(ctx).viewInsets.bottom + 16),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SleepController>();
    final hours = controller.sleepDuration.inHours;
    final minutes = controller.sleepDuration.inMinutes % 60;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F0),
      drawer: const HabittusDrawer(userName: 'USER_NAME'),
      appBar: const HabittusAppBar(showBack: true),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSleepDialog,
        backgroundColor: HabittusIcons.sleepColor,
        child: const Icon(HabittusIcons.add, color: Colors.white),
      ),
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

            // Sleep summary card
            HabittusCard(
              title: 'Tempo de sono',
              subtitle: 'Registo de hoje',
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: HabittusIcons.sleepColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          HabittusIcons.sleep,
                          color: HabittusIcons.sleepColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${hours}h ${minutes}min',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: HabittusIcons.sleepColor,
                            ),
                          ),
                          Text(
                            hours >= 7 ? 'Bom descanso! 😊' : hours >= 5 ? 'Pode melhorar 😐' : 'Descansa mais! 😴',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Meta: 8 horas',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          Text(
                            '${((hours + minutes / 60) / 8 * 100).clamp(0, 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 12, 
                              fontWeight: FontWeight.w700,
                              color: HabittusIcons.sleepColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: ((hours + minutes / 60) / 8).clamp(0.0, 1.0),
                          minHeight: 10,
                          backgroundColor: HabittusIcons.sleepColor.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation(HabittusIcons.sleepColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Slider card
            HabittusCard(
              title: 'Ajustar tempo',
              subtitle: 'Arrasta o slider para ajustar',
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

class _QuickSleepOption extends StatelessWidget {
  final int hours;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickSleepOption({
    required this.hours,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? HabittusIcons.sleepColor.withOpacity(0.2) 
              : const Color(0xFFE4EAD8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? HabittusIcons.sleepColor : const Color(0xFFD9E1D0),
            width: 2,
          ),
        ),
        child: Text(
          '${hours}h',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isSelected ? HabittusIcons.sleepColor : Colors.black87,
          ),
        ),
      ),
    );
  }
}
