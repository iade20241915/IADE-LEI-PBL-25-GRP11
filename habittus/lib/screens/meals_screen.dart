import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/meal_controller.dart';
import '../repositories/supabase/supabase_meal_repository.dart';
import '../widgets/habittus_app_bar.dart';
import '../widgets/habittus_drawer.dart';
import '../widgets/habittus_card.dart';
import '../widgets/weeklybarschart.dart';
import '../widgets/date_pills.dart';
import '../widgets/habittus_icons.dart';
import '../widgets/save_status_banner.dart';
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
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<MealController>().load(d);
  }

  String get monthName => const [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ][d.month - 1];

  void _setDate(DateTime nd) {
    setState(() => d = DateTime(nd.year, nd.month, nd.day));
    _loadData();
  }

  // Helper para obter o último dia de um mês
  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  // Helper para criar data validada (ajusta dia se necessário)
  DateTime _safeDate(int year, int month, int day) {
    while (month < 1) {
      month += 12;
      year--;
    }
    while (month > 12) {
      month -= 12;
      year++;
    }
    final maxDay = _daysInMonth(year, month);
    final safeDay = day > maxDay ? maxDay : day;
    return DateTime(year, month, safeDay);
  }

  Future<void> _openAddMeal({MealEntry? mealToEdit}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddMealScreen(
          date: d,
          mealToEdit: mealToEdit,
        ),
      ),
    );
    
    if (result == true && mounted) {
      _loadData();
    }
  }

  Future<void> _deleteMeal(MealEntry meal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFE4EAD8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Apagar refeição?'),
        content: Text('Tens a certeza que queres apagar "${meal.mealType ?? 'esta refeição'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted && meal.id != null) {
      await context.read<MealController>().deleteMeal(meal.id!);
    }
  }

  IconData _getMealIcon(String? mealType) {
    switch (mealType?.toLowerCase()) {
      case 'pequeno-almoço':
      case 'breakfast':
        return HabittusIcons.breakfast;
      case 'almoço':
      case 'lunch':
        return HabittusIcons.lunch;
      case 'lanche':
      case 'snack':
        return HabittusIcons.snack;
      case 'jantar':
      case 'dinner':
        return HabittusIcons.dinner;
      default:
        return HabittusIcons.meal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MealController>();
    final meals = controller.meals;
    final totalKcal = controller.todayCalories;

    return Scaffold(
      drawer: const HabittusDrawer(),
      appBar: const HabittusAppBar(showBack: true),
      backgroundColor: const Color(0xFFF6F8F0),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddMeal(),
        backgroundColor: const Color(0xFF2F5D2F),
        child: const Icon(HabittusIcons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async => _loadData(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Save Status Banner
                    SaveStatusBanner(
                      isVisible: controller.saveStatus != MealSaveStatus.idle,
                      isSaving: controller.saveStatus == MealSaveStatus.saving,
                      isSuccess: controller.saveStatus == MealSaveStatus.saved,
                      isError: controller.saveStatus == MealSaveStatus.error,
                      errorMessage: controller.errorMessage,
                    ),

                    DatePills(
                      day: '${d.day}',
                      month: monthName,
                      year: '${d.year}',
                      onDayPrev: () => _setDate(d.subtract(const Duration(days: 1))),
                      onDayNext: () => _setDate(d.add(const Duration(days: 1))),
                      onMonthPrev: () => _setDate(_safeDate(d.year, d.month - 1, d.day)),
                      onMonthNext: () => _setDate(_safeDate(d.year, d.month + 1, d.day)),
                      onYearPrev: () => _setDate(_safeDate(d.year - 1, d.month, d.day)),
                      onYearNext: () => _setDate(_safeDate(d.year + 1, d.month, d.day)),
                    ),

                    const SizedBox(height: 16),

                    // Resumo da refeição
                    HabittusCard(
                      title: 'Resumo da refeição',
                      subtitle: 'Total: ${totalKcal}kcal',
                      child: meals.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(20),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      HabittusIcons.meal,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Nenhuma refeição registada',
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton.icon(
                                      onPressed: () => _openAddMeal(),
                                      icon: const Icon(HabittusIcons.add),
                                      label: const Text('Adicionar refeição'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Column(
                              children: meals.map((meal) {
                                return _MealTile(
                                  title: meal.mealType ?? 'Refeição',
                                  kcal: meal.totalKcal,
                                  icon: _getMealIcon(meal.mealType),
                                  itemsCount: meal.items.length,
                                  onTap: () => _openAddMeal(mealToEdit: meal),
                                  onDelete: () => _deleteMeal(meal),
                                );
                              }).toList(),
                            ),
                    ),

                    const SizedBox(height: 14),

                    // Histórico Calorias
                    HabittusCard(
                      title: 'Histórico Calorias',
                      subtitle: 'Últimos 7 dias',
                      child: WeeklyBarsChart(
                        values: controller.weeklyChartValues,
                        labels: controller.weeklyLabels,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _MealTile extends StatelessWidget {
  final String title;
  final int kcal;
  final IconData icon;
  final int itemsCount;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MealTile({
    required this.title,
    required this.kcal,
    required this.icon,
    required this.itemsCount,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE4EAD8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: HabittusIcons.foodColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: HabittusIcons.foodColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '$itemsCount itens',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: HabittusIcons.foodColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${kcal}kcal',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: HabittusIcons.foodColor,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: Icon(HabittusIcons.more, color: Colors.grey.shade600),
              onSelected: (value) {
                if (value == 'edit') {
                  onTap();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Apagar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
