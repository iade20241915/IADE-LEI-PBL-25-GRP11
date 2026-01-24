import 'package:flutter/material.dart';

import '../models/physical_activity.dart';
import '../services/location_service.dart';
import '../widgets/habittus_app_bar.dart';
import '../widgets/habittus_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/habittus_icons.dart';

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

  // Estado do GPS
  bool _isCapturingGps = false;
  bool _activityStarted = false;
  GpsTrackPoint? _startLocation;
  GpsTrackPoint? _endLocation;
  DateTime? _activityStartTime;
  final LocationService _locationService = LocationService.instance;

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
      _startLocation = activity.startLocation;
      _endLocation = activity.endLocation;
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

  /// Inicia a atividade e captura localização GPS inicial
  Future<void> _startActivity() async {
    if (!selectedType.requiresGps) {
      setState(() {
        _activityStarted = true;
        _activityStartTime = DateTime.now();
      });
      return;
    }

    setState(() => _isCapturingGps = true);

    try {
      final coordinate = await _locationService.getCurrentLocation();
      
      if (coordinate != null) {
        setState(() {
          _startLocation = GpsTrackPoint(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            altitude: coordinate.altitude,
            sequence: 1,
          );
          _activityStarted = true;
          _activityStartTime = DateTime.now();
          _isCapturingGps = false;
        });
        _showSuccess('Atividade iniciada! Localização capturada.');
      } else {
        setState(() => _isCapturingGps = false);
        _showGpsError();
      }
    } catch (e) {
      setState(() => _isCapturingGps = false);
      _showGpsError();
    }
  }

  /// Termina a atividade e captura localização GPS final
  Future<void> _endActivity() async {
    if (!selectedType.requiresGps) {
      _calculateDurationFromStartTime();
      return;
    }

    setState(() => _isCapturingGps = true);

    try {
      final coordinate = await _locationService.getCurrentLocation();
      
      if (coordinate != null) {
        setState(() {
          _endLocation = GpsTrackPoint(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            altitude: coordinate.altitude,
            sequence: 2,
          );
          _isCapturingGps = false;
        });

        // Calcular duração automaticamente
        _calculateDurationFromStartTime();

        // Calcular distância se tiver ambos os pontos
        if (_startLocation != null) {
          final distance = _locationService.calculateDistanceKm(
            GpsCoordinate(
              latitude: _startLocation!.latitude,
              longitude: _startLocation!.longitude,
            ),
            GpsCoordinate(
              latitude: _endLocation!.latitude,
              longitude: _endLocation!.longitude,
            ),
          );
          distanceController.text = distance.toStringAsFixed(2);
        }

        _showSuccess('Atividade terminada! Localização capturada.');
      } else {
        setState(() => _isCapturingGps = false);
        _showGpsError();
      }
    } catch (e) {
      setState(() => _isCapturingGps = false);
      _showGpsError();
    }
  }

  void _calculateDurationFromStartTime() {
    if (_activityStartTime != null) {
      final duration = DateTime.now().difference(_activityStartTime!);
      durationController.text = duration.inMinutes.toString();
    }
  }

  void _showGpsError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('GPS Indisponível'),
        content: const Text(
          'Não foi possível obter a localização. Verifique se o GPS está ativo e se concedeu permissões de localização.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2F5D2F),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
      startLocation: _startLocation,
      endLocation: _endLocation,
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
    final showGpsControls = selectedType.requiresGps && !isEditing;

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

            // Controles GPS para atividades com tracking
            if (showGpsControls) ...[
              _GpsTrackingCard(
                activityType: selectedType,
                isCapturing: _isCapturingGps,
                activityStarted: _activityStarted,
                startLocation: _startLocation,
                endLocation: _endLocation,
                onStartActivity: _startActivity,
                onEndActivity: _endActivity,
              ),
              const SizedBox(height: 14),
            ],

            // Seletor de tipo de atividade
            HabittusCard(
              title: 'Tipo de atividade',
              subtitle: 'Selecione o tipo',
              child: Column(
                children: [
                  _ActivityTypeSelector(
                    selectedType: selectedType,
                    onSelect: (type) => setState(() {
                      selectedType = type;
                      // Reset GPS data quando muda de tipo
                      if (!type.requiresGps) {
                        _startLocation = null;
                        _endLocation = null;
                      }
                    }),
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
                        setState(() {
                          selectedType = selected;
                          if (!selected.requiresGps) {
                            _startLocation = null;
                            _endLocation = null;
                          }
                        });
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
                          Icon(HabittusIcons.activity, size: 18),
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
                    icon: HabittusIcons.time,
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
                            const Icon(HabittusIcons.chevronRight),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Duração
                  _InfoField(
                    label: 'Duração (minutos)',
                    icon: HabittusIcons.time,
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
                    icon: HabittusIcons.activity,
                    child: Row(
                      children: ActivityIntensity.values.map((intensity) {
                        final isSelected = selectedIntensity == intensity;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: intensity != ActivityIntensity.high ? 8 : 0,
                            ),
                            child: InkWell(
                              onTap: () =>
                                  setState(() => selectedIntensity = intensity),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
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
                                    const SizedBox(height: 2),
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
                    icon: HabittusIcons.location,
                    child: TextField(
                      controller: distanceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'Ex: 5.5',
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
                    label: 'Calorias queimadas - opcional',
                    icon: HabittusIcons.fire,
                    child: TextField(
                      controller: caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Ex: 250',
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
                    icon: HabittusIcons.notes,
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
              text: isEditing ? 'Atualizar' : 'Guardar Atividade',
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

/// Card para controles de tracking GPS
class _GpsTrackingCard extends StatelessWidget {
  final ActivityType activityType;
  final bool isCapturing;
  final bool activityStarted;
  final GpsTrackPoint? startLocation;
  final GpsTrackPoint? endLocation;
  final VoidCallback onStartActivity;
  final VoidCallback onEndActivity;

  const _GpsTrackingCard({
    required this.activityType,
    required this.isCapturing,
    required this.activityStarted,
    this.startLocation,
    this.endLocation,
    required this.onStartActivity,
    required this.onEndActivity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2F5D2F).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2F5D2F).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2F5D2F),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  HabittusIcons.location,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tracking GPS - ${activityType.label}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const Text(
                      'Captura localização no início e fim',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status das localizações
          Row(
            children: [
              _GpsStatusChip(
                label: 'Início',
                captured: startLocation != null,
              ),
              const SizedBox(width: 8),
              _GpsStatusChip(
                label: 'Fim',
                captured: endLocation != null,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Botões de controle
          if (isCapturing)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Color(0xFF2F5D2F)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'A obter localização...',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            )
          else if (!activityStarted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onStartActivity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F5D2F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  'Iniciar Atividade',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            )
          else if (endLocation == null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onEndActivity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.stop),
                label: const Text(
                  'Terminar Atividade',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2F5D2F).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF2F5D2F)),
                  SizedBox(width: 8),
                  Text(
                    'Tracking completo!',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2F5D2F),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Chip de status GPS
class _GpsStatusChip extends StatelessWidget {
  final String label;
  final bool captured;

  const _GpsStatusChip({
    required this.label,
    required this.captured,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: captured ? const Color(0xFF2F5D2F) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            captured ? Icons.check : Icons.circle_outlined,
            size: 16,
            color: captured ? Colors.white : Colors.black54,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: captured ? Colors.white : Colors.black54,
            ),
          ),
        ],
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
                if (type.requiresGps) ...[
                  const SizedBox(height: 2),
                  Icon(
                    HabittusIcons.location,
                    size: 12,
                    color: isSelected ? Colors.white70 : Colors.black38,
                  ),
                ],
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
                  icon: const Icon(HabittusIcons.close),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  type.label,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                if (type.requiresGps)
                                  Text(
                                    'Com GPS',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isSelected
                                          ? Colors.white70
                                          : Colors.black38,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(HabittusIcons.check, color: Colors.white),
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
