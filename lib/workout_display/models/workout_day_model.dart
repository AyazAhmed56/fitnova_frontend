import 'cooldown_model.dart';
import 'exercise_model.dart';
import 'stretching_model.dart';
import 'warmup_model.dart';

class WorkoutDayModel {
  final String dayName;
  final String focus;
  final String difficulty;
  final String estimatedDuration;

  final String motivation;
  final String notes;

  final bool restDay;
  final String activity;

  final List<String> recoveryTips;
  final List<String> dailyTips;
  final List<String> precautions;

  final List<WarmupModel> warmUp;
  final List<ExerciseModel> workout;
  final List<StretchingModel> stretching;
  final List<CooldownModel> coolDown;

  const WorkoutDayModel({
    required this.dayName,
    required this.focus,
    required this.difficulty,
    required this.estimatedDuration,
    required this.motivation,
    required this.notes,
    required this.restDay,
    required this.activity,
    required this.recoveryTips,
    required this.dailyTips,
    required this.precautions,
    required this.warmUp,
    required this.workout,
    required this.stretching,
    required this.coolDown,
  });

  factory WorkoutDayModel.fromMap(Map<String, dynamic> map) {
    return WorkoutDayModel(
      dayName: map['dayName']?.toString() ?? '',
      focus: map['focus']?.toString() ?? '',
      difficulty: map['difficulty']?.toString() ?? '',
      estimatedDuration: map['estimatedDuration']?.toString() ?? '',

      motivation: map['motivation']?.toString() ?? '',
      notes: map['notes']?.toString() ?? '',

      restDay: _boolValue(map['restDay']),

      activity: map['activity']?.toString() ?? '',

      recoveryTips: _stringList(map['recoveryTips']),

      dailyTips: _stringList(map['dailyTips']),

      precautions: _stringList(map['precautions']),

      warmUp: _mapList(map['warmUp']).map(WarmupModel.fromMap).toList(),

      workout: _mapList(map['workout']).map(ExerciseModel.fromMap).toList(),

      stretching: _mapList(
        map['stretching'],
      ).map(StretchingModel.fromMap).toList(),

      coolDown: _mapList(map['coolDown']).map(CooldownModel.fromMap).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dayName': dayName,
      'focus': focus,
      'difficulty': difficulty,
      'estimatedDuration': estimatedDuration,

      'motivation': motivation,
      'notes': notes,

      'restDay': restDay,
      'activity': activity,

      'recoveryTips': recoveryTips,
      'dailyTips': dailyTips,
      'precautions': precautions,

      'warmUp': warmUp.map((e) => e.toMap()).toList(),

      'workout': workout.map((e) => e.toMap()).toList(),

      'stretching': stretching.map((e) => e.toMap()).toList(),

      'coolDown': coolDown.map((e) => e.toMap()).toList(),
    };
  }

  WorkoutDayModel copyWith({
    String? dayName,
    String? focus,
    String? difficulty,
    String? estimatedDuration,
    String? motivation,
    String? notes,
    bool? restDay,
    String? activity,
    List<String>? recoveryTips,
    List<String>? dailyTips,
    List<String>? precautions,
    List<WarmupModel>? warmUp,
    List<ExerciseModel>? workout,
    List<CooldownModel>? coolDown,
  }) {
    return WorkoutDayModel(
      dayName: dayName ?? this.dayName,
      focus: focus ?? this.focus,
      difficulty: difficulty ?? this.difficulty,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,

      motivation: motivation ?? this.motivation,
      notes: notes ?? this.notes,

      restDay: restDay ?? this.restDay,
      activity: activity ?? this.activity,

      recoveryTips: recoveryTips ?? this.recoveryTips,

      dailyTips: dailyTips ?? this.dailyTips,

      precautions: precautions ?? this.precautions,

      warmUp: warmUp ?? this.warmUp,

      workout: workout ?? this.workout,

      stretching: stretching,

      coolDown: coolDown ?? this.coolDown,
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value.map((e) => e.toString()).toList();
  }

  static List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static bool _boolValue(dynamic value) {
    if (value is bool) {
      return value;
    }

    return value?.toString().toLowerCase() == 'true';
  }
}
