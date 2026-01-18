import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final bool filled;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = 160,
    this.height = 42,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    );

    return SizedBox(
      width: width,
      height: height,
      child: filled
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade300,
                elevation: 0,
                shape: shape,
              ),
              child: Text(text, style: const TextStyle(color: Colors.black87)),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                shape: shape,
                side: const BorderSide(color: Colors.green),
              ),
              child: Text(text, style: const TextStyle(color: Colors.green)),
            ),
    );
  }
}
