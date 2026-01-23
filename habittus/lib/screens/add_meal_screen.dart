import 'package:flutter/material.dart';

import '../widgets/habittus_app_bar.dart';
import '../widgets/habittus_drawer.dart';
import '../widgets/habittus_card.dart';
import '../widgets/date_pills.dart';
import '../widgets/food_detail_dialog.dart';

enum MealType { breakfast, lunch, snack, dinner }

extension MealTypeX on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'P. Almoço';
      case MealType.lunch:
        return 'Almoço';
      case MealType.snack:
        return 'Lanche';
      case MealType.dinner:
        return 'Jantar';
    }
  }

  IconData get icon {
    switch (this) {
      case MealType.breakfast:
        return Icons.free_breakfast_outlined;
      case MealType.lunch:
        return Icons.lunch_dining_outlined;
      case MealType.snack:
        return Icons.cookie_outlined;
      case MealType.dinner:
        return Icons.restaurant_outlined;
    }
  }
}

class FoodItem {
  final String id;
  final String name;
  double kcalPer100g;
  double carbsPer100g;
  double proteinPer100g;
  double fatPer100g;

  FoodItem({
    required this.id,
    required this.name,
    required this.kcalPer100g,
    required this.carbsPer100g,
    required this.proteinPer100g,
    required this.fatPer100g,
  });
}

class SelectedFood {
  final FoodItem food;
  double grams;
  MealType mealType;

  SelectedFood({
    required this.food,
    required this.grams,
    required this.mealType,
  });

  double get kcal => (food.kcalPer100g * grams) / 100.0;
}

class AddMealScreen extends StatefulWidget {
  final DateTime date;

  const AddMealScreen({super.key, required this.date});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  late DateTime d;

  final TextEditingController searchCtrl = TextEditingController();
  final TextEditingController gramsCtrl = TextEditingController();

  MealType selectedMealType = MealType.lunch;

  // Mock “catálogo” (depois ligas ao Supabase)
  final List<FoodItem> catalog = [
    FoodItem(
      id: '1',
      name: 'Arroz',
      kcalPer100g: 130,
      carbsPer100g: 28,
      proteinPer100g: 2.7,
      fatPer100g: 0.3,
    ),
    FoodItem(
      id: '2',
      name: 'Massa',
      kcalPer100g: 158,
      carbsPer100g: 31,
      proteinPer100g: 5.8,
      fatPer100g: 0.9,
    ),
    FoodItem(
      id: '3',
      name: 'Iogurte',
      kcalPer100g: 60,
      carbsPer100g: 7,
      proteinPer100g: 3.5,
      fatPer100g: 1.8,
    ),
    FoodItem(
      id: '4',
      name: 'Salada',
      kcalPer100g: 35,
      carbsPer100g: 4,
      proteinPer100g: 1.5,
      fatPer100g: 0.3,
    ),
    FoodItem(
      id: '5',
      name: 'Bife',
      kcalPer100g: 250,
      carbsPer100g: 0,
      proteinPer100g: 26,
      fatPer100g: 15,
    ),
  ];

  final List<SelectedFood> selected = [];

  @override
  void initState() {
    super.initState();
    d = DateTime(widget.date.year, widget.date.month, widget.date.day);
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    gramsCtrl.dispose();
    super.dispose();
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

  String _timeNow() {
    final t = TimeOfDay.now();
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  void _clearForm() {
    searchCtrl.clear();
    gramsCtrl.clear();
    setState(() {});
  }

  double _parseGrams() {
    final raw = gramsCtrl.text.replaceAll(',', '.').trim();
    final g = double.tryParse(raw);
    return (g == null || g <= 0) ? 0 : g;
  }

  Future<void> _openFoodDetails(FoodItem food) async {
    final updated = await showDialog<FoodItem>(
      context: context,
      builder: (_) => FoodDetailDialog(food: food),
    );

    if (updated != null) {
      final idx = catalog.indexWhere((x) => x.id == updated.id);
      if (idx >= 0) setState(() => catalog[idx] = updated);
    }
  }

  Future<void> _openRegisterNewFood() async {
    final created = await showDialog<FoodItem>(
      context: context,
      builder: (_) => const _RegisterFoodDialog(),
    );

    if (created != null) {
      setState(() => catalog.insert(0, created));
    }
  }

  void _addSelectedByName(String name) {
    final grams = _parseGrams();
    if (grams <= 0) return;

    final nm = name.trim();
    if (nm.isEmpty) return;

    final food = catalog.firstWhere(
      (f) => f.name.toLowerCase() == nm.toLowerCase(),
      orElse: () => FoodItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nm,
        kcalPer100g: 100,
        carbsPer100g: 0,
        proteinPer100g: 0,
        fatPer100g: 0,
      ),
    );

    setState(() {
      selected.add(
        SelectedFood(food: food, grams: grams, mealType: selectedMealType),
      );
      gramsCtrl.clear();
    });
  }

  double get totalKcal => selected.fold(0, (sum, x) => sum + x.kcal);

  Future<void> _openEditEntries() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditEntriesSheet(
        entries: selected,
        onRemove: (i) => setState(() => selected.removeAt(i)),
        onClear: () => setState(() => selected.clear()),
        onOk: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _continue() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HabittusDrawer(userName: 'USER_NAME'),
      appBar: const HabittusAppBar(showBack: true),
      backgroundColor: const Color(0xFFF6F8F0),
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
              title: 'Adicionar refeição',
              subtitle: 'O que comeste? Procura na lista.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert),
                    ),
                  ),

                  const Text(
                    'Procurar alimento...',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),

                  _FoodAutocompletePill(
                    controller: searchCtrl,
                    items: catalog,
                    hint: 'Procure um alimento',
                    onSelected: (food) async {
                      searchCtrl.text = food.name;
                      setState(() {});
                      await _openFoodDetails(food);
                    },
                    onRegisterNew: _openRegisterNewFood,
                  ),

                  const SizedBox(height: 12),

                  _MealTypeRow(
                    selected: selectedMealType,
                    onSelect: (t) => setState(() => selectedMealType = t),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'Peso em gramas',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),

                  _InputPill(
                    controller: gramsCtrl,
                    hint: 'peso em gramas',
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      TextButton(
                        onPressed: _clearForm,
                        child: const Text('Clear'),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _addSelectedByName(searchCtrl.text),
                        child: const Text(
                          'Adicionar',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            HabittusCard(
              title: 'Resumo da refeição',
              subtitle: 'Confirma os alimentos adicionados.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: selected.isEmpty ? null : _openEditEntries,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ),

                  if (selected.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Ainda não adicionaste alimentos.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  else
                    ...List.generate(selected.length, (i) {
                      final e = selected[i];
                      return _SelectedTile(
                        title: e.food.name,
                        kcal: e.kcal,
                        onRemove: () => setState(() => selected.removeAt(i)),
                      );
                    }),

                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${totalKcal.toStringAsFixed(0)}kcal',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Center(
              child: SizedBox(
                width: 180,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE4EAD8),
                    foregroundColor: const Color(0xFF244A24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* =====================
   Dropdown pesquisável
   ===================== */

class _FoodAutocompletePill extends StatelessWidget {
  final TextEditingController controller;
  final List<FoodItem> items;
  final String hint;
  final ValueChanged<FoodItem> onSelected;
  final VoidCallback onRegisterNew;

  const _FoodAutocompletePill({
    required this.controller,
    required this.items,
    required this.hint,
    required this.onSelected,
    required this.onRegisterNew,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<FoodItem>(
      displayStringForOption: (f) => f.name,
      optionsBuilder: (TextEditingValue text) {
        final q = text.text.trim().toLowerCase();
        if (q.isEmpty) return const Iterable<FoodItem>.empty();
        return items.where((f) => f.name.toLowerCase().contains(q));
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, textCtrl, focusNode, onFieldSubmitted) {
        if (textCtrl.text != controller.text) {
          textCtrl.text = controller.text;
          textCtrl.selection = TextSelection.fromPosition(
            TextPosition(offset: textCtrl.text.length),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8F0),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFF2F5D2F), width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textCtrl,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                  ),
                  onChanged: (v) => controller.text = v,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () {
                  controller.clear();
                  textCtrl.clear();
                  focusNode.requestFocus();
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE4EAD8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16),
                ),
              ),
            ],
          ),
        );
      },
      optionsViewBuilder: (context, onSelectedOpt, options) {
        final opts = options.toList();

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10,
                    offset: Offset(0, 6),
                    color: Colors.black26,
                  ),
                ],
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: opts.length + 1,
                  itemBuilder: (context, i) {
                    if (i == opts.length) {
                      return ListTile(
                        leading: const Icon(Icons.add_circle_outline),
                        title: const Text('Registar novo alimento'),
                        onTap: onRegisterNew,
                      );
                    }
                    final opt = opts[i];
                    return ListTile(
                      title: Text(opt.name),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => onSelectedOpt(opt),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/* =====================
   Bottom sheet: editar
   ===================== */

class _EditEntriesSheet extends StatelessWidget {
  final List<SelectedFood> entries;
  final ValueChanged<int> onRemove;
  final VoidCallback onClear;
  final VoidCallback onOk;

  const _EditEntriesSheet({
    required this.entries,
    required this.onRemove,
    required this.onClear,
    required this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'Editar entradas',
      subtitle: 'Confirma os alimentos adicionados.',
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, i) {
                final e = entries[i];
                return _SelectedTile(
                  title: e.food.name,
                  kcal: e.kcal,
                  onRemove: () => onRemove(i),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(onPressed: onClear, child: const Text('Clear')),
              const Spacer(),
              TextButton(
                onPressed: onOk,
                child: const Text(
                  'OK',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* =====================
   Dialog: registar novo
   ===================== */

class _RegisterFoodDialog extends StatefulWidget {
  const _RegisterFoodDialog();

  @override
  State<_RegisterFoodDialog> createState() => _RegisterFoodDialogState();
}

class _RegisterFoodDialogState extends State<_RegisterFoodDialog> {
  final name = TextEditingController();
  final carbs = TextEditingController();
  final protein = TextEditingController();
  final fat = TextEditingController();
  final kcal = TextEditingController();

  @override
  void dispose() {
    name.dispose();
    carbs.dispose();
    protein.dispose();
    fat.dispose();
    kcal.dispose();
    super.dispose();
  }

  double _parse(TextEditingController c) {
    final raw = c.text.replaceAll(',', '.').trim();
    return double.tryParse(raw) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFE4EAD8),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Registar novo alimento',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _LabeledPillField(label: 'Nome do alimento', controller: name),
            _LabeledPillField(
              label: 'Carboidratos em gramas',
              controller: carbs,
            ),
            _LabeledPillField(label: 'Proteína em gramas', controller: protein),
            _LabeledPillField(
              label: 'Gorduras Saturadas em gramas',
              controller: fat,
            ),
            _LabeledPillField(label: 'kcal por 100 g', controller: kcal),
            const SizedBox(height: 10),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Clear'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    final nm = name.text.trim();
                    if (nm.isEmpty) return;
                    Navigator.of(context).pop(
                      FoodItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nm,
                        kcalPer100g: _parse(kcal),
                        carbsPer100g: _parse(carbs),
                        proteinPer100g: _parse(protein),
                        fatPer100g: _parse(fat),
                      ),
                    );
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(fontWeight: FontWeight.w900),
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

/* =========================
   Shared UI building blocks
   ========================= */

class _SheetShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SheetShell({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, controller) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: Color(0xFFE4EAD8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: const TextStyle(color: Colors.black54)),
              ],
              const SizedBox(height: 12),
              Expanded(
                child: PrimaryScrollController(
                  controller: controller,
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LabeledPillField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _LabeledPillField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          _InputPill(controller: controller, hint: 'Escreva aqui'),
        ],
      ),
    );
  }
}

class _KeyValueField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _KeyValueField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            width: 90,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputPill extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;

  const _InputPill({
    required this.controller,
    required this.hint,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F0),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF2F5D2F), width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              keyboardType: keyboardType,
              onTap: onTap,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: controller.text.isEmpty ? null : () => controller.clear(),
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFE4EAD8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealTypeRow extends StatelessWidget {
  final MealType selected;
  final ValueChanged<MealType> onSelect;

  const _MealTypeRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final items = MealType.values;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((t) {
        final isSelected = selected == t;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onSelect(t),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2F5D2F)
                          : const Color(0xFFE4EAD8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      t.icon,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF244A24),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SelectedTile extends StatelessWidget {
  final String title;
  final double kcal;
  final VoidCallback onRemove;

  const _SelectedTile({
    required this.title,
    required this.kcal,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE4EAD8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.restaurant_outlined, color: Color(0xFF244A24)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            '${kcal.toStringAsFixed(0)}kcal',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFDDE6D3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.remove, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
