import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/workout_plan_model.dart';

class WorkoutSupabaseService {
  WorkoutSupabaseService._();

  static final WorkoutSupabaseService instance = WorkoutSupabaseService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  static const String table = 'workout_plans';

  // ============================================================
  // CURRENT USER
  // ============================================================

  String get _uid {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.id;
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> saveWorkoutPlan(WorkoutPlanModel workoutPlan) async {
    final now = DateTime.now();

    await _supabase.from(table).upsert({
      'user_id': _uid,
      'plan': workoutPlan.toMap(),
      'generated_at': now.toIso8601String(),
      'expires_at': now.add(const Duration(days: 30)).toIso8601String(),
      'is_active': true,
    }, onConflict: 'user_id');
  }

  // ============================================================
  // GET ACTIVE PLAN
  // ============================================================

  Future<WorkoutPlanModel?> getWorkoutPlan() async {
    final response = await _supabase
        .from(table)
        .select()
        .eq('user_id', _uid)
        .eq('is_active', true)
        .order('generated_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    final expiresAt = response['expires_at'];

    if (expiresAt != null) {
      final expiry = DateTime.tryParse(expiresAt.toString());

      if (expiry != null && DateTime.now().isAfter(expiry)) {
        await deactivateWorkoutPlan();
        return null;
      }
    }

    final plan = response['plan'];

    if (plan == null) {
      return null;
    }

    return WorkoutPlanModel.fromMap(Map<String, dynamic>.from(plan));
  }

  // ============================================================
  // EXISTS
  // ============================================================

  Future<bool> hasWorkoutPlan() async {
    final response = await _supabase
        .from(table)
        .select('id')
        .eq('user_id', _uid)
        .eq('is_active', true)
        .limit(1)
        .maybeSingle();

    return response != null;
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<void> updateWorkoutPlan(WorkoutPlanModel workoutPlan) async {
    await _supabase
        .from(table)
        .update({'plan': workoutPlan.toMap(), 'is_active': true})
        .eq('user_id', _uid);
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteWorkoutPlan() async {
    await _supabase.from(table).delete().eq('user_id', _uid);
  }

  // ============================================================
  // DEACTIVATE
  // ============================================================

  Future<void> deactivateWorkoutPlan() async {
    await _supabase
        .from(table)
        .update({'is_active': false})
        .eq('user_id', _uid);
  }

  // ============================================================
  // STREAM
  // ============================================================

  Stream<WorkoutPlanModel?> workoutStream() {
    return _supabase
        .from(table)
        .stream(primaryKey: ['id'])
        .eq('user_id', _uid)
        .map((rows) {
          if (rows.isEmpty) {
            return null;
          }

          final row = rows.first;

          if (row['is_active'] != true) {
            return null;
          }

          final plan = row['plan'];

          if (plan == null) {
            return null;
          }

          return WorkoutPlanModel.fromMap(Map<String, dynamic>.from(plan));
        });
  }

  // ============================================================
  // EXPIRED
  // ============================================================

  Future<bool> isWorkoutPlanExpired() async {
    final response = await _supabase
        .from(table)
        .select('expires_at')
        .eq('user_id', _uid)
        .eq('is_active', true)
        .order('generated_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) {
      return true;
    }

    final expiresAt = response['expires_at'];

    if (expiresAt == null) {
      return true;
    }

    final expiry = DateTime.tryParse(expiresAt.toString());

    if (expiry == null) {
      return true;
    }

    return DateTime.now().isAfter(expiry);
  }

  // ============================================================
  // REMAINING TIME
  // ============================================================

  Future<Duration> remainingTime() async {
    final response = await _supabase
        .from(table)
        .select('expires_at')
        .eq('user_id', _uid)
        .eq('is_active', true)
        .order('generated_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) {
      return Duration.zero;
    }

    final expiresAt = response['expires_at'];

    if (expiresAt == null) {
      return Duration.zero;
    }

    final expiry = DateTime.tryParse(expiresAt.toString());

    if (expiry == null) {
      return Duration.zero;
    }

    final remaining = expiry.difference(DateTime.now());

    if (remaining.isNegative) {
      return Duration.zero;
    }

    return remaining;
  }
}
