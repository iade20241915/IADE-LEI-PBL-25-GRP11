import 'package:flutter/material.dart';

import '../widgets/habittus_app_bar.dart';
import '../widgets/habittus_drawer.dart';
import '../widgets/habittus_card.dart';
import '../widgets/weeklybarschart.dart';
import '../widgets/date_pills.dart';
import '../widgets/food_detail_dialog.dart';
import 'add_meal_screen.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  late DateTime d;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    d = DateTime(now.year, now.month, now.day);
  }

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

  void _setDate(DateTime nd) {
    setState(() => d = DateTime(nd.year, nd.month, nd.day));
  }

  String _timeNow() {
    final t = TimeOfDay.now();
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<void> _openAddMeal() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => AddMealScreen(date: d)));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Mock (mantém a tua versão)
    final meals = const [
      _MealRow('Arroz', 500, Icons.rice_bowl_outlined),
      _MealRow('Massa', 400, Icons.ramen_dining_outlined),
      _MealRow('Salada', 350, Icons.eco_outlined),
      _MealRow('Bacalhau à brás', 400, Icons.set_meal_outlined),
    ];

    // 0..1 (mock)
    const weeklyValues = [0.95, 0.75, 0.85, 0.9, 0.8, 0.88, 0.92];
    const weekLabels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

    return Scaffold(
      drawer: const HabittusDrawer(userName: 'USER_NAME'),
      appBar: const HabittusAppBar(showBack: true),
      backgroundColor: const Color(0xFFF6F8F0),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddMeal,
        backgroundColor: const Color(0xFF2F5D2F),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
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

            HabittusCard(
              title: 'Resumo da refeição',
              subtitle: 'Registo calórico',
              child: Column(
                children: meals
                    .map(
                      (m) => _MealTile(
                        title: m.title,
                        kcal: m.kcal,
                        icon: m.icon,
                        onTap: () async {
                          // Criar FoodItem mock com os dados da refeição
                          final foodItem = FoodItem(
                            id: m.title.hashCode.toString(),
                            name: m.title,
                            kcalPer100g: m.kcal.toDouble(),
                            carbsPer100g: 25.0,
                            proteinPer100g: 5.0,
                            fatPer100g: 3.0,
                          );

                          final updated = await showDialog<FoodItem>(
                            context: context,
                            builder: (_) => FoodDetailDialog(food: foodItem),
                          );

                          if (updated != null) {
                            // Salvar alterações no Supabase
                            // TODO: Implementar quando tiver repositório
                            // await mealRepository.updateFood(updated);
                            setState(() {});
                          }
                        },
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 14),

            HabittusCard(
              title: 'Histórico Calorias',
              subtitle: 'Últimos 7 dias',
              child: WeeklyBarsChart(values: weeklyValues, labels: weekLabels),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===== UI blocks do MealsScreen ===== */

class _SmallPill extends StatelessWidget {
  final String text;
  const _SmallPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _MealTile extends StatelessWidget {
  final String title;
  final int kcal;
  final IconData icon;
  final VoidCallback onTap;

  const _MealTile({
    required this.title,
    required this.kcal,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE4EAD8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF244A24)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              '${kcal}kcal',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _MealRow {
  final String title;
  final int kcal;
  final IconData icon;
  const _MealRow(this.title, this.kcal, this.icon);
}
