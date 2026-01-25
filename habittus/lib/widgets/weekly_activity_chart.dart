import 'package:flutter/material.dart';

/// Gráfico de barras para atividade física (minutos)
class WeeklyActivityChart extends StatelessWidget {
  final List<int> minutes;
  final List<String> labels;
  final int goalMinutes;

  const WeeklyActivityChart({
    super.key,
    this.minutes = const [0, 0, 0, 0, 0, 0, 0],
    this.labels = const ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'],
    this.goalMinutes = 60,
  });

  @override
  Widget build(BuildContext context) {
    final displayMinutes = minutes.length >= 7 
        ? minutes 
        : List.filled(7, 0);
    final displayLabels = labels.length >= 7 
        ? labels 
        : const ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final mins = displayMinutes[i];
          final value = (mins / goalMinutes).clamp(0.0, 1.5);
          final hasData = mins > 0;
          
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Label de minutos
                if (hasData)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${mins}m',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                
                // Barra
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 12,
                      height: hasData ? 100 * value : 4,
                      decoration: BoxDecoration(
                        gradient: hasData
                            ? const LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                              )
                            : null,
                        color: hasData ? null : const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Label do dia
                _DayBubble(
                  text: displayLabels[i],
                  isActive: hasData,
                ),
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
  final bool isActive;

  const _DayBubble({required this.text, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
