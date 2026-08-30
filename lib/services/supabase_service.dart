import 'package:fitnova/models/user_profile_model.dart';
import 'package:fitnova/services/WorkoutAIService.dart';
import 'package:fitnova/services/ai_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService();

  static const mealPlanExpiry = Duration(hours: 48);
  static const workoutPlanExpiry = Duration(days: 30);

  final SupabaseClient _supabase = Supabase.instance.client;

  //==========================================================
  // USER PROFILE
  //==========================================================

  Future<void> saveUserProfile(UserProfileModel profile) async {
    // -------------------------------
    // 1. Save Profile (without goal fields)
    // -------------------------------
    final profileData = profile.toJson();

    // Remove goal-specific fields
    profileData.remove('target_weight');
    profileData.remove('duration_months');
    profileData.remove('muscle_gain_target');
    profileData.remove('strength_goal');
    profileData.remove('primary_lift');
    profileData.remove('rep_range');
    profileData.remove('endurance_goal');
    profileData.remove('cardio_preference');
    profileData.remove('fitness_goals');
    profileData.remove('workout_place');
    profileData.remove('sport_name');
    profileData.remove('performance_goals');
    profileData.remove('competition_level');
    profileData.remove('workout_days');

    profileData['id'] = profile.uid;
    profileData['updated_at'] = DateTime.now().toIso8601String();

    await _supabase.from('profiles').upsert(profileData);

    // -------------------------------
    // 2. Save Goal Details
    // -------------------------------
    final goalResponse = await _supabase
        .from('goal_details')
        .upsert({'profile_id': profile.uid, 'goal_name': profile.goal})
        .select()
        .single();

    final goalId = goalResponse['id'];

    // -------------------------------
    // 3. Save goal_id inside profile
    // -------------------------------
    await _supabase
        .from('profiles')
        .update({'goal_id': goalId})
        .eq('id', profile.uid);

    // -------------------------------
    // 4. Remove old goal records
    // -------------------------------
    await Future.wait([
      _supabase.from('lose_weight_goals').delete().eq('goal_id', goalId),
      _supabase.from('weight_gain_goals').delete().eq('goal_id', goalId),
      _supabase.from('build_muscle_goals').delete().eq('goal_id', goalId),
      _supabase.from('strength_power_goals').delete().eq('goal_id', goalId),
      _supabase.from('endurance_goals').delete().eq('goal_id', goalId),
      _supabase.from('general_fitness_goals').delete().eq('goal_id', goalId),
      _supabase
          .from('athletic_performance_goals')
          .delete()
          .eq('goal_id', goalId),
    ]);

    // -------------------------------
    // 5. Save Selected Goal
    // -------------------------------

    switch (profile.goal) {
      case "Lose Weight":
        await _supabase.from('lose_weight_goals').insert({
          'goal_id': goalId,
          'target_weight': profile.targetWeight,
          'duration_months': profile.durationMonths,
          'workout_days': profile.workoutDays,
        });
        break;

      case "Weight Gain":
        await _supabase.from('weight_gain_goals').insert({
          'goal_id': goalId,
          'target_weight': profile.targetWeight,
          'duration_months': profile.durationMonths,
          'workout_days': profile.workoutDays,
        });
        break;

      case "Build Muscle":
        await _supabase.from('build_muscle_goals').insert({
          'goal_id': goalId,
          'muscle_gain_target': profile.muscleGainTarget,
          'workout_days': profile.workoutDays,
          'duration_months': profile.durationMonths,
        });
        break;

      case "Strength & Power":
        await _supabase.from('strength_power_goals').insert({
          'goal_id': goalId,
          'strength_goal': profile.strengthGoal,
          'primary_lift': profile.primaryLift,
          'rep_range': profile.repRange,
          'workout_days': profile.workoutDays,
          'duration_months': profile.durationMonths,
        });
        break;

      case "Improve Endurance":
        await _supabase.from('endurance_goals').insert({
          'goal_id': goalId,
          'endurance_goal': profile.enduranceGoal,
          'cardio_preference': profile.cardioPreference,
          'workout_days': profile.workoutDays,
          'duration_months': profile.durationMonths,
        });
        break;

      case "General Fitness":
        await _supabase.from('general_fitness_goals').insert({
          'goal_id': goalId,
          'fitness_goals': profile.fitnessGoals,
          'workout_place': profile.workoutPlace,
          'workout_days': profile.workoutDays,
          'duration_months': profile.durationMonths,
        });
        break;

      case "Athletic Performance":
        await _supabase.from('athletic_performance_goals').insert({
          'goal_id': goalId,
          'sport_name': profile.sportName,
          'performance_goals': profile.performanceGoals,
          'competition_level': profile.competitionLevel,
          'workout_days': profile.workoutDays,
          'duration_months': profile.durationMonths,
        });
        break;
    }
  }

  Future<UserProfileModel?> getUserProfile(String uid) async {
    // ------------------------------------------
    // 1. Fetch Profile
    // ------------------------------------------
    final profileResponse = await _supabase
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();

    if (profileResponse == null) return null;

    // ------------------------------------------
    // 2. Fetch Goal Details
    // ------------------------------------------
    final goalResponse = await _supabase
        .from('goal_details')
        .select()
        .eq('profile_id', uid)
        .maybeSingle();

    if (goalResponse == null) {
      return UserProfileModel.fromJson(profileResponse);
    }

    profileResponse['goal'] = goalResponse['goal_name'];

    final goalId = goalResponse['id'];

    Map<String, dynamic>? goalData;

    switch (goalResponse['goal_name']) {
      case "Lose Weight":
        goalData = await _supabase
            .from('lose_weight_goals')
            .select()
            .eq('goal_id', goalId)
            .maybeSingle();
        break;

      case "Weight Gain":
        goalData = await _supabase
            .from('weight_gain_goals')
            .select()
            .eq('goal_id', goalId)
            .maybeSingle();
        break;

      case "Build Muscle":
        goalData = await _supabase
            .from('build_muscle_goals')
            .select()
            .eq('goal_id', goalId)
            .maybeSingle();
        break;

      case "Strength & Power":
        goalData = await _supabase
            .from('strength_power_goals')
            .select()
            .eq('goal_id', goalId)
            .maybeSingle();
        break;

      case "Improve Endurance":
        goalData = await _supabase
            .from('endurance_goals')
            .select()
            .eq('goal_id', goalId)
            .maybeSingle();
        break;

      case "General Fitness":
        goalData = await _supabase
            .from('general_fitness_goals')
            .select()
            .eq('goal_id', goalId)
            .maybeSingle();
        break;

      case "Athletic Performance":
        goalData = await _supabase
            .from('athletic_performance_goals')
            .select()
            .eq('goal_id', goalId)
            .maybeSingle();
        break;
    }

    if (goalData != null) {
      profileResponse.addAll(goalData);
    }

    return UserProfileModel.fromJson(profileResponse);
  }

  Future<void> updateUserProfile(UserProfileModel profile) async {
    await _supabase
        .from('profiles')
        .update({
          ...profile.toJson(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', profile.uid);
  }

  Future<void> deleteUserProfile(String uid) async {
    await _supabase.from('profiles').delete().eq('id', uid);
  }

  //==========================================================
  // MEAL PLAN
  //==========================================================

  Future<void> saveMealPlan(String uid, Map<String, dynamic> mealPlan) async {
    final generatedAt = DateTime.now();
    final expiresAt = generatedAt.add(mealPlanExpiry);

    await _supabase.from('meal_plans').upsert({
      'user_id': uid,
      'generated_at': generatedAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'plan': mealPlan,
      'is_active': true,
    });
  }

  Future<Map<String, dynamic>?> getMealPlan(String uid) async {
    final response = await _supabase
        .from('meal_plans')
        .select()
        .eq('user_id', uid)
        .order('generated_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Map<String, dynamic>.from(response['plan']);
  }

  Future<void> deleteMealPlan(String uid) async {
    await _supabase.from('meal_plans').delete().eq('user_id', uid);
  }

  Future<void> deactivateMealPlan(String uid) async {
    await _supabase
        .from('meal_plans')
        .update({'is_active': false})
        .eq('user_id', uid);
  }

  Future<bool> hasMealPlan(String uid) async {
    final response = await _supabase
        .from('meal_plans')
        .select('id')
        .eq('user_id', uid)
        .limit(1)
        .maybeSingle();

    return response != null;
  }
  //==========================================================
  // WORKOUT PLAN
  //==========================================================

  Future<void> saveWorkoutPlan(
    String uid,
    Map<String, dynamic> workoutPlan,
  ) async {
    final generatedAt = DateTime.now();
    final expiresAt = generatedAt.add(workoutPlanExpiry);

    await _supabase.from('workout_plans').upsert({
      'user_id': uid,
      'generated_at': generatedAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'plan': workoutPlan,
      'is_active': true,
    });
  }

  Future<Map<String, dynamic>?> getWorkoutPlan(String uid) async {
    final response = await _supabase
        .from('workout_plans')
        .select()
        .eq('user_id', uid)
        .order('generated_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Map<String, dynamic>.from(response['plan']);
  }

  Future<void> deleteWorkoutPlan(String uid) async {
    await _supabase.from('workout_plans').delete().eq('user_id', uid);
  }

  Future<void> deactivateWorkoutPlan(String uid) async {
    await _supabase
        .from('workout_plans')
        .update({'is_active': false})
        .eq('user_id', uid);
  }

  Future<bool> hasWorkoutPlan(String uid) async {
    final response = await _supabase
        .from('workout_plans')
        .select('id')
        .eq('user_id', uid)
        .limit(1)
        .maybeSingle();

    return response != null;
  }

  //==========================================================
  // PLAN HELPERS
  //==========================================================

  bool isPlanExpired(Map<String, dynamic> plan) {
    final expiresAt = plan['expiresAt'] ?? plan['expires_at'];

    if (expiresAt == null) {
      return true;
    }

    try {
      final expiry = DateTime.parse(expiresAt.toString());

      return DateTime.now().isAfter(expiry);
    } catch (_) {
      return true;
    }
  }

  Duration getRemainingTime(Map<String, dynamic> plan) {
    final expiresAt = plan['expiresAt'] ?? plan['expires_at'];

    if (expiresAt == null) {
      return Duration.zero;
    }

    try {
      final expiry = DateTime.parse(expiresAt.toString());

      final remaining = expiry.difference(DateTime.now());

      return remaining.isNegative ? Duration.zero : remaining;
    } catch (_) {
      return Duration.zero;
    }
  }

  String formatRemainingTime(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return "$days Day${days == 1 ? "" : "s"} "
          "$hours Hour${hours == 1 ? "" : "s"}";
    }

    if (hours > 0) {
      return "$hours Hour${hours == 1 ? "" : "s"} "
          "$minutes Min";
    }

    return "$minutes Min";
  }

  //==========================================================
  // PROGRESS
  //==========================================================

  double getPlanProgress(Map<String, dynamic> plan) {
    final createdAt =
        plan['generatedAt'] ??
        plan['generated_at'] ??
        plan['createdAt'] ??
        plan['created_at'];

    if (createdAt == null) {
      return 0;
    }

    try {
      final created = DateTime.parse(createdAt.toString());

      final expiry = created.add(mealPlanExpiry);

      final total = mealPlanExpiry.inSeconds;

      final remaining = expiry.difference(DateTime.now()).inSeconds;

      return (remaining / total).clamp(0.0, 1.0);
    } catch (_) {
      return 0;
    }
  }

  double getWorkoutProgress(DateTime createdAt) {
    final expiry = createdAt.add(workoutPlanExpiry);

    final remaining = expiry.difference(DateTime.now()).inSeconds;

    return (remaining / workoutPlanExpiry.inSeconds).clamp(0.0, 1.0);
  }

  Duration getWorkoutRemaining(DateTime createdAt) {
    final expiry = createdAt.add(workoutPlanExpiry);

    final remaining = expiry.difference(DateTime.now());

    return remaining.isNegative ? Duration.zero : remaining;
  }

  String formatWorkoutRemaining(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return "$days Day${days == 1 ? "" : "s"} "
          "$hours Hour${hours == 1 ? "" : "s"}";
    }

    if (hours > 0) {
      return "$hours Hour${hours == 1 ? "" : "s"} "
          "$minutes Min";
    }

    return "$minutes Min";
  }
  //==========================================================
  // AI GENERATION
  //==========================================================

  Future<void> generateAndSaveMealPlan(String uid) async {
    final profile = await getUserProfile(uid);

    if (profile == null) {
      throw Exception("User profile not found.");
    }

    final mealPlan = await AIService().generateMealPlan(profile);

    final generatedAt = DateTime.now();
    final expiresAt = generatedAt.add(mealPlanExpiry);

    mealPlan["generatedAt"] = generatedAt.toIso8601String();
    mealPlan["expiresAt"] = expiresAt.toIso8601String();

    await _supabase.from('meal_plans').upsert({
      'user_id': uid,
      'generated_at': generatedAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'plan': mealPlan,
      'is_active': true,
    });
  }

  Future<void> generateAndSaveWorkoutPlan(String uid) async {
    final profile = await getUserProfile(uid);

    if (profile == null) {
      throw Exception("User profile not found.");
    }

    final workoutPlan = await WorkoutAIService().generateWorkoutPlan(profile);

    final generatedAt = DateTime.now();
    final expiresAt = generatedAt.add(workoutPlanExpiry);

    workoutPlan["generatedAt"] = generatedAt.toIso8601String();
    workoutPlan["expiresAt"] = expiresAt.toIso8601String();

    await _supabase.from('workout_plans').upsert({
      'user_id': uid,
      'generated_at': generatedAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'plan': workoutPlan,
      'is_active': true,
    });
  }

  Future<void> generateAndSavePlans(String uid) async {
    final profile = await getUserProfile(uid);

    if (profile == null) {
      throw Exception("User profile not found.");
    }

    final results = await Future.wait([
      AIService().generateMealPlan(profile),
      WorkoutAIService().generateWorkoutPlan(profile),
    ]);

    final mealPlan = Map<String, dynamic>.from(results[0]);
    final workoutPlan = Map<String, dynamic>.from(results[1]);

    final generatedAt = DateTime.now();

    final mealExpiry = generatedAt.add(mealPlanExpiry);
    final workoutExpiry = generatedAt.add(workoutPlanExpiry);

    mealPlan["generatedAt"] = generatedAt.toIso8601String();
    mealPlan["expiresAt"] = mealExpiry.toIso8601String();

    workoutPlan["generatedAt"] = generatedAt.toIso8601String();
    workoutPlan["expiresAt"] = workoutExpiry.toIso8601String();

    await Future.wait([
      _supabase.from('meal_plans').upsert({
        'user_id': uid,
        'generated_at': generatedAt.toIso8601String(),
        'expires_at': mealExpiry.toIso8601String(),
        'plan': mealPlan,
        'is_active': true,
      }),

      _supabase.from('workout_plans').upsert({
        'user_id': uid,
        'generated_at': generatedAt.toIso8601String(),
        'expires_at': workoutExpiry.toIso8601String(),
        'plan': workoutPlan,
        'is_active': true,
      }),
    ]);
  }
}
