import 'package:flutter/material.dart';

import '../models/physical_activity.dart';
import '../widgets/habittus_app_bar.dart';
import '../widgets/habittus_card.dart';
import '../widgets/primary_button.dart';

class AddActivityScreen extends StatefulWidget {
  final DateTime date;
  final PhysicalActivity? activityToEdit;

  const AddActivityScreen({super.key, required this.date, this.activityToEdit});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  late ActivityType selectedType;
  late ActivityIntensity selectedIntensity;
  late TimeOfDay selectedTime;

  final durationController = TextEditingController();
  final distanceController = TextEditingController();
  final caloriesController = TextEditingController();
  final notesController = TextEditingController();

  bool get isEditing => widget.activityToEdit != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final activity = widget.activityToEdit!;
      selectedType = activity.activityType;
      selectedIntensity = activity.intensity;
      selectedTime = TimeOfDay.fromDateTime(activity.timestamp);
      durationController.text = activity.durationMinutes.toString();
      distanceController.text = activity.distanceKm?.toString() ?? '';
      caloriesController.text = activity.caloriesBurned?.toString() ?? '';
      notesController.text = activity.notes ?? '';
    } else {
      selectedType = ActivityType.running;
      selectedIntensity = ActivityIntensity.moderate;
      selectedTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    durationController.dispose();
    distanceController.dispose();
    caloriesController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2F5D2F),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _save() {
    // Validação básica
    final duration = int.tryParse(durationController.text);
    if (duration == null || duration <= 0) {
      _showError('Por favor, insira uma duração válida');
      return;
    }

    final distance = distanceController.text.isNotEmpty
        ? double.tryParse(distanceController.text.replaceAll(',', '.'))
        : null;

    final calories = caloriesController.text.isNotEmpty
        ? int.tryParse(caloriesController.text)
        : null;

    // Cria timestamp com data e hora selecionadas
    final timestamp = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final activity = PhysicalActivity(
      id: isEditing
          ? widget.activityToEdit!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'mock_user_123', // TODO: Pegar do auth
      timestamp: timestamp,
      activityType: selectedType,
      durationMinutes: duration,
      intensity: selectedIntensity,
      distanceKm: distance,
      caloriesBurned: calories,
      notes: notesController.text.isEmpty ? null : notesController.text,
    );

    Navigator.pop(context, activity);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HabittusAppBar(showBack: true),
      backgroundColor: const Color(0xFFF6F8F0),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Título
            Text(
              isEditing ? 'Editar Atividade' : 'Nova Atividade',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.date.day}/${widget.date.month}/${widget.date.year}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const SizedBox(height: 20),

            // Seletor de tipo de atividade
            HabittusCard(
              title: 'Tipo de atividade',
              subtitle: 'Selecione o tipo',
              child: Column(
                children: [
                  _ActivityTypeSelector(
                    selectedType: selectedType,
                    onSelect: (type) => setState(() => selectedType = type),
                  ),
                  const SizedBox(height: 12),

                  // Popup para ver todos os tipos
                  InkWell(
                    onTap: () async {
                      final selected = await showDialog<ActivityType>(
                        context: context,
                        builder: (context) =>
                            _ActivityTypeDialog(selectedType: selectedType),
                      );
                      if (selected != null) {
                        setState(() => selectedType = selected);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4EAD8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Ver todas as atividades',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Detalhes da atividade
            HabittusCard(
              title: 'Detalhes',
              subtitle: 'Informações da atividade',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hora
                  _InfoField(
                    label: 'Hora',
                    icon: Icons.access_time,
                    child: InkWell(
                      onTap: _selectTime,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F8F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Duração
                  _InfoField(
                    label: 'Duração (minutos) *',
                    icon: Icons.timer,
                    child: TextField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Ex: 30',
                        filled: true,
                        fillColor: const Color(0xFFF6F8F0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Intensidade
                  _InfoField(
                    label: 'Intensidade',
                    icon: Icons.speed,
                    child: Row(
                      children: ActivityIntensity.values.map((intensity) {
                        final isSelected = selectedIntensity == intensity;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () => setState(() {
                                selectedIntensity = intensity;
                              }),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF2F5D2F)
                                      : const Color(0xFFF6F8F0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      intensity.emoji,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      intensity.label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Distância (opcional)
                  _InfoField(
                    label: 'Distância (km) - opcional',
                    icon: Icons.straighten,
                    child: TextField(
                      controller: distanceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ex: 5.2',
                        filled: true,
                        fillColor: const Color(0xFFF6F8F0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Calorias (opcional)
                  _InfoField(
                    label: 'Calorias - opcional',
                    icon: Icons.local_fire_department,
                    child: TextField(
                      controller: caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Ex: 320',
                        filled: true,
                        fillColor: const Color(0xFFF6F8F0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Notas (opcional)
                  _InfoField(
                    label: 'Notas - opcional',
                    icon: Icons.notes,
                    child: TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Adicione observações sobre a atividade',
                        filled: true,
                        fillColor: const Color(0xFFF6F8F0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Botão salvar
            PrimaryButton(
              text: isEditing ? 'Atualizar' : 'Adicionar',
              onPressed: _save,
            ),

            if (isEditing) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Widget para campo de informação com label e ícone
class _InfoField extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget child;

  const _InfoField({
    required this.label,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF244A24)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

/// Seletor visual de tipos de atividade (primeiros 6)
class _ActivityTypeSelector extends StatelessWidget {
  final ActivityType selectedType;
  final Function(ActivityType) onSelect;

  const _ActivityTypeSelector({
    required this.selectedType,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    // Mostra os 6 tipos mais comuns
    final commonTypes = [
      ActivityType.running,
      ActivityType.walking,
      ActivityType.cycling,
      ActivityType.gym,
      ActivityType.swimming,
      ActivityType.yoga,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: commonTypes.map((type) {
        final isSelected = selectedType == type;
        return InkWell(
          onTap: () => onSelect(type),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: (MediaQuery.of(context).size.width - 80) / 3,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF2F5D2F)
                  : const Color(0xFFE4EAD8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(type.icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
                Text(
                  type.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Dialog para selecionar tipo de atividade (todos os tipos)
class _ActivityTypeDialog extends StatelessWidget {
  final ActivityType selectedType;

  const _ActivityTypeDialog({required this.selectedType});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE4EAD8),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Selecionar atividade',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: ActivityType.values.map((type) {
                  final isSelected = selectedType == type;
                  return InkWell(
                    onTap: () => Navigator.pop(context, type),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2F5D2F)
                            : const Color(0xFFF6F8F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(type.icon, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              type.label,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Colors.white),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
