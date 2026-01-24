import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/cycle_entry.dart';
import '../widgets/habittus_app_bar.dart';
import '../widgets/habittus_drawer.dart';
import '../widgets/habittus_card.dart';
import '../widgets/date_pills.dart';
import '../widgets/habittus_icons.dart';

class MenstrualCycleScreen extends StatefulWidget {
  const MenstrualCycleScreen({super.key});

  @override
  State<MenstrualCycleScreen> createState() => _MenstrualCycleScreenState();
}

class _MenstrualCycleScreenState extends State<MenstrualCycleScreen> {
  DateTime _selectedDate = DateTime.now();
  
  // Dados mock do ciclo
  late CycleData _cycleData;
  
  // Seleções do utilizador
  final Set<String> _selectedTags = {'Menstruação'};
  MenstrualFlow _selectedFlow = MenstrualFlow.medium;
  
  // Dias marcados no calendário (mock)
  final Map<DateTime, CyclePhase> _markedDays = {};

  @override
  void initState() {
    super.initState();
    _cycleData = CycleData(
      cycleLength: 28,
      periodLength: 5,
      lastPeriodStart: DateTime.now().subtract(const Duration(days: 3)),
    );
    _generateMockCalendarData();
  }

  void _generateMockCalendarData() {
    // Simular dados do calendário
    final start = _cycleData.lastPeriodStart!;
    for (int i = 0; i < _cycleData.periodLength; i++) {
      _markedDays[start.add(Duration(days: i))] = CyclePhase.menstruation;
    }
    // Ovulação
    final ovulationStart = start.add(Duration(days: _cycleData.cycleLength ~/ 2 - 2));
    for (int i = 0; i < 4; i++) {
      _markedDays[ovulationStart.add(Duration(days: i))] = CyclePhase.ovulation;
    }
  }

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
            // Date Pills
            DatePills(
              day: '${_selectedDate.day}',
              month: _getMonthName(_selectedDate.month),
              year: '${_selectedDate.year}',
              onDayPrev: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
              onDayNext: () => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1))),
              onMonthPrev: () => setState(() => _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, _selectedDate.day)),
              onMonthNext: () => setState(() => _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, _selectedDate.day)),
              onYearPrev: () => setState(() => _selectedDate = DateTime(_selectedDate.year - 1, _selectedDate.month, _selectedDate.day)),
              onYearNext: () => setState(() => _selectedDate = DateTime(_selectedDate.year + 1, _selectedDate.month, _selectedDate.day)),
            ),
            const SizedBox(height: 16),

            // Header Card
            _buildHeaderCard(),
            const SizedBox(height: 16),

            // Calendário
            _buildCalendar(),
            const SizedBox(height: 16),

            // Tags de seleção
            _buildTagsSection(),
            const SizedBox(height: 16),

            // Ciclo atual
            _buildCycleStatusCard(),
            const SizedBox(height: 16),

            // Menstruação
            _buildMenstruationCard(),
            const SizedBox(height: 16),

            // Fluxo
            _buildFlowCard(),
            const SizedBox(height: 16),

            // Fase atual
            _buildPhaseCard(),
            const SizedBox(height: 16),

            // Sintomas
            _buildSymptomsCard(),
            const SizedBox(height: 16),

            // Bottom Navigation
            _buildBottomNav(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Adicionar registo
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registo guardado!'),
              backgroundColor: Color(0xFF2F5D2F),
            ),
          );
        },
        backgroundColor: const Color(0xFF2F5D2F),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return HabittusCard(
      title: 'Calendário menstrual',
      subtitle: 'Acompanha o teu ciclo e os teus registos.',
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday; // 1 = Monday

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
                        onPressed: () {
                          setState(() {
                            _selectedDate = DateTime(
                              _selectedDate.year,
                              _selectedDate.month - 1,
                              1,
                            );
                          });
                        },
                      ),
                      IconButton(
                    icon: const Icon(HabittusIcons.chevronRight, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime(
                          _selectedDate.year,
                          _selectedDate.month + 1,
                          1,
                        );
                      });
                    },
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
            itemCount: 42, // 6 weeks
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
              final phase = _getPhaseForDate(date);

              return _buildCalendarDay(day, isToday, phase);
            },
          ),
        ],
          ),
        ),
      ),
    );
  }

  CyclePhase? _getPhaseForDate(DateTime date) {
    for (final entry in _markedDays.entries) {
      if (entry.key.day == date.day &&
          entry.key.month == date.month &&
          entry.key.year == date.year) {
        return entry.value;
      }
    }
    return null;
  }

  Widget _buildCalendarDay(int day, bool isToday, CyclePhase? phase) {
    Color? bgColor;
    Color textColor = Colors.black87;

    if (phase == CyclePhase.menstruation) {
      bgColor = const Color(0xFFE57373); // Vermelho claro
      textColor = Colors.white;
    } else if (phase == CyclePhase.ovulation) {
      bgColor = const Color(0xFF81C784); // Verde claro
      textColor = Colors.white;
    }

    if (isToday && phase == null) {
      bgColor = const Color(0xFF2F5D2F);
      textColor = Colors.white;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: isToday && phase != null
            ? Border.all(color: const Color(0xFF2F5D2F), width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          day.toString(),
          style: TextStyle(
            color: textColor,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    final tags = ['Menstruação', 'Ovulação', 'Período Fértil'];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        final isSelected = _selectedTags.contains(tag);
        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedTags.remove(tag);
              } else {
                _selectedTags.add(tag);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2F5D2F) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? const Color(0xFF2F5D2F) : Colors.black26,
              ),
            ),
            child: Text(
              tag,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCycleStatusCard() {
    final daysUntil = _cycleData.daysUntilNextPeriod ?? 19;
    
    return HabittusCard(
      title: 'Ciclo atual',
      subtitle: 'Dias até a próxima menstruação',
      child: Center(
        child: SizedBox(
          width: 150,
          height: 150,
          child: CustomPaint(
            painter: _CircularProgressPainter(
              progress: (28 - daysUntil) / 28,
              color: const Color(0xFF8B9A7D),
              backgroundColor: const Color(0xFFE4EAD8),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    daysUntil.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'dias restantes',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
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

  Widget _buildMenstruationCard() {
    final periodDay = _cycleData.currentPeriodDay ?? 4;
    
    return HabittusCard(
      title: 'Menstruação',
      subtitle: 'Estado do período de hoje',
      child: Center(
        child: SizedBox(
          width: 150,
          height: 150,
          child: CustomPaint(
            painter: _CircularProgressPainter(
              progress: periodDay / _cycleData.periodLength,
              color: const Color(0xFFE57373),
              backgroundColor: const Color(0xFFFFCDD2),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    periodDay.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'dia do período',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
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

  Widget _buildFlowCard() {
    return HabittusCard(
      title: 'Fluxo',
      subtitle: _selectedFlow.label,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: MenstrualFlow.values.map((flow) {
          final isSelected = _selectedFlow == flow;
          return InkWell(
            onTap: () => setState(() => _selectedFlow = flow),
            child: Container(
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
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPhaseCard() {
    final phase = _cycleData.currentPhase ?? CyclePhase.menstruation;
    final daysInPhase = 9; // Mock
    
    return HabittusCard(
      title: 'Fase atual',
      subtitle: 'Momento do teu ciclo',
      child: Center(
        child: SizedBox(
          width: 150,
          height: 150,
          child: CustomPaint(
            painter: _CircularProgressPainter(
              progress: 0.3,
              color: const Color(0xFF8B9A7D),
              backgroundColor: const Color(0xFFE4EAD8),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    daysInPhase.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Fase: ${phase.label}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
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

  Widget _buildSymptomsCard() {
    return HabittusCard(
      title: 'Sintomas de Menstruação',
      subtitle: 'Como te sentes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Registados no Humor Diário',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSymptomChip('Dor Inchaço', '😣', true),
                _buildSymptomChip('Barriga Inchada', '🎈', false),
                _buildSymptomChip('Aumento Calórico', '🍫', false),
                _buildSymptomChip('Dor de Cabeça', '🤕', false),
                _buildSymptomChip('Cansaço', '😴', true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomChip(String label, String emoji, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF2F5D2F) : const Color(0xFFE4EAD8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': HabittusIcons.water, 'label': 'Água', 'color': HabittusIcons.waterColor},
      {'icon': HabittusIcons.meal, 'label': 'Refeições', 'color': HabittusIcons.foodColor},
      {'icon': HabittusIcons.caffeine, 'label': 'Cafeína', 'color': const Color(0xFF795548)},
      {'icon': HabittusIcons.activity, 'label': 'Desporto', 'color': HabittusIcons.activityColor},
      {'icon': HabittusIcons.sleep, 'label': 'Sono', 'color': HabittusIcons.sleepColor},
      {'icon': HabittusIcons.heart, 'label': 'Saúde mental', 'color': HabittusIcons.moodColor},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE4EAD8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((item) {
          final color = item['color'] as Color;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['label'] as String,
                style: const TextStyle(fontSize: 9),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[month - 1];
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
    const strokeWidth = 12.0;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
