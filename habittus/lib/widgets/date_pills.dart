// lib/widgets/date_pills.dart
import 'package:flutter/material.dart';

class DatePills extends StatelessWidget {
  final String day;
  final String month;
  final String year;

  final VoidCallback onDayPrev;
  final VoidCallback onDayNext;
  final VoidCallback onMonthPrev;
  final VoidCallback onMonthNext;
  final VoidCallback onYearPrev;
  final VoidCallback onYearNext;

  const DatePills({
    super.key,
    required this.day,
    required this.month,
    required this.year,
    required this.onDayPrev,
    required this.onDayNext,
    required this.onMonthPrev,
    required this.onMonthNext,
    required this.onYearPrev,
    required this.onYearNext,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        // spacing do Wrap (tem de bater com os valores abaixo)
        const spacing = 2.0;

        // “ideais” (layout normal)
        const idealDayGroup = 28.0;
        const idealMonthGroup = 40.0;
        const idealYearGroup = 30.0;

        // “mínimos absolutos” (para não colapsar mas permitir caber)
        const minDayGroup = 28.0;
        const minMonthGroup = 40.0;
        const minYearGroup = 30.0;

        // largura total ideal (3 grupos + 2 espaços)
        final idealTotal =
            idealDayGroup + idealMonthGroup + idealYearGroup + (2 * spacing);
        final w = c.maxWidth;

        // fator de escala só quando o ecrã é menor que o ideal
        final scale = (w / idealTotal).clamp(0.80, 1.0);

        // minWidth adaptativo
        final dayGroupW = (idealDayGroup * scale).clamp(
          minDayGroup,
          idealDayGroup,
        );
        final monthGroupW = (idealMonthGroup * scale).clamp(
          minMonthGroup,
          idealMonthGroup,
        );
        final yearGroupW = (idealYearGroup * scale).clamp(
          minYearGroup,
          idealYearGroup,
        );

        // maxWidth do pill do mês (para evitar “crush”)
        final monthPillMax = (w - 120).clamp(60.0, 120.0);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFDDECCF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFBFCDB2), width: 0.6),
          ),
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: spacing,
              runSpacing: 2,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: dayGroupW),
                  child: _GroupFixed(
                    text: day,
                    minPillWidth: 30,
                    onPrev: onDayPrev,
                    onNext: onDayNext,
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: monthGroupW),
                  child: _GroupFlexible(
                    text: month,
                    maxPillWidth: monthPillMax,
                    onPrev: onMonthPrev,
                    onNext: onMonthNext,
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: yearGroupW),
                  child: _GroupFixed(
                    text: year,
                    minPillWidth: 30,
                    onPrev: onYearPrev,
                    onNext: onYearNext,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/* ---------- Groups ---------- */

class _GroupFixed extends StatelessWidget {
  final String text;
  final double minPillWidth;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _GroupFixed({
    required this.text,
    required this.minPillWidth,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MiniIcon(icon: Icons.chevron_left, onTap: onPrev),
        const SizedBox(width: 2),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: minPillWidth),
          child: _Pill(text: text),
        ),
        const SizedBox(width: 2),
        _MiniIcon(icon: Icons.chevron_right, onTap: onNext),
      ],
    );
  }
}

class _GroupFlexible extends StatelessWidget {
  final String text;
  final double maxPillWidth;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _GroupFlexible({
    required this.text,
    required this.maxPillWidth,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MiniIcon(icon: Icons.chevron_left, onTap: onPrev),
        const SizedBox(width: 1),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: 60, maxWidth: maxPillWidth),
          child: _Pill(text: text),
        ),
        const SizedBox(width: 1),
        _MiniIcon(icon: Icons.chevron_right, onTap: onNext),
      ],
    );
  }
}

/* ---------- Pill + Icon ---------- */

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFCDB2), width: 0.6),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF244A24),
        ),
      ),
    );
  }
}

class _MiniIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEFF6E6),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 20,
          height: 20,
          child: Icon(icon, size: 18, color: const Color(0xFF2F5B2F)),
        ),
      ),
    );
  }
}
