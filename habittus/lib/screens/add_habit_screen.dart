import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../widgets/habittus_app_bar.dart';
import '../widgets/primary_button.dart';

class AddHabitScreen extends StatefulWidget {
  final HabitType type;
  final Habit? habitToEdit;

  const AddHabitScreen({super.key, required this.type, this.habitToEdit});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  late HabitCategory selectedCategory;

  bool get isEditing => widget.habitToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final habit = widget.habitToEdit!;
      nameController.text = habit.name;
      descriptionController.text = habit.description ?? '';
      selectedCategory = habit.category;
    } else {
      selectedCategory = widget.type == HabitType.negative
          ? HabitCategory.smoking
          : HabitCategory.reading;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira um nome')),
      );
      return;
    }

    final habit = Habit(
      id: isEditing
          ? widget.habitToEdit!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'mock_user_123',
      name: nameController.text.trim(),
      type: widget.type,
      category: selectedCategory,
      description: descriptionController.text.isEmpty
          ? null
          : descriptionController.text,
      emoji: selectedCategory.emoji,
      createdAt: isEditing ? widget.habitToEdit!.createdAt : DateTime.now(),
    );

    Navigator.pop(context, habit);
  }

  @override
  Widget build(BuildContext context) {
    final categories = HabitCategory.values
        .where(
          (c) =>
              widget.type == HabitType.negative ? c.isNegative : !c.isNegative,
        )
        .toList();

    return Scaffold(
      appBar: const HabittusAppBar(showBack: true),
      backgroundColor: const Color(0xFFF6F8F0),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              isEditing ? 'Editar Hábito' : 'Novo Hábito',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nome do hábito',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Descrição (opcional)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Categoria:',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                final isSelected = selectedCategory == cat;
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedCategory = cat;
                      nameController.text =
                          cat.label; // Preenche automaticamente
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2F5D2F)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cat.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          cat.label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            PrimaryButton(
              text: isEditing ? 'Atualizar' : 'Adicionar',
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
