import 'package:flutter/material.dart';
import '../models/food_item.dart'; // Import correto do FoodItem

/// Dialog para exibir e editar os detalhes nutricionais de um alimento
/// Pode ser usado tanto no AddMealScreen quanto no MealsScreen
class FoodDetailDialog extends StatefulWidget {
  final FoodItem food;

  const FoodDetailDialog({super.key, required this.food});

  @override
  State<FoodDetailDialog> createState() => _FoodDetailDialogState();
}

class _FoodDetailDialogState extends State<FoodDetailDialog> {
  late TextEditingController kcal;
  late TextEditingController protein;
  late TextEditingController carbs;
  late TextEditingController fat;

  @override
  void initState() {
    super.initState();
    kcal = TextEditingController(
      text: widget.food.kcalPer100g.toStringAsFixed(1),
    );
    protein = TextEditingController(
      text: widget.food.proteinPer100g.toStringAsFixed(1),
    );
    carbs = TextEditingController(
      text: widget.food.carbsPer100g.toStringAsFixed(1),
    );
    fat = TextEditingController(
      text: widget.food.fatPer100g.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    kcal.dispose();
    protein.dispose();
    carbs.dispose();
    fat.dispose();
    super.dispose();
  }

  double _parse(TextEditingController c) {
    final raw = c.text.replaceAll(',', '.').trim();
    return double.tryParse(raw) ?? 0;
  }

  void _saveChanges() {
    final updatedFood = widget.food.copyWith(
      kcalPer100g: _parse(kcal),
      carbsPer100g: _parse(carbs),
      proteinPer100g: _parse(protein),
      fatPer100g: _parse(fat),
    );
    Navigator.of(context).pop(updatedFood);
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
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.food.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Detalhes do alimento',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Campos nutricionais
            _KeyValueField(label: 'kcal por 100 g', controller: kcal),
            _KeyValueField(label: 'Proteína por 100 g', controller: protein),
            _KeyValueField(label: 'Hidratos por 100 g', controller: carbs),
            _KeyValueField(label: 'Gordura por 100 g', controller: fat),
            const SizedBox(height: 10),

            // Botões de ação
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F5D2F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Guardar',
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

/// Widget interno para campo chave-valor (label + input)
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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '0.0',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
