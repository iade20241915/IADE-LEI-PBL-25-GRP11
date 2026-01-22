import 'package:flutter/material.dart';

class WeeklyWavesChart extends StatelessWidget {
  const WeeklyWavesChart();

  @override
  Widget build(BuildContext context) {
    // 7 dias, valores 0..1 (mock)
    const v = [0.9, 0.8, 0.4, 0.3, 0.85, 0.65, 0.95];
    const labels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: CustomPaint(
                        painter: _WaveStemPainter(strength: v[i]),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _DayBubble(text: labels[i]),
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

class _WaveStemPainter extends CustomPainter {
  final double strength; // 0..1
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

    // stem (linha clara)
    final stemTop = size.height * 0.05;
    final stemBottom = size.height * 0.95;
    canvas.drawLine(
      Offset(size.width / 2, stemTop),
      Offset(size.width / 2, stemBottom),
      paintStem,
    );

    // wave (curva escura) com altura proporcional
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

  @override
  bool shouldRepaint(covariant _WaveStemPainter oldDelegate) =>
      oldDelegate.strength != strength;
}
