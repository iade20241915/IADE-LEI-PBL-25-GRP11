import 'package:flutter/material.dart';
import 'package:habittus/widgets/weeklywaveschart.dart';
import 'package:provider/provider.dart';

import '../controllers/water_controller.dart';
import '../widgets/date_pills.dart';
import '../widgets/habittus_app_bar.dart';
import '../widgets/habittus_card.dart';
import '../widgets/habittus_drawer.dart';

class WaterIntakeScreen extends StatefulWidget {
  const WaterIntakeScreen({super.key});

  @override
  State<WaterIntakeScreen> createState() => _WaterIntakeScreenState();
}

class _WaterIntakeScreenState extends State<WaterIntakeScreen> {
  static const int rows = 4;
  static const int cols = 4;
  static const int dailyGoalMl = 2000;

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

  int get gridSize => rows * cols;

  @override
  void initState() {
    super.initState();
    d = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WaterController>().load(d);
    });
  }

  void _setDate(DateTime newDate) {
    setState(() => d = newDate);
    context.read<WaterController>().load(newDate);
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
    final controller = context.watch<WaterController>();
    final progress = (controller.totalMl / dailyGoalMl).clamp(0.0, 1.0);

    return Scaffold(
      drawer: const HabittusDrawer(userName: 'USER_NAME'),
      appBar: const HabittusAppBar(showBack: true),

      floatingActionButton: WaterQuickAddFab(
        onAddMl: (ml, source) async {
          // Base atual: "cups" (250ml por copo)
          const int mlPerCup = 250;

          final cupsToAdd = (ml / mlPerCup).round().clamp(1, 99);
          final newCups = (controller.cups + cupsToAdd).clamp(0, gridSize);

          // Persistência usando toggleCup (index 0-based)
          if (newCups <= 0) {
            await controller.toggleCup(0, gridSize: gridSize);
            await controller.toggleCup(0, gridSize: gridSize);
          } else {
            await controller.toggleCup(newCups - 1, gridSize: gridSize);
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Adicionado $ml ml'),
                duration: const Duration(milliseconds: 900),
              ),
            );
          }
        },
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

            HabittusCard(
              title: 'HydrateLog',
              subtitle: 'Contador de água',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CupGrid(
                    rows: rows,
                    cols: cols,
                    filledCount: controller.cups,
                    onTap: (index) =>
                        controller.toggleCup(index, gridSize: gridSize),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: const Color(0xFFEAF3E3),
                            valueColor: AlwaysStoppedAnimation(
                              Colors.green.shade700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${controller.totalMl} / $dailyGoalMl ml',
                        style: TextStyle(
                          color: Colors.green.shade900,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Consumiu ${controller.totalMl} ml (≈ ${controller.cups} copos).',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            HabittusCard(
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

class _CupGrid extends StatelessWidget {
  final int rows;
  final int cols;
  final int filledCount;
  final void Function(int index) onTap;

  const _CupGrid({
    required this.rows,
    required this.cols,
    required this.filledCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(rows, (r) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: List.generate(cols, (c) {
              final index = r * cols + c;
              final isFilled = index < filledCount;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: c == cols - 1 ? 0 : 8),
                  child: InkWell(
                    onTap: () => onTap(index),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: isFilled
                            ? const Color(0xFFBFDFA8)
                            : const Color(0xFFEAF3E3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add,
                          size: 18,
                          color: isFilled
                              ? Colors.green.shade900
                              : Colors.green.shade400,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

enum WaterAddSource { manual, bottle }

class WaterQuickAddFab extends StatefulWidget {
  final Future<void> Function(int ml, WaterAddSource source) onAddMl;

  const WaterQuickAddFab({super.key, required this.onAddMl});

  @override
  State<WaterQuickAddFab> createState() => _WaterQuickAddFabState();
}

class _WaterQuickAddFabState extends State<WaterQuickAddFab>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _entry;
  bool _open = false;

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 160),
  );

  @override
  void dispose() {
    _removeOverlay();
    _c.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _entry?.remove();
    _entry = null;
    _open = false;
  }

  Future<void> _close() async {
    if (!_open) return;
    await _c.reverse();
    _removeOverlay();
    if (mounted) setState(() {});
  }

  Future<void> _openMenu() async {
    if (_open) return;

    _entry = _buildOverlay();
    Overlay.of(context).insert(_entry!);

    _open = true;
    if (mounted) setState(() {});
    await _c.forward();
  }

  Future<void> _tapAdd(int ml, WaterAddSource src) async {
    await _close();
    await widget.onAddMl(ml, src);
  }

  OverlayEntry _buildOverlay() {
    return OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _close,
                child: const SizedBox.expand(),
              ),
            ),

            // Menu ancorado ao FAB
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(-40, -190),
              child: Material(
                color: Colors.transparent,
                child: FadeTransition(
                  opacity: CurvedAnimation(parent: _c, curve: Curves.easeOut),
                  child: ScaleTransition(
                    scale: CurvedAnimation(parent: _c, curve: Curves.easeOut),
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _QuickPill(
                          icon: Icons.local_drink_outlined,
                          label: '200ml',
                          onTap: () => _tapAdd(200, WaterAddSource.manual),
                        ),
                        const SizedBox(height: 6),
                        _QuickPill(
                          icon: Icons.local_drink_outlined,
                          label: '300ml',
                          onTap: () => _tapAdd(300, WaterAddSource.manual),
                        ),
                        const SizedBox(height: 6),
                        _QuickPill(
                          icon: Icons.local_drink_outlined,
                          label: '500ml',
                          onTap: () => _tapAdd(500, WaterAddSource.manual),
                        ),
                        const SizedBox(height: 6),
                        _QuickPill(
                          icon: Icons.water_drop_outlined,
                          label: '500ml',
                          onTap: () => _tapAdd(500, WaterAddSource.bottle),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: FloatingActionButton(
        backgroundColor: Colors.green.shade800,
        onPressed: () {
          if (_open) {
            _close();
          } else {
            _openMenu();
          }
        },
        child: AnimatedRotation(
          turns: _open ? 0.125 : 0,
          duration: const Duration(milliseconds: 160),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

class _QuickPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFDFF0CC),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.green.shade900),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: Colors.green.shade900,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
