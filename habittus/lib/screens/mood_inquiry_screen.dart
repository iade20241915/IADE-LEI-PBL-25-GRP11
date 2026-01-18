import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/mood_controller.dart';
import '../models/mood.dart';
import '../widgets/date_selector.dart';
import '../widgets/habittus_app_bar.dart';
import '../widgets/habittus_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/habittus_drawer.dart';

class MoodInquiryScreen extends StatefulWidget {
  const MoodInquiryScreen({super.key});

  @override
  State<MoodInquiryScreen> createState() => _MoodInquiryScreenState();
}

class _MoodInquiryScreenState extends State<MoodInquiryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodController>().load(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MoodController>();

    return Scaffold(
      drawer: const HabittusDrawer(userName: 'USER_NAME'),
      appBar: const HabittusAppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const DateSelector(day: '25', month: 'September', year: '2025'),
            const SizedBox(height: 16),

            HabittusCard(
              title: 'Como te sentes hoje?',
              subtitle: 'Seleciona uma opção',
              child: _MoodGrid(
                selected: controller.selected,
                onSelect: controller.select,
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: PrimaryButton(
                text: 'Continuar',
                onPressed: controller.selected == null
                    ? null
                    : () async {
                        // Se quiseres guardar:
                        // await context.read<MoodController>().submit();

                        Navigator.pop(context);
                      },
                width: 140,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodGrid extends StatelessWidget {
  final MoodLevel? selected;
  final ValueChanged<MoodLevel> onSelect;

  const _MoodGrid({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final items = <({MoodLevel level, String label, IconData icon})>[
      (
        level: MoodLevel.veryBad,
        label: 'Muito mal',
        icon: Icons.sentiment_very_dissatisfied,
      ),
      (level: MoodLevel.bad, label: 'Mal', icon: Icons.sentiment_dissatisfied),
      (
        level: MoodLevel.neutral,
        label: 'Neutro',
        icon: Icons.sentiment_neutral,
      ),
      (level: MoodLevel.good, label: 'Bem', icon: Icons.sentiment_satisfied),
      (
        level: MoodLevel.veryGood,
        label: 'Muito bem',
        icon: Icons.sentiment_very_satisfied,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final it = items[index];
        final isSelected = selected == it.level;

        return InkWell(
          onTap: () => onSelect(it.level),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFBFDFA8)
                  : const Color(0xFFEAF3E3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Colors.green.shade700
                    : Colors.green.shade200,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(it.icon, color: Colors.green.shade800),
                const SizedBox(height: 6),
                Text(
                  it.label,
                  style: const TextStyle(fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
