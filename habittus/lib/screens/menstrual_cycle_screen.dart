import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../controllers/cycle_controller.dart';
import '../models/cycle_entry.dart';
import '../widgets/habittus_app_bar.dart';
import '../widgets/habittus_drawer.dart';
import '../widgets/habittus_card.dart';
import '../widgets/date_pills.dart';
import '../widgets/primary_button.dart';
import '../widgets/habittus_icons.dart';

class MenstrualCycleScreen extends StatefulWidget {
  const MenstrualCycleScreen({super.key});

  @override
  State<MenstrualCycleScreen> createState() => _MenstrualCycleScreenState();
}

class _MenstrualCycleScreenState extends State<MenstrualCycleScreen> {
  late DateTime _selectedDate;
  
  // Estado local para edição
  MenstrualFlow? _selectedFlow;
  final Set<CycleSymptom> _selectedSymptoms = {};
  bool _tookPill = false;
  bool _hadSex = false;
  bool _usedProtection = false;
  bool _ovulation = false;
  final TextEditingController _notesController = TextEditingController();  // ✅ NOVO: Campo notas

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final controller = context.read<CycleController>();
    await controller.load(_selectedDate);
    
    // Sincronizar estado local com dados carregados
    if (mounted) {
      final entry = controller.todayEntry;
      setState(() {
        _selectedFlow = entry?.menstrualFlow;
        _selectedSymptoms.clear();
        if (entry != null) {
          _selectedSymptoms.addAll(entry.symptoms);
        }
        _tookPill = entry?.birthControlTaken ?? false;
        _hadSex = entry?.sexualActivity ?? false;
        _ovulation = entry?.ovulation ?? false;
        _notesController.text = entry?.notes ?? '';  // ✅ NOVO: Carregar notas
      });
    }
  }

  void _changeDate(DateTime newDate) {
    setState(() {
      _selectedDate = DateTime(newDate.year, newDate.month, newDate.day);
    });
    _loadData();
  }

  void _changeMonth(int year, int month) {
    final controller = context.read<CycleController>();
    controller.loadMonth(year, month);
    setState(() {
      _selectedDate = DateTime(year, month, 1);
    });
  }

  Future<void> _saveEntry() async {
    final controller = context.read<CycleController>();
    
    final entry = CycleEntry(
      id: controller.todayEntry?.id ?? '',
      userId: '',
      entryDate: _selectedDate,
      menstrualFlow: _selectedFlow,
      symptoms: _selectedSymptoms.toList(),
      birthControlTaken: _tookPill,
      sexualActivity: _hadSex,
      ovulation: _ovulation,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,  // ✅ NOVO: Gravar notas
    );
    
    await controller.saveEntry(entry);
    
    if (mounted && controller.saveStatus == CycleSaveStatus.saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registo guardado com sucesso!'),
          backgroundColor: Color(0xFF2F5D2F),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HabittusDrawer(),
      appBar: const HabittusAppBar(showBack: true),
      backgroundColor: const Color(0xFFF6F8F0),
      body: SafeArea(
        child: Consumer<CycleController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Date Pills
                DatePills(
                  day: '${_selectedDate.day}',
                  month: _getMonthName(_selectedDate.month),
                  year: '${_selectedDate.year}',
                  onDayPrev: () => _changeDate(_selectedDate.subtract(const Duration(days: 1))),
                  onDayNext: () => _changeDate(_selectedDate.add(const Duration(days: 1))),
                  onMonthPrev: () => _changeMonth(_selectedDate.year, _selectedDate.month - 1),
                  onMonthNext: () => _changeMonth(_selectedDate.year, _selectedDate.month + 1),
                  onYearPrev: () => _changeDate(DateTime(_selectedDate.year - 1, _selectedDate.month, _selectedDate.day)),
                  onYearNext: () => _changeDate(DateTime(_selectedDate.year + 1, _selectedDate.month, _selectedDate.day)),
                ),
                const SizedBox(height: 16),

                // Header Card
                _buildHeaderCard(controller),
                const SizedBox(height: 16),

                // Calendário
                _buildCalendar(controller),
                const SizedBox(height: 16),

                // Fase atual
                if (controller.cycleData != null)
                  _buildPhaseCard(controller),
                const SizedBox(height: 16),

                // Fluxo Menstrual
                _buildFlowCard(),
                const SizedBox(height: 16),

                // Sintomas
                _buildSymptomsCard(),
                const SizedBox(height: 16),

                // Contraceção e Atividade Sexual
                _buildIntimacyCard(),
                const SizedBox(height: 16),

                // Ovulação
                _buildOvulationCard(),
                const SizedBox(height: 16),

                // ✅ NOVO: Card de Notas
                _buildNotesCard(),
                const SizedBox(height: 24),

                // Botão Gravar
                Center(
                  child: SizedBox(
                    width: 200,
                    child: PrimaryButton(
                      text: controller.saveStatus == CycleSaveStatus.saving
                          ? 'A guardar...'
                          : 'Gravar',
                      onPressed: controller.saveStatus == CycleSaveStatus.saving
                          ? null
                          : _saveEntry,
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCard(CycleController controller) {
    final daysUntil = controller.daysUntilNextPeriod;
    final periodDay = controller.currentPeriodDay;
    
    String subtitle;
    if (periodDay != null) {
      subtitle = 'Dia $periodDay do período';
    } else if (daysUntil != null && daysUntil > 0) {
      subtitle = '$daysUntil dias até à próxima menstruação';
    } else {
      subtitle = 'Acompanha o teu ciclo';
    }
    
    return HabittusCard(
      title: 'Calendário Menstrual',
      subtitle: subtitle,
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildCalendar(CycleController controller) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE4EAD8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Month/Year header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(HabittusIcons.chevronLeft, size: 20),
                        onPressed: () => _changeMonth(
                          _selectedDate.month == 1 ? _selectedDate.year - 1 : _selectedDate.year,
                          _selectedDate.month == 1 ? 12 : _selectedDate.month - 1,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(HabittusIcons.chevronRight, size: 20),
                        onPressed: () => _changeMonth(
                          _selectedDate.month == 12 ? _selectedDate.year + 1 : _selectedDate.year,
                          _selectedDate.month == 12 ? 1 : _selectedDate.month + 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Weekday headers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['D', 'S', 'T', 'Q', 'Q', 'S', 'S']
                    .map((d) => SizedBox(
                          width: 36,
                          child: Text(
                            d,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),

              // Calendar grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: 42,
                itemBuilder: (context, index) {
                  final dayOffset = index - (startWeekday % 7);
                  final day = dayOffset + 1;

                  if (day < 1 || day > daysInMonth) {
                    return const SizedBox.shrink();
                  }

                  final date = DateTime(_selectedDate.year, _selectedDate.month, day);
                  final isToday = date.day == now.day &&
                      date.month == now.month &&
                      date.year == now.year;
                  final isSelected = date.day == _selectedDate.day &&
                      date.month == _selectedDate.month &&
                      date.year == _selectedDate.year;
                  
                  // Verificar se tem dados
                  final hasMenstruation = controller.menstruationDays.contains(day);
                  final hasOvulation = controller.ovulationDays.contains(day);
                  final hasSex = controller.sexualActivityDays.contains(day);

                  return _buildCalendarDay(
                    day, 
                    isToday, 
                    isSelected,
                    hasMenstruation: hasMenstruation,
                    hasOvulation: hasOvulation,
                    hasSex: hasSex,
                    onTap: () => _changeDate(date),
                  );
                },
              ),
              
              const SizedBox(height: 12),
              
              // Legenda
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Menstruação', const Color(0xFFE57373)),
                  const SizedBox(width: 16),
                  _buildLegendItem('Ovulação', const Color(0xFF81C784)),
                  const SizedBox(width: 16),
                  _buildLegendItem('Atividade', const Color(0xFF64B5F6)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildCalendarDay(
    int day,
    bool isToday,
    bool isSelected, {
    bool hasMenstruation = false,
    bool hasOvulation = false,
    bool hasSex = false,
    VoidCallback? onTap,
  }) {
    Color bgColor = Colors.transparent;
    Color textColor = Colors.black87;
    
    if (hasMenstruation) {
      bgColor = const Color(0xFFE57373);
      textColor = Colors.white;
    } else if (hasOvulation) {
      bgColor = const Color(0xFF81C784);
      textColor = Colors.white;
    } else if (hasSex) {
      bgColor = const Color(0xFF64B5F6);
      textColor = Colors.white;
    } else if (isSelected) {
      bgColor = const Color(0xFF2F5D2F);
      textColor = Colors.white;
    } else if (isToday) {
      bgColor = const Color(0xFFDDE6D3);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: isToday && !isSelected && !hasMenstruation && !hasOvulation
              ? Border.all(color: const Color(0xFF2F5D2F), width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
              color: textColor,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseCard(CycleController controller) {
    final phase = controller.currentPhase ?? CyclePhase.menstruation;
    final periodDay = controller.currentPeriodDay;
    final daysUntil = controller.daysUntilNextPeriod;
    
    int displayValue = periodDay ?? daysUntil ?? 0;
    String displayLabel = periodDay != null 
        ? 'Dia do período'
        : 'Dias até próximo';
    
    return HabittusCard(
      title: 'Fase Atual: ${phase.label}',
      subtitle: phase.description,
      child: Center(
        child: SizedBox(
          width: 120,
          height: 120,
          child: CustomPaint(
            painter: _CircularProgressPainter(
              progress: (periodDay ?? 1) / 7,
              color: const Color(0xFF8B9A7D),
              backgroundColor: const Color(0xFFE4EAD8),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayValue.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    displayLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlowCard() {
    return HabittusCard(
      title: 'Fluxo Menstrual',
      subtitle: _selectedFlow?.label ?? 'Seleciona o fluxo',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: MenstrualFlow.values.map((flow) {
          final isSelected = _selectedFlow == flow;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedFlow = _selectedFlow == flow ? null : flow;
            }),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2F5D2F)
                        : const Color(0xFFE4EAD8),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      flow.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  flow.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSymptomsCard() {
    return HabittusCard(
      title: 'Sintomas',
      subtitle: _selectedSymptoms.isEmpty 
          ? 'Seleciona os sintomas' 
          : '${_selectedSymptoms.length} selecionado(s)',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: CycleSymptom.values.map((symptom) {
          final isSelected = _selectedSymptoms.contains(symptom);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedSymptoms.remove(symptom);
                } else {
                  _selectedSymptoms.add(symptom);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2F5D2F)
                    : const Color(0xFFE4EAD8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(symptom.emoji),
                  const SizedBox(width: 4),
                  Text(
                    symptom.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIntimacyCard() {
    return HabittusCard(
      title: 'Contraceção e Intimidade',
      subtitle: 'Regista os teus dados',
      child: Column(
        children: [
          // Contraceção
          _buildSwitchTile(
            icon: HabittusIcons.medication,
            title: 'Tomei contraceção hoje',
            value: _tookPill,
            onChanged: (v) => setState(() => _tookPill = v),
          ),
          const Divider(height: 1),
          
          // Atividade sexual
          _buildSwitchTile(
            icon: HabittusIcons.heart,
            title: 'Atividade sexual',
            value: _hadSex,
            onChanged: (v) => setState(() {
              _hadSex = v;
              if (!v) _usedProtection = false;
            }),
          ),
          
          // Proteção (só se teve atividade)
          if (_hadSex) ...[
            const Divider(height: 1),
            _buildSwitchTile(
              icon: Icons.shield_outlined,
              title: 'Usei proteção',
              value: _usedProtection,
              onChanged: (v) => setState(() => _usedProtection = v),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2F5D2F), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2F5D2F),
          ),
        ],
      ),
    );
  }

  Widget _buildOvulationCard() {
    return HabittusCard(
      title: 'Ovulação',
      subtitle: _ovulation ? 'Dia de ovulação registado' : 'Marca se é dia de ovulação',
      child: Center(
        child: GestureDetector(
          onTap: () => setState(() => _ovulation = !_ovulation),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _ovulation
                  ? const Color(0xFF81C784)
                  : const Color(0xFFE4EAD8),
              shape: BoxShape.circle,
              border: Border.all(
                color: _ovulation
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFBDBDBD),
                width: 3,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _ovulation ? Icons.check : Icons.egg_outlined,
                    size: 32,
                    color: _ovulation ? Colors.white : Colors.black54,
                  ),
                  Text(
                    _ovulation ? 'Sim' : 'Não',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _ovulation ? Colors.white : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ NOVO: Card de Notas
  Widget _buildNotesCard() {
    return HabittusCard(
      title: 'Notas',
      subtitle: 'Adiciona observações sobre o teu dia',
      child: TextField(
        controller: _notesController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Escreve aqui as tuas notas...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          filled: true,
          fillColor: const Color(0xFFE4EAD8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

/// Painter para progresso circular
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    const strokeWidth = 10.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
