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

  // ============================================================
  // GENERATE + ENRICH + SAVE
  // ============================================================

  Future<WorkoutPlanModel> generateAndSaveWorkoutPlan(
    UserProfileModel profile,
  ) async {
    // ----------------------------------------------------------
    // 1. Gemini creates weekly programming.
    // ----------------------------------------------------------

    final geminiResponse = await _aiService.generateWorkoutPlan(profile);

    // ----------------------------------------------------------
    // 2. Convert Gemini JSON to model.
    // ----------------------------------------------------------

    final generatedPlan = WorkoutPlanModel.fromMap({
      ...geminiResponse,
      'createdAt': DateTime.now().toIso8601String(),
    });

    // ----------------------------------------------------------
    // 3. Enrich with Supabase ExerciseDB data.
    // ----------------------------------------------------------

    final enrichedPlan = await _enrichPlanWithCatalog(generatedPlan);

    // ----------------------------------------------------------
    // 4. Save complete plan.
    // ----------------------------------------------------------

    await saveWorkoutPlan(enrichedPlan);

    return enrichedPlan;
  }

  // ============================================================
  // ENRICH PLAN
  // ============================================================

  Future<WorkoutPlanModel> _enrichPlanWithCatalog(WorkoutPlanModel plan) async {
    final Map<String, WorkoutDayModel> enrichedDays = {};

    // ----------------------------------------------------------
    // Collect all main workout exercise names.
    // ----------------------------------------------------------

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

    // ----------------------------------------------------------
    // Fetch catalog records in one query.
    // ----------------------------------------------------------

    final catalogExercises = await _catalogService.findByNames(exerciseNames);

    // ----------------------------------------------------------
    // Build normalized lookup map.
    // ----------------------------------------------------------

    final Map<String, dynamic> catalogMap = {};

    for (final catalog in catalogExercises) {
      catalogMap[ExerciseCatalogService.normalizeExerciseName(
            catalog.exerciseName,
          )] =
          catalog;
    }

    // ----------------------------------------------------------
    // Enrich each workout day.
    // ----------------------------------------------------------

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

        // ------------------------------------------------------
        // Fallback to best-match lookup.
        // ------------------------------------------------------

        if (catalog == null) {
          catalog = await _catalogService.findBestMatch(exercise.exerciseName);
        }

        // ------------------------------------------------------
        // No match: keep Gemini programming.
        // ------------------------------------------------------

        if (catalog == null) {
          enrichedExercises.add(exercise);

          continue;
        }

        // ------------------------------------------------------
        // Merge Supabase ExerciseDB data.
        // ------------------------------------------------------

        enrichedExercises.add(
          exercise.copyWith(
            exerciseDbId: catalog.exerciseDbId,

            gifUrl: catalog.gifUrl,

            bodyParts: catalog.bodyParts,

            targetMuscles: catalog.targetMuscles,

            catalogSecondaryMuscles: catalog.secondaryMuscles,

            catalogInstructions: catalog.instructions,

            // Supabase is authoritative
            // for ExerciseDB equipment.
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
