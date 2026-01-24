import 'package:flutter/material.dart';
import '../widgets/date_pills.dart';
import '../widgets/habittus_app_bar.dart';
import '../widgets/habittus_drawer.dart';
import '../widgets/weeklywaveschart.dart';
import '../widgets/weeklybarschart.dart';
import '../widgets/habittus_icons.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  DateTime d = DateTime(2025, 9, 25);
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F0),
      drawer: const HabittusDrawer(userName: 'USER_NAME', isDashboard: true),
      appBar: const HabittusAppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            DatePills(
              day: '${d.day}',
              month: monthName,
              year: '${d.year}',
              onDayPrev: () =>
                  setState(() => d = d.subtract(const Duration(days: 1))),
              onDayNext: () =>
                  setState(() => d = d.add(const Duration(days: 1))),
              onMonthPrev: () =>
                  setState(() => d = d = DateTime(d.year, d.month - 1, d.day)),
              onMonthNext: () =>
                  setState(() => d = d = DateTime(d.year, d.month + 1, d.day)),
              onYearPrev: () =>
                  setState(() => d = DateTime(d.year - 1, d.month, d.day)),
              onYearNext: () =>
                  setState(() => d = DateTime(d.year + 1, d.month, d.day)),
            ),
            const SizedBox(height: 16),

            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardTitle(
                    icon: HabittusIcons.emotion,
                    iconColor: HabittusIcons.moodColor,
                    title: 'Estado de Espírito',
                    subtitle: 'Registos',
                  ),
                  const SizedBox(height: 10),
                  const _MoodGrid(),
                ],
              ),
            ),

            const SizedBox(height: 12),

            _Card(
              background: const Color(0xFFF3F5EA),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardTitle(
                    icon: HabittusIcons.water,
                    iconColor: HabittusIcons.waterColor,
                    title: 'Hidratação',
                    subtitle: 'Histórico semanal',
                  ),
                  const SizedBox(height: 12),
                  const WeeklyWavesChart(),
                ],
              ),
            ),

            const SizedBox(height: 12),

            _Card(
              background: const Color(0xFFF3F5EA),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardTitle(
                    icon: HabittusIcons.sleep,
                    iconColor: HabittusIcons.sleepColor,
                    title: 'Horas de Descanso',
                    subtitle: 'Histórico semanal',
                  ),
                  const SizedBox(height: 12),
                  const WeeklyBarsChart(),
                ],
              ),
            ),

            const SizedBox(height: 12),

            _Card(
              background: const Color(0xFFF3F5EA),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardTitle(
                    icon: HabittusIcons.cycle,
                    iconColor: HabittusIcons.cycleColor,
                    title: 'Calendário Menstrual',
                    subtitle: 'Acompanha o teu ciclo e os teus registos',
                  ),
                  const SizedBox(height: 10),
                  _MonthHeader(
                    month: 'August',
                    year: '2025',
                    onPrev: () {},
                    onNext: () {},
                  ),
                  const SizedBox(height: 10),
                  const _MiniCalendar(),
                  const SizedBox(height: 10),
                  const _CyclePills(),
                ],
              ),
            ),

            const SizedBox(height: 12),

            _Card(
              background: const Color(0xFFF3F5EA),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardTitle(
                    icon: HabittusIcons.fertile,
                    iconColor: HabittusIcons.cycleColor,
                    title: 'Ciclo Atual',
                    subtitle: 'Dias até à próxima menstruação',
                  ),
                  const SizedBox(height: 10),
                  const _CycleGauge(daysLeft: 19),
                ],
              ),
            ),

            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

/* ---------- CARD / TITLES ---------- */

class _Card extends StatelessWidget {
  final Widget child;
  final Color background;

  const _Card({required this.child, this.background = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E6D4)),
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;

  const _CardTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: (iconColor ?? HabittusIcons.primaryColor).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon, 
            size: 20,
            color: iconColor ?? HabittusIcons.primaryColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/* ---------- MOOD GRID ---------- */

class _MoodGrid extends StatelessWidget {
  const _MoodGrid();

  @override
  Widget build(BuildContext context) {
    // 5 colunas como no print, 3 linhas (placeholders)
    final icons = <IconData>[
      Icons.favorite_border,
      Icons.sentiment_neutral,
      Icons.sentiment_neutral,
      Icons.sentiment_satisfied,
      Icons.sentiment_very_satisfied,
      Icons.local_drink_outlined,
      Icons.restaurant_outlined,
      Icons.sentiment_neutral,
      Icons.bed_outlined,
      Icons.directions_walk,
      Icons.spa_outlined,
      Icons.circle,
      Icons.circle,
      Icons.circle,
      Icons.circle,
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(15, (i) {
        return Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFDDECCF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icons[i], size: 20),
        );
      }),
    );
  }
}

/* ---------- CALENDAR ---------- */

class _MonthHeader extends StatelessWidget {
  final String month;
  final String year;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthHeader({
    required this.month,
    required this.year,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$month $year',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        IconButton(
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left),
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _MiniCalendar extends StatelessWidget {
  const _MiniCalendar();

  @override
  Widget build(BuildContext context) {
    // layout fixo como no print (placeholder)
    final days = List.generate(31, (i) => i + 1);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFDDECCF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _Dow('S'),
              _Dow('M'),
              _Dow('T'),
              _Dow('W'),
              _Dow('T'),
              _Dow('F'),
              _Dow('S'),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: days.map((d) {
              final isHighlight = d == 17;
              final isDark = d == 13 || d == 27;
              return _DayDot(text: '$d', filled: isHighlight, dark: isDark);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _Dow extends StatelessWidget {
  final String t;
  const _Dow(this.t);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      child: Center(
        child: Text(
          t,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  final String text;
  final bool filled;
  final bool dark;

  const _DayDot({required this.text, this.filled = false, this.dark = false});

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.white.withOpacity(.55);
    Color fg = Colors.black87;

    if (dark) {
      bg = const Color(0xFF8A8E8A);
      fg = Colors.white;
    }
    if (filled) {
      bg = const Color(0xFF2F5B2F);
      fg = Colors.white;
    }

    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/* ---------- CYCLE PILLS ---------- */

class _CyclePills extends StatelessWidget {
  const _CyclePills();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: const [
        _OutlinedPill(text: 'Menstruação'),
        _OutlinedPill(text: 'Ovulação'),
        _OutlinedPill(text: 'Período Fértil'),
      ],
    );
  }
}

class _OutlinedPill extends StatelessWidget {
  final String text;
  const _OutlinedPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBFCDB2)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/* ---------- CYCLE GAUGE ---------- */

class _CycleGauge extends StatelessWidget {
  final int daysLeft;
  const _CycleGauge({required this.daysLeft});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 210,
        height: 210,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(size: const Size(210, 210), painter: _GaugePainter()),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$daysLeft',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'dias restantes',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
            const Positioned(
              right: 18,
              top: 18,
              child: Icon(Icons.info_outline, size: 18, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 18;

    final base = Paint()
      ..color = const Color(0xFFCEDAC0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final arc = Paint()
      ..color = const Color(0xFF9EBC7D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    // base circle
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      0,
      6.283185,
      false,
      base,
    );

    // highlight arc (como no print: 2 segmentos)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      -1.2,
      1.1,
      false,
      arc,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      1.6,
      0.6,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
