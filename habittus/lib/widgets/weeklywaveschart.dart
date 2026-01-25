import 'package:flutter/material.dart';

/// Gráfico de ondas para hidratação
class WeeklyWavesChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;

  const WeeklyWavesChart({
    super.key,
    this.values = const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    this.labels = const ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'],
  });

  @override
  Widget build(BuildContext context) {
    final displayValues = values.length >= 7 
        ? values 
        : List.filled(7, 0.0);
    final displayLabels = labels.length >= 7 
        ? labels 
        : const ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final value = displayValues[i].clamp(0.0, 1.0);
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: CustomPaint(
                        painter: _WaveStemPainter(strength: value),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _DayBubble(
                      text: displayLabels[i],
                      isActive: value > 0,
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
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
        color: isActive ? const Color(0xFF9EBC7D) : const Color(0xFFDDECCF),
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

class _WaveStemPainter extends CustomPainter {
  final double strength;

  _WaveStemPainter({required this.strength});

  @override
  void paint(Canvas canvas, Size size) {
    final paintStem = Paint()
      ..color = const Color(0xFF9EBC7D)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final paintWave = Paint()
      ..color = const Color(0xFF2F5B2F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final stemTop = size.height * 0.05;
    final stemBottom = size.height * 0.95;
    
    // Stem (linha de fundo)
    canvas.drawLine(
      Offset(size.width / 2, stemTop),
      Offset(size.width / 2, stemBottom),
      paintStem,
    );

    if (strength > 0) {
      // Wave (curva proporcional ao valor)
      final waveHeight = (stemBottom - stemTop) * strength;
      final startY = stemBottom - waveHeight;
      final midX = size.width / 2;

      final path = Path();
      path.moveTo(midX, startY);

      final seg = waveHeight / 5;
      for (int i = 0; i < 5; i++) {
        final y1 = startY + seg * (i + 0.5);
        final y2 = startY + seg * (i + 1);
        final dx = (i % 2 == 0) ? 10.0 : -10.0;
        path.quadraticBezierTo(midX + dx, y1, midX, y2);
      }

      canvas.drawPath(path, paintWave);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveStemPainter oldDelegate) =>
      oldDelegate.strength != strength;
}
