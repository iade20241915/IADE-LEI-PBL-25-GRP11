import 'package:flutter/material.dart';

class DatePills extends StatelessWidget {
  final String day;
  final String month;
  final String year;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const DatePills({
    super.key,
    required this.day,
    required this.month,
    required this.year,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFDDEACF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onPrev,
            icon: Icon(Icons.chevron_left, color: Colors.green.shade800),
          ),
          _pill(day),
          const SizedBox(width: 8),
          _pill(month),
          const SizedBox(width: 8),
          _pill(year),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onNext,
            icon: Icon(Icons.chevron_right, color: Colors.green.shade800),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.green.shade900,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
