import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/water_controller.dart';
import '../widgets/date_selector.dart';
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

  int get gridSize => rows * cols;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WaterController>().load(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WaterController>();

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
              title: 'HydrateLog',
              subtitle: 'Contador de água',
              child: Column(
                children: [
                  _CupGrid(
                    rows: rows,
                    cols: cols,
                    filledCount: controller.cups,
                    onTap: (index) =>
                        controller.toggleCup(index, gridSize: gridSize),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Consumiu ${controller.totalMl} ml de água, ou ${controller.cups} copos de água.',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

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
