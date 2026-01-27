import 'package:flutter/foundation.dart';
import '../repositories/supabase/supabase_mood_repository.dart' as mood_repo;
import '../repositories/supabase/supabase_cycle_repository.dart';
import '../models/cycle_entry.dart';
import '../models/mood.dart';

enum MoodSaveStatus { idle, saving, saved, error }

/// Controller unificado para Mood e Ciclo Menstrual
class MoodController extends ChangeNotifier {
  final mood_repo.SupabaseMoodRepository _moodRepo = mood_repo.SupabaseMoodRepository();
  final SupabaseCycleRepository _cycleRepo = SupabaseCycleRepository();

  DateTime selectedDate = DateTime.now();
  
  // Dados de Mood
  MoodLevel? _selectedLevel;
  int _intensity = 3;
  String? _notes;
  String? _sleepQuality;
  final Set<String> _emotions = {};
  final Set<String> _health = {};
  final Set<String> _food = {};
  final Set<String> _weather = {};

  // Dados de Ciclo (feminino)
  CycleEntry? _currentCycle;
  bool _tookPill = false;
  bool _hadSex = false;
  bool _usedProtection = false;
  MenstrualFlow? _menstrualFlow;
  final Set<CycleSymptom> _symptoms = {};

  // Estado
  bool _isLoading = false;
  MoodSaveStatus _saveStatus = MoodSaveStatus.idle;
  String? _errorMessage;

  // Getters
  MoodLevel? get selectedLevel => _selectedLevel;
  CycleEntry? get currentCycle => _currentCycle;
  int get intensity => _intensity;
  String? get notes => _notes;
  String? get sleepQuality => _sleepQuality;
  Set<String> get emotions => _emotions;
  Set<String> get health => _health;
  Set<String> get food => _food;
  Set<String> get weather => _weather;
  
  bool get tookPill => _tookPill;
  bool get hadSex => _hadSex;
  bool get usedProtection => _usedProtection;
  MenstrualFlow? get menstrualFlow => _menstrualFlow;
  Set<CycleSymptom> get symptoms => _symptoms;

  bool get isLoading => _isLoading;
  MoodSaveStatus get saveStatus => _saveStatus;
  String? get errorMessage => _errorMessage;

  /// Seleciona nível de mood (chamado pelo UI)
  void select(MoodLevel level) {
    _selectedLevel = level;
    notifyListeners();
  }

  Future<void> load(DateTime date) async {
    selectedDate = DateTime(date.year, date.month, date.day);
    _isLoading = true;
    _saveStatus = MoodSaveStatus.idle;
    notifyListeners();

    try {
      // Carregar mood
      final moodEntry = await _moodRepo.getForDate(selectedDate);
      if (moodEntry != null) {
        _selectedLevel = _moodTypeToLevel(moodEntry.moodTypeId);
        _intensity = moodEntry.intensity ?? 3;
        _notes = moodEntry.notes;
      } else {
        _clearMoodState();
      }

      // Carregar ciclo
      _currentCycle = await _cycleRepo.getForDate(selectedDate);
      if (_currentCycle != null) {
        _tookPill = _currentCycle!.birthControlTaken;
        _hadSex = _currentCycle!.sexualActivity;
        _menstrualFlow = _currentCycle!.menstrualFlow;
        _symptoms.clear();
        _symptoms.addAll(_currentCycle!.symptoms);
      } else {
        _clearCycleState();
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erro ao carregar: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  MoodLevel? _moodTypeToLevel(int typeId) {
    switch (typeId) {
      case 1: return MoodLevel.veryBad;
      case 2: return MoodLevel.bad;
      case 3: return MoodLevel.neutral;
      case 4: return MoodLevel.good;
      case 5: return MoodLevel.veryGood;
      default: return null;
    }
  }

  int _levelToMoodType(MoodLevel level) {
    switch (level) {
      case MoodLevel.veryBad: return 1;
      case MoodLevel.bad: return 2;
      case MoodLevel.neutral: return 3;
      case MoodLevel.good: return 4;
      case MoodLevel.veryGood: return 5;
    }
  }

  void _clearMoodState() {
    _selectedLevel = null;
    _intensity = 3;
    _notes = null;
    _sleepQuality = null;
    _emotions.clear();
    _health.clear();
    _food.clear();
    _weather.clear();
  }

  void _clearCycleState() {
    _tookPill = false;
    _hadSex = false;
    _usedProtection = false;
    _menstrualFlow = null;
    _symptoms.clear();
  }

  // Setters para mood
  void setIntensity(int value) {
    _intensity = value;
    notifyListeners();
  }

  void setNotes(String? value) {
    _notes = value;
    notifyListeners();
  }

  void setSleepQuality(String? value) {
    _sleepQuality = value;
    notifyListeners();
  }

  void toggleEmotion(String emotion) {
    if (_emotions.contains(emotion)) {
      _emotions.remove(emotion);
    } else {
      _emotions.add(emotion);
    }
    notifyListeners();
  }

  void toggleHealth(String item) {
    if (_health.contains(item)) {
      _health.remove(item);
    } else {
      _health.add(item);
    }
    notifyListeners();
  }

  void toggleFood(String item) {
    if (_food.contains(item)) {
      _food.remove(item);
    } else {
      _food.add(item);
    }
    notifyListeners();
  }

  void toggleWeather(String item) {
    if (_weather.contains(item)) {
      _weather.remove(item);
    } else {
      _weather.add(item);
    }
    notifyListeners();
  }

  // Setters para ciclo
  void setTookPill(bool value) {
    _tookPill = value;
    notifyListeners();
  }

  void setHadSex(bool value) {
    _hadSex = value;
    notifyListeners();
  }

  void setUsedProtection(bool value) {
    _usedProtection = value;
    notifyListeners();
  }

  void setMenstrualFlow(MenstrualFlow? flow) {
    _menstrualFlow = flow;
    notifyListeners();
  }

  void toggleSymptom(CycleSymptom symptom) {
    if (_symptoms.contains(symptom)) {
      _symptoms.remove(symptom);
    } else {
      _symptoms.add(symptom);
    }
    notifyListeners();
  }

  /// Grava todos os dados (mood + ciclo)
  Future<void> save() async {
    _saveStatus = MoodSaveStatus.saving;
    notifyListeners();

    try {
      // Guardar mood
      if (_selectedLevel != null) {
        final moodEntry = mood_repo.MoodEntry(
          moodTypeId: _levelToMoodType(_selectedLevel!),
          createdAt: selectedDate,
          intensity: _intensity,
          notes: _buildNotesString(),
        );
        await _moodRepo.save(moodEntry);
      }

      // Guardar ciclo
      if (_menstrualFlow != null || _symptoms.isNotEmpty || _tookPill || _hadSex) {
        final cycleEntry = CycleEntry(
          id: _currentCycle?.id ?? '',
          userId: '',
          entryDate: selectedDate,
          menstrualFlow: _menstrualFlow,
          symptoms: _symptoms.toList(),
          birthControlTaken: _tookPill,
          sexualActivity: _hadSex,
          notes: _notes,
        );
        await _cycleRepo.save(cycleEntry);
      }

      _saveStatus = MoodSaveStatus.saved;
      _errorMessage = null;
    } catch (e) {
      _saveStatus = MoodSaveStatus.error;
      _errorMessage = 'Erro ao guardar: $e';
    }

    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      if (_saveStatus == MoodSaveStatus.saved) {
        _saveStatus = MoodSaveStatus.idle;
        notifyListeners();
      }
    });
  }

  String _buildNotesString() {
    final parts = <String>[];
    
    // Construir string com dados (abreviados para caber no campo)
    if (_sleepQuality != null) parts.add('S:$_sleepQuality');
    if (_emotions.isNotEmpty) parts.add('E:${_emotions.length}');
    if (_health.isNotEmpty) parts.add('H:${_health.length}');
    if (_food.isNotEmpty) parts.add('F:${_food.length}');
    if (_weather.isNotEmpty) parts.add('W:${_weather.length}');
    if (_notes != null && _notes!.isNotEmpty) {
      // Adicionar notas truncadas se houver espaço
      final notesShort = _notes!.length > 20 ? _notes!.substring(0, 20) : _notes!;
      parts.add(notesShort);
    }

    final result = parts.join('|');
    // Truncar para 45 caracteres (limite do campo VARCHAR(45))
    return result.length > 45 ? result.substring(0, 45) : result;
  }

  void clearStatus() {
    _saveStatus = MoodSaveStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpa todos os dados do formulário (para nova entrada)
  void clearAllData() {
    _sleepQuality = null;
    _notes = null;
    _emotions.clear();
    _health.clear();
    _food.clear();
    _weather.clear();
    // Não limpar _selectedLevel pois é selecionado separadamente
  }

  /// Define fluxo menstrual a partir de string
  void setMenstrualFlowFromString(String flow) {
    switch (flow.toLowerCase()) {
      case 'leve':
        _menstrualFlow = MenstrualFlow.light;
        break;
      case 'moderado':
        _menstrualFlow = MenstrualFlow.medium;
        break;
      case 'intenso':
        _menstrualFlow = MenstrualFlow.heavy;
        break;
      default:
        _menstrualFlow = null;
    }
    notifyListeners();
  }

  /// Toggle sintoma a partir de string
  void toggleSymptomFromString(String symptom) {
    CycleSymptom? cycleSymptom;
    switch (symptom.toLowerCase()) {
      case 'cólicas':
        cycleSymptom = CycleSymptom.cramps;
        break;
      case 'dor de cabeça':
        cycleSymptom = CycleSymptom.headache;
        break;
      case 'inchaço':
        cycleSymptom = CycleSymptom.bloating;
        break;
      case 'fadiga':
        cycleSymptom = CycleSymptom.fatigue;
        break;
      case 'náuseas':
        cycleSymptom = CycleSymptom.nausea;
        break;
      case 'dor nas costas':
        cycleSymptom = CycleSymptom.backPain;
        break;
      case 'sensibilidade mamária':
        cycleSymptom = CycleSymptom.breastTenderness;
        break;
      case 'alterações de humor':
        cycleSymptom = CycleSymptom.moodSwings;
        break;
      case 'acne':
        cycleSymptom = CycleSymptom.acne;
        break;
      case 'insónia':
        cycleSymptom = CycleSymptom.insomnia;
        break;
    }
    if (cycleSymptom != null) {
      toggleSymptom(cycleSymptom);
    }
  }
}
