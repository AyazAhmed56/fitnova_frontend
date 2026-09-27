import 'package:fitnova/models/user_profile_model.dart';
import 'package:fitnova/services/WorkoutAIService.dart';
import 'package:fitnova/services/ai_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService();

  static const mealPlanExpiry = Duration(hours: 48);

  static const workoutPlanExpiry = Duration(days: 30);

  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================
  // SAVE USER PROFILE
  // ============================================================

  Future<void> saveUserProfile(UserProfileModel profile) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    final authUid = user.id;

    // profiles.id must always be auth.uid
    final profileId = authUid;

    // ----------------------------------------------------------
    // 1. Save Profile
    // ----------------------------------------------------------

    final profileData = profile.toJson();

    // These fields belong to goal_details
    // or goal-specific tables.
    profileData.remove('goal');
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

    profileData['id'] = profileId;

    profileData['updated_at'] = DateTime.now().toIso8601String();

    await _supabase.from('profiles').upsert(profileData);

    // ----------------------------------------------------------
    // 2. Save Goal Details
    // ----------------------------------------------------------

    final goalResponse = await _supabase
        .from('goal_details')
        .upsert({
          'profile_id': profileId,
          'goal_name': profile.goal,
        }, onConflict: 'profile_id')
        .select()
        .single();

    final goalId = goalResponse['id'].toString();

    // ----------------------------------------------------------
    // 3. Link Goal To Profile
    // ----------------------------------------------------------

    await _supabase
        .from('profiles')
        .update({'goal_id': goalId})
        .eq('id', profileId);

    // ----------------------------------------------------------
    // 4. Delete Previous Goal Record
    // ----------------------------------------------------------

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

    // ----------------------------------------------------------
    // 5. Insert Selected Goal
    // ----------------------------------------------------------

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

      default:
        throw Exception('Unsupported goal: ${profile.goal}');
    }
  }

  // ============================================================
  // GET USER PROFILE
  // ============================================================

  Future<UserProfileModel?> getUserProfile(String uid) async {
    // ----------------------------------------------------------
    // 1. Fetch Profile
    // ----------------------------------------------------------

    final profileResponse = await _supabase
        .from('profiles')
        .select(
          'id, '
          'full_name, '
          'phone, '
          'age, '
          'gender, '
          'height, '
          'weight, '
          'activity_level, '
          'dietary_preferences, '
          'allergies, '
          'comments, '
          'meals_per_day, '
          'sleep_hours, '
          'water_intake, '
          'job, '
          'office_time, '
          'break_time, '
          'workout_time, '
          'exercise, '
          'wake_up, '
          'budget, '
          'workout_prefer, '
          'equipment_prefer, '
          'split, '
          'custom_split, '
          'skin_tone, '
          'skin_concerns, '
          'hair_type, '
          'hair_concerns, '
          'scalp_type, '
          'body_type, '
          'body_goal, '
          'fitness_level, '
          'created_at, '
          'updated_at, '
          'goal_id',
        )
        .eq('id', uid)
        .maybeSingle();

    if (profileResponse == null) {
      return null;
    }

    // ----------------------------------------------------------
    // 2. Fetch Goal Details
    // ----------------------------------------------------------

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

    // ----------------------------------------------------------
    // 3. Fetch Goal Specific Data
    // ----------------------------------------------------------

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

  // ============================================================
  // UPDATE PROFILE FIELDS
  // ============================================================

  Future<void> updateProfileFields(
    String profileId,
    Map<String, dynamic> fields,
  ) async {
    if (fields.isEmpty) {
      return;
    }

    await Supabase.instance.client
        .from('profiles')
        .update({...fields, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', profileId);
  }

  // ============================================================
  // UPDATE COMPLETE USER PROFILE
  // ============================================================

  Future<void> updateUserProfile(UserProfileModel profile) async {
    final data = profile.toJson();

    // These belong to goal tables.
    data.remove('goal');
    data.remove('target_weight');
    data.remove('duration_months');
    data.remove('muscle_gain_target');
    data.remove('strength_goal');
    data.remove('primary_lift');
    data.remove('rep_range');
    data.remove('endurance_goal');
    data.remove('cardio_preference');
    data.remove('fitness_goals');
    data.remove('workout_place');
    data.remove('sport_name');
    data.remove('performance_goals');
    data.remove('competition_level');
    data.remove('workout_days');

    data['updated_at'] = DateTime.now().toIso8601String();

    await _supabase.from('profiles').update(data).eq('id', profile.uid);
  }

  // ============================================================
  // GET SPECIFIC PROFILE FIELDS
  // ============================================================

  Future<Map<String, dynamic>?> getProfileFields(
    String profileId,
    String columns,
  ) async {
    return await _supabase
        .from('profiles')
        .select(columns)
        .eq('id', profileId)
        .maybeSingle();
  }

  // ============================================================
  // GET CURRENT GOAL ID
  // ============================================================

  Future<String?> getCurrentGoalId(String profileId) async {
    final data = await _supabase
        .from('goal_details')
        .select('id')
        .eq('profile_id', profileId)
        .maybeSingle();

    return data?['id']?.toString();
  }

  // ============================================================
  // UPDATE CURRENT GOAL WORKOUT SETTINGS
  //
  // THIS IS THE NEW / CORRECT METHOD
  // ============================================================

  Future<void> updateCurrentGoalWorkoutSettings({
    required String profileId,
    required String workoutPrefer,
    required String equipmentPrefer,
    required String split,
    required String fitnessLevel,
    required int workoutDays,
    String? workoutPlace,
    Map<String, String>? customSplit,
  }) async {
    // ----------------------------------------------------------
    // 1. Update Workout Preferences in profiles
    // ----------------------------------------------------------

    await updateProfileFields(profileId, {
      'workout_prefer': workoutPrefer,

      'equipment_prefer': equipmentPrefer,

      'split': split,

      // Custom split is saved as JSONB.
      //
      // If split != Custom:
      // customSplit will be null and old
      // custom data will be cleared.
      //
      // If split == Custom:
      // customSplit contains Monday-Sunday.
      'custom_split': customSplit,

      'fitness_level': fitnessLevel,
    });

    // ----------------------------------------------------------
    // 2. Get Current Goal
    // ----------------------------------------------------------

    final goalDetails = await _supabase
        .from('goal_details')
        .select('id, goal_name')
        .eq('profile_id', profileId)
        .maybeSingle();

    if (goalDetails == null) {
      throw Exception('Goal details not found. Please set a goal first.');
    }

    final goalId = goalDetails['id'].toString();

    final goalName = goalDetails['goal_name']?.toString() ?? '';

    // ----------------------------------------------------------
    // 3. Map Goal Name To Goal Table
    // ----------------------------------------------------------

    const Map<String, String> goalTables = {
      'Lose Weight': 'lose_weight_goals',

      'Weight Gain': 'weight_gain_goals',

      'Build Muscle': 'build_muscle_goals',

      'Strength & Power': 'strength_power_goals',

      'Improve Endurance': 'endurance_goals',

      'General Fitness': 'general_fitness_goals',

      'Athletic Performance': 'athletic_performance_goals',
    };

    final table = goalTables[goalName];

    if (table == null) {
      throw Exception('Unsupported goal: $goalName');
    }

    // ----------------------------------------------------------
    // 4. Update Workout Days
    // ----------------------------------------------------------

    final Map<String, dynamic> goalFields = {'workout_days': workoutDays};

    // workout_place is stored in
    // general_fitness_goals according
    // to your current database design.
    if (goalName == 'General Fitness' &&
        workoutPlace != null &&
        workoutPlace.trim().isNotEmpty) {
      goalFields['workout_place'] = workoutPlace.trim();
    }

    // ----------------------------------------------------------
    // 5. Save Goal Settings
    // ----------------------------------------------------------

    await updateGoalTable(table: table, goalId: goalId, fields: goalFields);
  }

  // ============================================================
  // UPDATE ONLY WORKOUT DAYS
  // ============================================================

  Future<void> updateCurrentGoalWorkoutDays({
    required String profileId,
    required int workoutDays,
  }) async {
    final goalDetails = await _supabase
        .from('goal_details')
        .select('id, goal_name')
        .eq('profile_id', profileId)
        .maybeSingle();

    if (goalDetails == null) {
      throw Exception('Goal details not found. Please set a goal first.');
    }

    final goalId = goalDetails['id'].toString();

    final goalName = goalDetails['goal_name']?.toString() ?? '';

    const Map<String, String> goalTables = {
      'Lose Weight': 'lose_weight_goals',

      'Weight Gain': 'weight_gain_goals',

      'Build Muscle': 'build_muscle_goals',

      'Strength & Power': 'strength_power_goals',

      'Improve Endurance': 'endurance_goals',

      'General Fitness': 'general_fitness_goals',

      'Athletic Performance': 'athletic_performance_goals',
    };

    final table = goalTables[goalName];

    if (table == null) {
      throw Exception('Unsupported goal: $goalName');
    }

    await updateGoalTable(
      table: table,
      goalId: goalId,
      fields: {'workout_days': workoutDays},
    );
  }

  // ============================================================
  // DELETE USER PROFILE
  // ============================================================

  Future<void> deleteUserProfile(String uid) async {
    await _supabase.from('profiles').delete().eq('id', uid);
  }

  // ============================================================
  // GET OR CREATE GOAL DETAILS
  // ============================================================

  Future<String> getOrCreateGoalDetails({required String goalName}) async {
    final client = Supabase.instance.client;

    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    final authUid = user.id;

    final existing = await client
        .from('goal_details')
        .select('id, goal_name')
        .eq('profile_id', authUid)
        .maybeSingle();

    if (existing != null) {
      final goalId = existing['id'].toString();

      await client
          .from('goal_details')
          .update({'goal_name': goalName})
          .eq('id', goalId)
          .eq('profile_id', authUid);

      return goalId;
    }

    final inserted = await client
        .from('goal_details')
        .insert({'profile_id': authUid, 'goal_name': goalName})
        .select('id')
        .single();

    return inserted['id'].toString();
  }

  // ============================================================
  // UPDATE GOAL TABLE
  // ============================================================

  Future<void> updateGoalTable({
    required String table,
    required String goalId,
    required Map<String, dynamic> fields,
  }) async {
    final client = Supabase.instance.client;

    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    if (goalId.trim().isEmpty) {
      throw Exception('Goal ID cannot be empty.');
    }

    final data = <String, dynamic>{'goal_id': goalId, ...fields};

    await client.from(table).upsert(data, onConflict: 'goal_id');
  }

  // ============================================================
  // SAVE MEAL PLAN
  // ============================================================

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

  // ============================================================
  // GET MEAL PLAN
  // ============================================================

  Future<Map<String, dynamic>?> getMealPlan(String uid) async {
    final response = await _supabase
        .from('meal_plans')
        .select()
        .eq('user_id', uid)
        .eq('is_active', true)
        .order('generated_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    final expiresAt = response['expires_at'];

    if (expiresAt != null &&
        DateTime.now().isAfter(DateTime.parse(expiresAt.toString()))) {
      await deactivateMealPlan(uid);

      return null;
    }

    return Map<String, dynamic>.from(response['plan']);
  }

  // ============================================================
  // DELETE MEAL PLAN
  // ============================================================

  Future<void> deleteMealPlan(String uid) async {
    await _supabase.from('meal_plans').delete().eq('user_id', uid);
  }

  // ============================================================
  // DEACTIVATE MEAL PLAN
  // ============================================================

  Future<void> deactivateMealPlan(String uid) async {
    await _supabase
        .from('meal_plans')
        .update({'is_active': false})
        .eq('user_id', uid);
  }

  // ============================================================
  // CHECK MEAL PLAN
  // ============================================================

  Future<bool> hasMealPlan(String uid) async {
    final response = await _supabase
        .from('meal_plans')
        .select('id')
        .eq('user_id', uid)
        .limit(1)
        .maybeSingle();

    return response != null;
  }

  // ============================================================
  // SAVE WORKOUT PLAN
  // ============================================================

  Future<void> saveWorkoutPlan(
    String uid,
    Map<String, dynamic> workoutPlan,
  ) async {
    final generatedAt = DateTime.now();

    final expiresAt = generatedAt.add(workoutPlanExpiry);

    final existing = await _supabase
        .from('workout_plans')
        .select('id')
        .eq('user_id', uid)
        .limit(1)
        .maybeSingle();

    final data = <String, dynamic>{
      'user_id': uid,

      'generated_at': generatedAt.toIso8601String(),

      'expires_at': expiresAt.toIso8601String(),

      'plan': workoutPlan,

      'is_active': true,
    };

    if (existing != null) {
      await _supabase
          .from('workout_plans')
          .update({
            'generated_at': generatedAt.toIso8601String(),

            'expires_at': expiresAt.toIso8601String(),

            'plan': workoutPlan,

            'is_active': true,
          })
          .eq('id', existing['id']);
    } else {
      await _supabase.from('workout_plans').insert(data);
    }
  }

  // ============================================================
  // GET WORKOUT PLAN
  // ============================================================

  Future<Map<String, dynamic>?> getWorkoutPlan(String uid) async {
    final response = await _supabase
        .from('workout_plans')
        .select()
        .eq('user_id', uid)
        .eq('is_active', true)
        .order('generated_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    final expiresAt = response['expires_at'];

    if (expiresAt != null &&
        DateTime.now().isAfter(DateTime.parse(expiresAt.toString()))) {
      await deactivateWorkoutPlan(uid);

      return null;
    }

    return Map<String, dynamic>.from(response['plan']);
  }

  // ============================================================
  // DELETE WORKOUT PLAN
  // ============================================================

  Future<void> deleteWorkoutPlan(String uid) async {
    await _supabase.from('workout_plans').delete().eq('user_id', uid);
  }

  // ============================================================
  // DEACTIVATE WORKOUT PLAN
  // ============================================================

  Future<void> deactivateWorkoutPlan(String uid) async {
    await _supabase
        .from('workout_plans')
        .update({'is_active': false})
        .eq('user_id', uid);
  }

  // ============================================================
  // CHECK WORKOUT PLAN
  // ============================================================

  Future<bool> hasWorkoutPlan(String uid) async {
    final response = await _supabase
        .from('workout_plans')
        .select('id')
        .eq('user_id', uid)
        .limit(1)
        .maybeSingle();

    return response != null;
  }

  // ============================================================
  // CHECK PLAN EXPIRY
  // ============================================================

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

  // ============================================================
  // GET REMAINING PLAN TIME
  // ============================================================

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

  // ============================================================
  // FORMAT REMAINING TIME
  // ============================================================

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

  // ============================================================
  // MEAL PLAN PROGRESS
  // ============================================================

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

  // ============================================================
  // WORKOUT PLAN PROGRESS
  // ============================================================

  double getWorkoutProgress(DateTime createdAt) {
    final expiry = createdAt.add(workoutPlanExpiry);

    final remaining = expiry.difference(DateTime.now()).inSeconds;

    return (remaining / workoutPlanExpiry.inSeconds).clamp(0.0, 1.0);
  }

  // ============================================================
  // WORKOUT PLAN REMAINING TIME
  // ============================================================

  Duration getWorkoutRemaining(DateTime createdAt) {
    final expiry = createdAt.add(workoutPlanExpiry);

    final remaining = expiry.difference(DateTime.now());

    return remaining.isNegative ? Duration.zero : remaining;
  }

  // ============================================================
  // FORMAT WORKOUT REMAINING TIME
  // ============================================================

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

  // ============================================================
  // GENERATE AND SAVE MEAL PLAN
  // ============================================================

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

  // ============================================================
  // GENERATE AND SAVE WORKOUT PLAN
  // ============================================================

  Future<void> generateAndSaveWorkoutPlan(String uid) async {
    try {
      final profile = await getUserProfile(uid);

      if (profile == null) {
        throw Exception('User profile not found for user: $uid');
      }

      final workoutPlan = await WorkoutAIService().generateWorkoutPlan(profile);

      if (workoutPlan.isEmpty) {
        throw Exception('Workout AI returned an empty workout plan.');
      }

      final generatedAt = DateTime.now();

      final expiresAt = generatedAt.add(workoutPlanExpiry);

      final updatedWorkoutPlan = {
        ...workoutPlan,

        'generatedAt': generatedAt.toIso8601String(),

        'expiresAt': expiresAt.toIso8601String(),
      };

      await saveWorkoutPlan(uid, updatedWorkoutPlan);
    } catch (e, stackTrace) {
      print('======================================');

      print('WORKOUT GENERATION FAILED');

      print('ERROR: $e');

      print('STACK TRACE:');

      print(stackTrace);

      print('======================================');

      rethrow;
    }
  }

  // ============================================================
  // GENERATE AND SAVE BOTH PLANS
  // ============================================================

  Future<void> generateAndSavePlans(String uid) async {
    final profile = await getUserProfile(uid);

    if (profile == null) {
      throw Exception("Profile not found.");
    }

    // ----------------------------------------------------------
    // Generate Meal Plan
    // ----------------------------------------------------------

    final mealPlan = await AIService().generateMealPlan(profile);

    final generatedAt = DateTime.now();

    final updatedMealPlan = {
      ...mealPlan,

      "generatedAt": generatedAt.toIso8601String(),

      "expiresAt": generatedAt.add(mealPlanExpiry).toIso8601String(),
    };

    await saveMealPlan(uid, updatedMealPlan);

    // ----------------------------------------------------------
    // Generate Workout Plan
    // ----------------------------------------------------------

    final workoutPlan = await WorkoutAIService().generateWorkoutPlan(profile);

    final updatedWorkoutPlan = {
      ...workoutPlan,

      "generatedAt": generatedAt.toIso8601String(),

      "expiresAt": generatedAt.add(workoutPlanExpiry).toIso8601String(),
    };

    await saveWorkoutPlan(uid, updatedWorkoutPlan);
  }
}
