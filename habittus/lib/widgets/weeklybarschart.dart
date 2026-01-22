import 'package:flutter/material.dart';

class WeeklyBarsChart extends StatelessWidget {
  const WeeklyBarsChart({super.key});

  @override
  Widget build(BuildContext context) {
    // 7 dias, horas 0..1 (mock)
    const v = [0.95, 0.75, 0.85, 0.9, 0.8, 0.88, 0.92];
    const labels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 8,
                      height: 110 * v[i],
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F5B2F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _DayBubble(text: labels[i]),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _DayBubble extends StatelessWidget {
  final String text;
  const _DayBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFDDECCF),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
