import 'package:flutter/foundation.dart';
import '../models/cycle_entry.dart';
import '../repositories/supabase/supabase_cycle_repository.dart';

enum CycleSaveStatus { idle, saving, saved, error }

class CycleController extends ChangeNotifier {
  final SupabaseCycleRepository _repo = SupabaseCycleRepository();

  DateTime selectedDate = DateTime.now();
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  
  CycleEntry? _todayEntry;
  List<CycleEntry> _monthEntries = [];
  CycleData? _cycleData;
  bool _isLoading = false;
  CycleSaveStatus _saveStatus = CycleSaveStatus.idle;
  String? _error;

  CycleEntry? get todayEntry => _todayEntry;
  List<CycleEntry> get monthEntries => _monthEntries;
  CycleData? get cycleData => _cycleData;
  bool get isLoading => _isLoading;
  CycleSaveStatus get saveStatus => _saveStatus;
  String? get error => _error;

  // Dados calculados
  int? get daysUntilNextPeriod => _cycleData?.daysUntilNextPeriod;
  int? get currentPeriodDay => _cycleData?.currentPeriodDay;
  CyclePhase? get currentPhase => _cycleData?.currentPhase;
  int? get daysUntilOvulation => _cycleData?.daysUntilOvulation;
  DateTime? get lastPeriodStart => _cycleData?.lastPeriodStart;

  /// Dias com menstruação no mês
  List<int> get menstruationDays {
    return _monthEntries
        .where((e) => e.menstrualFlow != null && e.menstrualFlow != MenstrualFlow.none)
        .map((e) => e.entryDate.day)
        .toList();
  }

  /// Dias de ovulação no mês
  List<int> get ovulationDays {
    return _monthEntries
        .where((e) => e.ovulation)
        .map((e) => e.entryDate.day)
        .toList();
  }

  /// Dias com atividade sexual no mês
  List<int> get sexualActivityDays {
    return _monthEntries
        .where((e) => e.sexualActivity)
        .map((e) => e.entryDate.day)
        .toList();
  }

  Future<void> load(DateTime date) async {
    selectedDate = DateTime(date.year, date.month, date.day);
    selectedMonth = date.month;
    selectedYear = date.year;
    _isLoading = true;
    _saveStatus = CycleSaveStatus.idle;
    notifyListeners();

    try {
      _todayEntry = await _repo.getForDate(selectedDate);
      _monthEntries = await _repo.getForMonth(selectedYear, selectedMonth);
      _cycleData = await _repo.getCycleData();
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMonth(int year, int month) async {
    selectedYear = year;
    selectedMonth = month;
    _isLoading = true;
    notifyListeners();

    try {
      _monthEntries = await _repo.getForMonth(year, month);
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar mês: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveEntry(CycleEntry entry) async {
    _saveStatus = CycleSaveStatus.saving;
    notifyListeners();

    try {
      await _repo.save(entry);
      
      // Atualizar dados locais
      if (entry.entryDate.year == selectedYear && entry.entryDate.month == selectedMonth) {
        final index = _monthEntries.indexWhere((e) => 
            e.entryDate.year == entry.entryDate.year &&
            e.entryDate.month == entry.entryDate.month &&
            e.entryDate.day == entry.entryDate.day);
        
        if (index >= 0) {
          _monthEntries[index] = entry;
        } else {
          _monthEntries.add(entry);
        }
      }
      
      if (_isSameDay(entry.entryDate, selectedDate)) {
        _todayEntry = entry;
      }

      // Recalcular dados do ciclo
      _cycleData = await _repo.getCycleData();

      _saveStatus = CycleSaveStatus.saved;
      _error = null;
    } catch (e) {
      _saveStatus = CycleSaveStatus.error;
      _error = 'Erro ao guardar: $e';
    }

    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      if (_saveStatus == CycleSaveStatus.saved) {
        _saveStatus = CycleSaveStatus.idle;
        notifyListeners();
      }
    });
  }

  Future<void> deleteEntry(DateTime date) async {
    try {
      await _repo.delete(date);
      _monthEntries.removeWhere((e) => _isSameDay(e.entryDate, date));
      if (_isSameDay(date, selectedDate)) {
        _todayEntry = null;
      }
      _cycleData = await _repo.getCycleData();
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao apagar: $e';
      notifyListeners();
    }
  }

  /// Regista início de menstruação
  Future<void> logPeriodStart(DateTime date, {MenstrualFlow flow = MenstrualFlow.medium}) async {
    final existing = await _repo.getForDate(date);
    final entry = existing?.copyWith(menstrualFlow: flow) ??
        CycleEntry(
          id: '',
          userId: '',
          entryDate: date,
          menstrualFlow: flow,
        );
    await saveEntry(entry);
  }

  /// Regista fim de menstruação
  Future<void> logPeriodEnd(DateTime date) async {
    final existing = await _repo.getForDate(date);
    if (existing != null) {
      await saveEntry(existing.copyWith(menstrualFlow: MenstrualFlow.none));
    }
  }

  /// Regista ovulação
  Future<void> logOvulation(DateTime date) async {
    final existing = await _repo.getForDate(date);
    final entry = existing?.copyWith(ovulation: true) ??
        CycleEntry(
          id: '',
          userId: '',
          entryDate: date,
          ovulation: true,
        );
    await saveEntry(entry);
  }

  /// Regista sintomas
  Future<void> logSymptoms(DateTime date, List<CycleSymptom> symptoms) async {
    final existing = await _repo.getForDate(date);
    final entry = existing?.copyWith(symptoms: symptoms) ??
        CycleEntry(
          id: '',
          userId: '',
          entryDate: date,
          symptoms: symptoms,
        );
    await saveEntry(entry);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void clearStatus() {
    _saveStatus = CycleSaveStatus.idle;
    _error = null;
    notifyListeners();
  }
}
