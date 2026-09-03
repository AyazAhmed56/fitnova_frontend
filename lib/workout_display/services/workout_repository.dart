import 'package:fitnova/models/user_profile_model.dart';

import '../models/exercise_model.dart';
import '../models/workout_day_model.dart';
import '../models/workout_plan_model.dart';

import '../../services/WorkoutAIService.dart';

import 'exercise_catalog_service.dart';
import 'workout_supabase_service.dart';

class WorkoutRepository {
  WorkoutRepository._();

  static final WorkoutRepository instance = WorkoutRepository._();

  final WorkoutSupabaseService _supabaseService =
      WorkoutSupabaseService.instance;

  final ExerciseCatalogService _catalogService =
      ExerciseCatalogService.instance;

  final WorkoutAIService _aiService = WorkoutAIService();

  // GENERATE + ENRICH + SAVE
  Future<WorkoutPlanModel> generateAndSaveWorkoutPlan(
    UserProfileModel profile,
  ) async {
    final geminiResponse = await _aiService.generateWorkoutPlan(profile);

    final generatedPlan = WorkoutPlanModel.fromMap({
      ...geminiResponse,
      'createdAt': DateTime.now().toIso8601String(),
    });

    final enrichedPlan = await _enrichPlanWithCatalog(generatedPlan);

    await saveWorkoutPlan(enrichedPlan);

    return enrichedPlan;
  }

  Future<WorkoutPlanModel> _enrichPlanWithCatalog(WorkoutPlanModel plan) async {
    final Map<String, WorkoutDayModel> enrichedDays = {};

    final List<String> exerciseNames = [];

    for (final day in plan.days.values) {
      if (day.restDay) {
        continue;
      }

      for (final exercise in day.workout) {
        if (exercise.exerciseName.trim().isNotEmpty) {
          exerciseNames.add(exercise.exerciseName);
        }
      }
    }

    final catalogExercises = await _catalogService.findByNames(exerciseNames);

    final Map<String, dynamic> catalogMap = {};

    for (final catalog in catalogExercises) {
      catalogMap[ExerciseCatalogService.normalizeExerciseName(
            catalog.exerciseName,
          )] =
          catalog;
    }

    for (final entry in plan.days.entries) {
      final day = entry.value;

      if (day.restDay || day.workout.isEmpty) {
        enrichedDays[entry.key] = day;
        continue;
      }

      final enrichedExercises = <ExerciseModel>[];

      for (final exercise in day.workout) {
        final normalized = ExerciseCatalogService.normalizeExerciseName(
          exercise.exerciseName,
        );

        var catalog = catalogMap[normalized];

        if (catalog == null) {
          catalog = await _catalogService.findBestMatch(exercise.exerciseName);
        }

        if (catalog == null) {
          enrichedExercises.add(exercise);

          continue;
        }

        enrichedExercises.add(
          exercise.copyWith(
            // IMPORTANT:
            // Catalog name becomes the canonical displayed name.
            exerciseName: catalog.exerciseName,

            // ExerciseDB data
            exerciseDbId: catalog.exerciseDbId,
            gifUrl: catalog.gifUrl,
            bodyParts: catalog.bodyParts,
            targetMuscles: catalog.targetMuscles,
            catalogSecondaryMuscles: catalog.secondaryMuscles,
            catalogInstructions: catalog.instructions,

            // Supabase is authoritative for equipment.
            equipmentRequired: catalog.equipments.isNotEmpty
                ? catalog.equipments.join(', ')
                : exercise.equipmentRequired,
          ),
        );
      }

      enrichedDays[entry.key] = day.copyWith(workout: enrichedExercises);
    }

    return plan.copyWith(days: enrichedDays);
  }

  // ============================================================
  // PLAN
  // ============================================================

  Future<WorkoutPlanModel?> getWorkoutPlan() {
    return _supabaseService.getWorkoutPlan();
  }

  Stream<WorkoutPlanModel?> workoutStream() {
    return _supabaseService.workoutStream();
  }

  Future<void> saveWorkoutPlan(WorkoutPlanModel plan) {
    return _supabaseService.saveWorkoutPlan(plan);
  }

  Future<void> updateWorkoutPlan(WorkoutPlanModel plan) {
    return _supabaseService.updateWorkoutPlan(plan);
  }

  Future<void> deleteWorkoutPlan() {
    return _supabaseService.deleteWorkoutPlan();
  }

  Future<bool> hasWorkoutPlan() {
    return _supabaseService.hasWorkoutPlan();
  }

  Future<bool> isWorkoutPlanExpired() {
    return _supabaseService.isWorkoutPlanExpired();
  }

  Future<Duration> remainingTime() {
    return _supabaseService.remainingTime();
  }

  // ============================================================
  // DAY HELPERS
  // ============================================================

  Future<WorkoutDayModel?> getWorkoutDay(String dayKey) async {
    final plan = await getWorkoutPlan();

    if (plan == null) {
      return null;
    }

    return plan.getDay(dayKey);
  }

  Future<List<WorkoutDayModel>> getAllWorkoutDays() async {
    final plan = await getWorkoutPlan();

    if (plan == null) {
      return [];
    }

    return plan.allDays;
  }
}
