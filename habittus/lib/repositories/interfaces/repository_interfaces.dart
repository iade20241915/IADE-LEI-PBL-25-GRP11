/// Design Pattern: REPOSITORY
/// 
/// O Repository Pattern abstrai a camada de acesso a dados,
/// permitindo trocar facilmente entre diferentes fontes de dados
/// (Supabase, Mock, Local Storage, etc.)
/// 
/// Benefícios:
/// - Separação entre lógica de negócio e acesso a dados
/// - Facilita testes unitários com mocks
/// - Permite trocar implementação sem afetar o resto do código
/// - Centraliza queries e operações de dados

import '../../models/user_model.dart';
import '../../models/water_intake_model.dart';
import '../../models/sleep_session_model.dart';
import '../../models/meal_model.dart';
import '../../models/mood_model.dart';
import '../../models/activity_model.dart';
import '../../models/habit_model.dart';
import '../../models/cycle_entry_model.dart';

/// Interface base para repositórios
abstract class BaseRepository<T> {
  Future<T?> getById(int id);
  Future<List<T>> getAll();
  Future<T> create(T entity);
  Future<T> update(T entity);
  Future<bool> delete(int id);
}

/// Interface para repositório de utilizadores
abstract class IUserRepository extends BaseRepository<UserModel> {
  Future<UserModel?> getByEmail(String email);
  Future<UserModel?> getCurrentUser();
  Future<bool> updateProfile(UserModel user);
}

/// Interface para repositório de consumo de água
abstract class IWaterIntakeRepository extends BaseRepository<WaterIntakeModel> {
  Future<List<WaterIntakeModel>> getByDate(int userId, DateTime date);
  Future<List<WaterIntakeModel>> getByDateRange(int userId, DateTime start, DateTime end);
  Future<WaterDailySummary> getDailySummary(int userId, DateTime date);
  Future<int> getTotalForDate(int userId, DateTime date);
  Future<WaterIntakeModel> addIntake(int userId, int amountMl, WaterSource source);
}

/// Interface para repositório de sessões de sono
abstract class ISleepSessionRepository extends BaseRepository<SleepSessionModel> {
  Future<SleepSessionModel?> getByDate(int userId, DateTime date);
  Future<List<SleepSessionModel>> getByDateRange(int userId, DateTime start, DateTime end);
  Future<SleepWeeklySummary> getWeeklySummary(int userId, DateTime weekStart);
  Future<SleepSessionModel> saveSleep(int userId, Duration duration, int qualityScore, DateTime date);
}

/// Interface para repositório de refeições
abstract class IMealRepository extends BaseRepository<MealModel> {
  Future<List<MealModel>> getByDate(int userId, DateTime date);
  Future<List<MealModel>> getByDateRange(int userId, DateTime start, DateTime end);
  Future<DailyCaloriesSummary> getDailySummary(int userId, DateTime date);
  Future<MealModel> addMeal(MealModel meal);
  Future<MealItemModel> addMealItem(int mealId, MealItemModel item);
  Future<bool> removeMealItem(int mealItemId);
}

/// Interface para repositório de alimentos
abstract class IFoodRepository extends BaseRepository<FoodModel> {
  Future<List<FoodModel>> search(String query);
  Future<List<FoodModel>> getPopular();
  Future<List<FoodModel>> getRecent(int userId);
}

/// Interface para repositório de humor
abstract class IMoodRepository extends BaseRepository<MoodModel> {
  Future<MoodModel?> getByDate(int userId, DateTime date);
  Future<List<MoodModel>> getByDateRange(int userId, DateTime start, DateTime end);
  Future<MoodModel> saveMood(MoodModel mood);
  Future<List<MoodTypeModel>> getMoodTypes();
}

/// Interface para repositório de atividades
abstract class IActivityRepository extends BaseRepository<ActivityModel> {
  Future<List<ActivityModel>> getByDate(int userId, DateTime date);
  Future<List<ActivityModel>> getByDateRange(int userId, DateTime start, DateTime end);
  Future<ActivityWeeklySummary> getWeeklySummary(int userId, DateTime weekStart);
  Future<ActivityModel> addActivity(ActivityModel activity);
  Future<List<ActivityTypeModel>> getActivityTypes();
  Future<List<ActivityCategoryModel>> getActivityCategories();
}

/// Interface para repositório de hábitos
abstract class IHabitRepository extends BaseRepository<HabitModel> {
  Future<List<HabitModel>> getByUser(int userId);
  Future<List<HabitModel>> getPositiveHabits(int userId);
  Future<List<HabitModel>> getNegativeHabits(int userId);
  Future<HabitModel> addHabit(HabitModel habit);
  Future<List<HabitTypeModel>> getHabitTypes();
  Future<HabitLogModel> logHabitCompletion(int habitId, DateTime date, bool completed);
  Future<List<HabitLogModel>> getHabitLogs(int habitId, DateTime start, DateTime end);
  Future<int> getCurrentStreak(int habitId);
}

/// Interface para repositório de ciclo menstrual
abstract class ICycleEntryRepository extends BaseRepository<CycleEntryModel> {
  Future<List<CycleEntryModel>> getByUser(int userId);
  Future<CycleEntryModel?> getByDate(int userId, DateTime date);
  Future<List<CycleEntryModel>> getByDateRange(int userId, DateTime start, DateTime end);
  Future<CycleEntryModel> saveEntry(CycleEntryModel entry);
  Future<CycleData> getCycleData(int userId);
  Future<DateTime?> getLastPeriodStart(int userId);
}

/// Interface para repositório de fotos
abstract class IPhotoRepository {
  Future<String> uploadPhoto(int userId, List<int> bytes, String filename);
  Future<List<String>> getPhotosByUser(int userId);
  Future<List<String>> getPhotosByDate(int userId, DateTime date);
  Future<bool> deletePhoto(int photoId);
}

/// Interface para repositório de metas
abstract class IGoalRepository {
  Future<Map<String, dynamic>?> getGoal(int userId, String goalType);
  Future<void> setGoal(int userId, String goalType, double target, String unit);
  Future<Map<String, Map<String, dynamic>>> getAllGoals(int userId);
}

/// Interface para repositório de lembretes
abstract class IReminderRepository {
  Future<List<Map<String, dynamic>>> getReminders(int userId);
  Future<Map<String, dynamic>> createReminder(int userId, Map<String, dynamic> reminder);
  Future<void> updateReminder(int reminderId, Map<String, dynamic> data);
  Future<bool> deleteReminder(int reminderId);
  Future<void> toggleReminder(int reminderId, bool enabled);
}
