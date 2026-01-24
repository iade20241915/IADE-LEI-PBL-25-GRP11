import '../models/user_model.dart';
import '../models/water_intake_model.dart';
import '../models/sleep_session_model.dart';
import '../models/meal_model.dart';
import '../models/mood_model.dart';
import '../models/activity_model.dart';
import '../models/habit_model.dart';
import '../models/cycle_entry_model.dart';

/// Design Pattern: FACTORY METHOD
/// 
/// O ModelFactory implementa o padrão Factory Method para criar
/// instâncias de modelos de forma centralizada e consistente.
/// 
/// Benefícios:
/// - Encapsulamento da lógica de criação
/// - Flexibilidade para criar diferentes tipos de objetos
/// - Centralização de validações e defaults
/// - Facilita testes unitários
/// 
abstract class ModelFactory<T> {
  T create(Map<String, dynamic> data);
  T createDefault({required int userId});
}

/// Factory para UserModel
class UserModelFactory implements ModelFactory<UserModel> {
  @override
  UserModel create(Map<String, dynamic> data) {
    return UserModel.fromJson(data);
  }

  @override
  UserModel createDefault({required int userId}) {
    return UserModel(
      userId: userId,
      email: '',
      fullName: '',
    );
  }

  /// Cria um novo utilizador para registo
  UserModel createForRegistration({
    required String email,
    required String fullName,
    String? password,
    DateTime? birthDate,
    Gender? gender,
  }) {
    return UserModel(
      email: email,
      fullName: fullName,
      passwordHash: password, // Será hash no servidor
      birthDate: birthDate,
      gender: gender,
    );
  }
}

/// Factory para WaterIntakeModel
class WaterIntakeModelFactory implements ModelFactory<WaterIntakeModel> {
  @override
  WaterIntakeModel create(Map<String, dynamic> data) {
    return WaterIntakeModel.fromJson(data);
  }

  @override
  WaterIntakeModel createDefault({required int userId}) {
    return WaterIntakeModel(
      amountMl: 250,
      userId: userId,
    );
  }

  /// Cria intake para um copo de água (250ml)
  WaterIntakeModel createGlass({required int userId}) {
    return WaterIntakeModel(
      amountMl: 250,
      source: WaterSource.manual,
      userId: userId,
    );
  }

  /// Cria intake para garrafa
  WaterIntakeModel createBottle({
    required int userId,
    int amountMl = 500,
  }) {
    return WaterIntakeModel(
      amountMl: amountMl,
      source: WaterSource.bottle,
      userId: userId,
    );
  }
}

/// Factory para SleepSessionModel
class SleepSessionModelFactory implements ModelFactory<SleepSessionModel> {
  @override
  SleepSessionModel create(Map<String, dynamic> data) {
    return SleepSessionModel.fromJson(data);
  }

  @override
  SleepSessionModel createDefault({required int userId}) {
    final now = DateTime.now();
    return SleepSessionModel(
      startTime: DateTime(now.year, now.month, now.day, 23, 0),
      endTime: DateTime(now.year, now.month, now.day + 1, 7, 0),
      qualityScore: 3,
      userId: userId,
    );
  }

  /// Cria sessão a partir de duração
  SleepSessionModel createFromDuration({
    required int userId,
    required Duration duration,
    int qualityScore = 3,
    DateTime? date,
  }) {
    return SleepSessionModel.fromDuration(
      duration: duration,
      userId: userId,
      qualityScore: qualityScore,
      date: date,
    );
  }

  /// Cria sessão a partir de horas
  SleepSessionModel createFromHours({
    required int userId,
    required double hours,
    int qualityScore = 3,
  }) {
    final minutes = (hours * 60).round();
    return createFromDuration(
      userId: userId,
      duration: Duration(minutes: minutes),
      qualityScore: qualityScore,
    );
  }
}

/// Factory para MealModel
class MealModelFactory implements ModelFactory<MealModel> {
  @override
  MealModel create(Map<String, dynamic> data) {
    return MealModel.fromJson(data);
  }

  @override
  MealModel createDefault({required int userId}) {
    return MealModel(
      mealType: MealType.lunch,
      userId: userId,
    );
  }

  /// Cria refeição por tipo
  MealModel createByType({
    required int userId,
    required MealType type,
    List<MealItemModel>? items,
    String? notes,
  }) {
    return MealModel(
      mealType: type,
      userId: userId,
      items: items ?? [],
      notes: notes,
    );
  }

  /// Cria pequeno-almoço
  MealModel createBreakfast({required int userId}) {
    return createByType(userId: userId, type: MealType.breakfast);
  }

  /// Cria almoço
  MealModel createLunch({required int userId}) {
    return createByType(userId: userId, type: MealType.lunch);
  }

  /// Cria lanche
  MealModel createSnack({required int userId}) {
    return createByType(userId: userId, type: MealType.snack);
  }

  /// Cria jantar
  MealModel createDinner({required int userId}) {
    return createByType(userId: userId, type: MealType.dinner);
  }
}

/// Factory para MoodModel
class MoodModelFactory implements ModelFactory<MoodModel> {
  @override
  MoodModel create(Map<String, dynamic> data) {
    return MoodModel.fromJson(data);
  }

  @override
  MoodModel createDefault({required int userId}) {
    return MoodModel(
      userId: userId,
      moodTypeId: 3, // Neutral
      intensity: 3,
    );
  }

  /// Cria mood com nível
  MoodModel createWithLevel({
    required int userId,
    required MoodLevel level,
    String? notes,
    List<String>? emotions,
  }) {
    return MoodModel(
      userId: userId,
      moodTypeId: level.value,
      intensity: level.value,
      notes: notes,
      emotions: emotions ?? [],
    );
  }
}

/// Factory para ActivityModel
class ActivityModelFactory implements ModelFactory<ActivityModel> {
  @override
  ActivityModel create(Map<String, dynamic> data) {
    return ActivityModel.fromJson(data);
  }

  @override
  ActivityModel createDefault({required int userId}) {
    return ActivityModel(
      userId: userId,
      activityTypeId: 1,
      durationMin: 30,
    );
  }

  /// Cria atividade com tipo
  ActivityModel createWithType({
    required int userId,
    required int activityTypeId,
    required int durationMin,
    int? steps,
    int? kcal,
    double? distanceKm,
  }) {
    return ActivityModel(
      userId: userId,
      activityTypeId: activityTypeId,
      durationMin: durationMin,
      steps: steps,
      kcal: kcal,
      distanceKm: distanceKm,
    );
  }
}

/// Factory para HabitModel
class HabitModelFactory implements ModelFactory<HabitModel> {
  @override
  HabitModel create(Map<String, dynamic> data) {
    return HabitModel.fromJson(data);
  }

  @override
  HabitModel createDefault({required int userId}) {
    return HabitModel(
      userId: userId,
      habitTypeId: 1,
    );
  }

  /// Cria hábito positivo
  HabitModel createPositive({
    required int userId,
    required int habitTypeId,
    required String name,
    HabitCategory category = HabitCategory.other,
    String? description,
  }) {
    return HabitModel(
      userId: userId,
      habitTypeId: habitTypeId,
      name: name,
      category: category,
      description: description,
      isPositive: true,
    );
  }

  /// Cria vício (hábito negativo)
  HabitModel createNegative({
    required int userId,
    required int habitTypeId,
    required String name,
    HabitCategory category = HabitCategory.other,
    String? description,
    double? dailyCost,
    int? timesPerDay,
  }) {
    return HabitModel(
      userId: userId,
      habitTypeId: habitTypeId,
      name: name,
      category: category,
      description: description,
      isPositive: false,
      moneySpent: dailyCost,
      timesDay: timesPerDay,
    );
  }
}

/// Factory para CycleEntryModel
class CycleEntryModelFactory implements ModelFactory<CycleEntryModel> {
  @override
  CycleEntryModel create(Map<String, dynamic> data) {
    return CycleEntryModel.fromJson(data);
  }

  @override
  CycleEntryModel createDefault({required int userId}) {
    return CycleEntryModel(
      entryDate: DateTime.now(),
      userId: userId,
    );
  }

  /// Cria entrada de período
  CycleEntryModel createPeriodEntry({
    required int userId,
    required DateTime date,
    required MenstrualFlow flow,
    List<CycleSymptom>? symptoms,
  }) {
    return CycleEntryModel(
      entryDate: date,
      userId: userId,
      menstrualFlow: flow,
      symptoms: symptoms ?? [],
    );
  }

  /// Cria entrada de ovulação
  CycleEntryModel createOvulationEntry({
    required int userId,
    required DateTime date,
  }) {
    return CycleEntryModel(
      entryDate: date,
      userId: userId,
      ovulation: true,
    );
  }
}

/// Registry central de factories
/// 
/// Permite acesso centralizado a todas as factories
class ModelFactoryRegistry {
  static final ModelFactoryRegistry _instance = ModelFactoryRegistry._();
  static ModelFactoryRegistry get instance => _instance;

  ModelFactoryRegistry._();

  final userFactory = UserModelFactory();
  final waterIntakeFactory = WaterIntakeModelFactory();
  final sleepSessionFactory = SleepSessionModelFactory();
  final mealFactory = MealModelFactory();
  final moodFactory = MoodModelFactory();
  final activityFactory = ActivityModelFactory();
  final habitFactory = HabitModelFactory();
  final cycleEntryFactory = CycleEntryModelFactory();
}
