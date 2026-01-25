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

  // ============================================================
  // LOAD - Carregar todos os dados para uma data
  // ============================================================
  Future<void> load(DateTime date) async {
    selectedDate = DateTime(date.year, date.month, date.day);
    _isLoading = true;
    _saveStatus = MoodSaveStatus.idle;
    notifyListeners();

    print('[MOOD CONTROLLER] Carregando dados para $selectedDate');

    try {
      // ============================================================
      // 1. CARREGAR MOOD (tabela mood)
      // ============================================================
      final moodEntry = await _moodRepo.getForDate(selectedDate);
      if (moodEntry != null) {
        print('[MOOD CONTROLLER] Mood encontrado: level=${moodEntry.moodTypeId}');
        _selectedLevel = _moodTypeToLevel(moodEntry.moodTypeId);
        _intensity = moodEntry.intensity ?? 3;
        _notes = moodEntry.notes;
        
        // Carregar campos adicionais
        _sleepQuality = moodEntry.sleepQuality;
        _emotions.clear();
        _emotions.addAll(moodEntry.emotions);
        _health.clear();
        _health.addAll(moodEntry.health);
        _food.clear();
        _food.addAll(moodEntry.food);
        _weather.clear();
        _weather.addAll(moodEntry.weather);
        
        print('[MOOD CONTROLLER] Dados carregados: sleep=$_sleepQuality, emotions=$_emotions');
      } else {
        print('[MOOD CONTROLLER] Nenhum mood encontrado');
        _clearMoodState();
      }

      // ============================================================
      // 2. CARREGAR CICLO (tabela cycle_entry)
      // ============================================================
      _currentCycle = await _cycleRepo.getForDate(selectedDate);
      if (_currentCycle != null) {
        print('[MOOD CONTROLLER] Ciclo encontrado: flow=${_currentCycle!.menstrualFlow}');
        _tookPill = _currentCycle!.birthControlTaken;
        _hadSex = _currentCycle!.sexualActivity;
        _menstrualFlow = _currentCycle!.menstrualFlow;
        _symptoms.clear();
        _symptoms.addAll(_currentCycle!.symptoms);
      } else {
        print('[MOOD CONTROLLER] Nenhum ciclo encontrado');
        _clearCycleState();
      }

      _errorMessage = null;
    } catch (e) {
      print('[MOOD CONTROLLER ERROR] $e');
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

  // ============================================================
  // SAVE - Gravar todos os dados (mood + ciclo)
  // ============================================================
  Future<void> save({bool isFemale = true}) async {
    _saveStatus = MoodSaveStatus.saving;
    notifyListeners();

    print('[MOOD CONTROLLER] Gravando dados para $selectedDate');
    print('[MOOD CONTROLLER] Level: $_selectedLevel, Sleep: $_sleepQuality');
    print('[MOOD CONTROLLER] Emotions: $_emotions, Health: $_health');
    print('[MOOD CONTROLLER] Food: $_food, Weather: $_weather');

    try {
      // ============================================================
      // 1. GUARDAR MOOD (tabela mood)
      // ============================================================
      if (_selectedLevel != null) {
        final moodEntry = mood_repo.MoodEntry(
          moodTypeId: _levelToMoodType(_selectedLevel!),
          createdAt: selectedDate,
          intensity: _intensity,
          notes: _notes,
          sleepQuality: _sleepQuality,
          emotions: _emotions.toList(),
          health: _health.toList(),
          food: _food.toList(),
          weather: _weather.toList(),
        );
        await _moodRepo.save(moodEntry);
        print('[MOOD CONTROLLER] Mood gravado com sucesso!');
      }

      // ============================================================
      // 2. GUARDAR CICLO (tabela cycle_entry) - só se feminino
      // ============================================================
      print('[MOOD CONTROLLER] Verificando se deve gravar ciclo:');
      print('  - isFemale: $isFemale');
      print('  - _menstrualFlow: $_menstrualFlow');
      print('  - _symptoms: $_symptoms');
      print('  - _tookPill: $_tookPill');
      print('  - _hadSex: $_hadSex');
      
      if (isFemale && (_menstrualFlow != null || _symptoms.isNotEmpty || _tookPill || _hadSex)) {
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
        print('[MOOD CONTROLLER] CycleEntry a gravar:');
        print('  - menstrualFlow: ${cycleEntry.menstrualFlow}');
        print('  - symptoms: ${cycleEntry.symptoms}');
        await _cycleRepo.save(cycleEntry);
        print('[MOOD CONTROLLER] Ciclo gravado com sucesso!');
      } else {
        print('[MOOD CONTROLLER] Ciclo NÃO gravado (condições não satisfeitas)');
      }

      _saveStatus = MoodSaveStatus.saved;
      _errorMessage = null;
    } catch (e) {
      print('[MOOD CONTROLLER ERROR] Erro ao guardar: $e');
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
    _tookPill = false;
    _hadSex = false;
    _usedProtection = false;
    _menstrualFlow = null;
    _symptoms.clear();
  }

  /// Define fluxo menstrual a partir de string (ID do UI)
  void setMenstrualFlowFromString(String flow) {
    print('[MOOD CONTROLLER] setMenstrualFlowFromString: "$flow"');
    switch (flow.toLowerCase()) {
      case 'nenhum':
        _menstrualFlow = MenstrualFlow.none;
        break;
      case 'spots':
      case 'spotting':
        _menstrualFlow = MenstrualFlow.spotting;
        break;
      case 'muito leve':
      case 'leve':
        _menstrualFlow = MenstrualFlow.light;
        break;
      case 'moderado':
        _menstrualFlow = MenstrualFlow.medium;
        break;
      case 'intenso':
      case 'muito intenso':
        _menstrualFlow = MenstrualFlow.heavy;
        break;
      default:
        print('[MOOD CONTROLLER] Fluxo não reconhecido: "$flow"');
        _menstrualFlow = null;
    }
    print('[MOOD CONTROLLER] _menstrualFlow definido para: $_menstrualFlow');
    notifyListeners();
  }

  /// Toggle sintoma a partir de string (ID do UI)
  void toggleSymptomFromString(String symptom) {
    print('[MOOD CONTROLLER] toggleSymptomFromString: "$symptom"');
    CycleSymptom? cycleSymptom;
    switch (symptom.toLowerCase()) {
      case 'cólicas':
        cycleSymptom = CycleSymptom.cramps;
        break;
      case 'dor de cabeça':
        cycleSymptom = CycleSymptom.headache;
        break;
      case 'inchaço':
      case 'barriga inchada':
        cycleSymptom = CycleSymptom.bloating;
        break;
      case 'fadiga':
      case 'cansaço':
        cycleSymptom = CycleSymptom.fatigue;
        break;
      case 'náuseas':
      case 'enjoos':
        cycleSymptom = CycleSymptom.nausea;
        break;
      case 'dor nas costas':
      case 'dor lombar':
        cycleSymptom = CycleSymptom.backPain;
        break;
      case 'sensibilidade mamária':
      case 'seios sensíveis':
        cycleSymptom = CycleSymptom.breastTenderness;
        break;
      case 'alterações de humor':
      case 'tonturas':
        cycleSymptom = CycleSymptom.moodSwings;
        break;
      case 'acne':
      case 'borbulhas':
        cycleSymptom = CycleSymptom.acne;
        break;
      case 'insónia':
        cycleSymptom = CycleSymptom.insomnia;
        break;
      case 'aumento do apetite':
        cycleSymptom = CycleSymptom.cravings;
        break;
      case 'sangramento':
        // Sangramento é tratado via fluxo menstrual, não sintoma
        break;
      default:
        print('[MOOD CONTROLLER] Sintoma não reconhecido: "$symptom"');
    }
    if (cycleSymptom != null) {
      toggleSymptom(cycleSymptom);
      print('[MOOD CONTROLLER] Sintoma adicionado: $cycleSymptom');
    }
  }
}
