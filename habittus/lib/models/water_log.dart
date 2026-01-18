class WaterLog {
  final DateTime date;
  final int mlPerCup;
  final int cups;

  const WaterLog({
    required this.date,
    required this.mlPerCup,
    required this.cups,
  });

  int get totalMl => mlPerCup * cups;
}
