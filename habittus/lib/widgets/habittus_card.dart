import 'package:flutter/material.dart';

class HabittusCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const HabittusCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitle!,
                style: TextStyle(color: Colors.green.shade800, fontSize: 12),
              ),
            ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
