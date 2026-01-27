import 'package:flutter/material.dart';

class SleepDurationPicker extends StatefulWidget {
  final Duration duration;
  final ValueChanged<Duration> onPick;

  final Duration min;
  final Duration max;
  final Duration step;

  const SleepDurationPicker({
    super.key,
    required this.duration,
    required this.onPick,
    this.min = Duration.zero,
    this.max = const Duration(hours: 12),
    this.step = const Duration(minutes: 15),
  });

  @override
  State<SleepDurationPicker> createState() => _SleepDurationPickerState();
}

class _SleepDurationPickerState extends State<SleepDurationPicker> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = _durationToT(widget.duration);
  }

  @override
  void didUpdateWidget(covariant SleepDurationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _value = _durationToT(widget.duration);
    }
  }

  double _durationToT(Duration d) {
    final minM = widget.min.inMinutes;
    final maxM = widget.max.inMinutes;
    final span = maxM - minM;
    if (span <= 0) return 0;

    final clampedM = d.inMinutes.clamp(minM, maxM);
    return (clampedM - minM) / span;
  }

  Duration _tToDuration(double t) {
    final minM = widget.min.inMinutes;
    final maxM = widget.max.inMinutes;
    final span = maxM - minM;

    final raw = minM + (t * span).round();
    final stepM = widget.step.inMinutes;

    final snapped = ((raw / stepM).round()) * stepM;
    final clamped = snapped.clamp(minM, maxM);

    return Duration(minutes: clamped);
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final picked = _tToDuration(_value);

    return Row(
      children: [
        // Slider container
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFBFDFA8).withOpacity(0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 8,
                overlayShape: SliderComponentShape.noOverlay,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 12,
                ),
                activeTrackColor: Colors.green.shade600,
                inactiveTrackColor: const Color(0xFFEAF3E3),
                thumbColor: Colors.green.shade700,
              ),
              child: Slider(
                value: _value.clamp(0.0, 1.0),
                onChanged: (v) {
                  setState(() => _value = v);
                  widget.onPick(_tToDuration(v));
                },
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Display container
        Container(
          width: 80,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3E3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Center(
            child: Text(
              _fmt(picked),
              style: TextStyle(
                color: Colors.green.shade900,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
