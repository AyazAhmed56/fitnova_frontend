class UserProfileModel {
  final String uid;

  final String fullName;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final int phone;

  final String goal;
  final double targetWeight;
  final double durationMonths;

  final String muscleGainTarget;
  final String strengthGoal;
  final String primaryLift;
  final String repRange;

  final String enduranceGoal;
  final String cardioPreference;

  final List<String> fitnessGoals;

  final String workoutPlace;
  final String sportName;

  final List<String> performanceGoals;

  final String competitionLevel;

  final int workoutDays;

  final String activityLevel;

  final List<String> dietaryPreferences;
  final String allergies;
  final String comments;

  final String mealsPerDay;
  final String sleepHours;
  final String waterIntake;

  final String job;
  final String workoutTime;
  final String breakTime;
  final String officeTime;
  final String exercise;
  final String wakeUp;
  final String budget;

  final String workoutPrefer;
  final String equipmentPrefer;

  final String split;

  // Custom weekly workout split.
  //
  // Example:
  // {
  //   "Monday": "Chest",
  //   "Tuesday": "Back",
  //   "Wednesday": "Legs",
  //   "Thursday": "Shoulders",
  //   "Friday": "Arms",
  //   "Saturday": "Full Body",
  //   "Sunday": "Rest"
  // }
  final Map<String, dynamic>? customSplit;

  final String skinTone;
  final List<String> skinConcerns;

  final String hairType;
  final List<String> hairConcerns;
  final String scalpType;

  final String bodyType;
  final String bodyGoal;

  final String fitnessLevel;

  UserProfileModel({
    required this.uid,

    required this.fullName,
    required this.age,
    required this.gender,

    required this.height,
    required this.weight,
    required this.phone,

    required this.goal,
    required this.targetWeight,
    required this.durationMonths,

    required this.muscleGainTarget,
    required this.strengthGoal,
    required this.primaryLift,
    required this.repRange,

    required this.enduranceGoal,
    required this.cardioPreference,

    required this.fitnessGoals,

    required this.workoutPlace,
    required this.sportName,

    required this.performanceGoals,

    required this.competitionLevel,

    required this.workoutDays,

    required this.activityLevel,

    required this.dietaryPreferences,
    required this.allergies,
    required this.comments,

    required this.mealsPerDay,
    required this.sleepHours,
    required this.waterIntake,

    required this.job,
    required this.workoutTime,
    required this.breakTime,
    required this.officeTime,
    required this.exercise,
    required this.wakeUp,
    required this.budget,

    required this.workoutPrefer,
    required this.equipmentPrefer,

    required this.split,

    // Optional so older code that creates
    // UserProfileModel does not break.
    this.customSplit,

    required this.skinTone,
    required this.skinConcerns,

    required this.hairType,
    required this.hairConcerns,
    required this.scalpType,

    required this.bodyType,
    required this.bodyGoal,

    required this.fitnessLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone': phone,
      'age': age,
      'gender': gender,

      'height': height,
      'weight': weight,

      'goal': goal,
      'target_weight': targetWeight,
      'duration_months': durationMonths,

      'muscle_gain_target': muscleGainTarget,

      'strength_goal': strengthGoal,

      'primary_lift': primaryLift,

      'rep_range': repRange,

      'endurance_goal': enduranceGoal,

      'cardio_preference': cardioPreference,

      'fitness_goals': fitnessGoals,

      'workout_place': workoutPlace,

      'sport_name': sportName,

      'performance_goals': performanceGoals,

      'competition_level': competitionLevel,

      'workout_days': workoutDays,

      'activity_level': activityLevel,

      'dietary_preferences': dietaryPreferences,

      'allergies': allergies,

      'comments': comments,

      'meals_per_day': mealsPerDay,

      'sleep_hours': sleepHours,

      'water_intake': waterIntake,

      'job': job,

      'office_time': officeTime,

      'break_time': breakTime,

      'workout_time': workoutTime,

      'exercise': exercise,

      'wake_up': wakeUp,

      'budget': budget,

      'workout_prefer': workoutPrefer,

      'equipment_prefer': equipmentPrefer,

      'split': split,

      // IMPORTANT:
      // Supabase column is custom_split,
      // not customSplit.
      'custom_split': customSplit,

      'skin_tone': skinTone,

      'skin_concerns': skinConcerns,

      'hair_type': hairType,

      'hair_concerns': hairConcerns,

      'scalp_type': scalpType,

      'body_type': bodyType,

      'body_goal': bodyGoal,

      'fitness_level': fitnessLevel,
    };
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      uid: json['id']?.toString() ?? '',

      fullName: json['full_name']?.toString() ?? '',

      age: _toInt(json['age']),

      gender: json['gender']?.toString() ?? '',

      height: _toDouble(json['height']),

      weight: _toDouble(json['weight']),

      phone: _toInt(json['phone']),

      goal: json['goal']?.toString() ?? '',

      targetWeight: _toDouble(json['target_weight']),

      durationMonths: _toDouble(json['duration_months']),

      muscleGainTarget: json['muscle_gain_target']?.toString() ?? '',

      strengthGoal: json['strength_goal']?.toString() ?? '',

      primaryLift: json['primary_lift']?.toString() ?? '',

      repRange: json['rep_range']?.toString() ?? '',

      enduranceGoal: json['endurance_goal']?.toString() ?? '',

      cardioPreference: json['cardio_preference']?.toString() ?? '',

      sportName: json['sport_name']?.toString() ?? '',

      fitnessGoals: _toStringList(json['fitness_goals']),

      performanceGoals: _toStringList(json['performance_goals']),

      workoutPlace: json['workout_place']?.toString() ?? '',

      competitionLevel: json['competition_level']?.toString() ?? '',

      workoutDays: _toInt(json['workout_days']),

      activityLevel: json['activity_level']?.toString() ?? '',

      dietaryPreferences: _toStringList(json['dietary_preferences']),

      allergies: json['allergies']?.toString() ?? '',

      comments: json['comments']?.toString() ?? '',

      mealsPerDay: json['meals_per_day']?.toString() ?? '',

      sleepHours: json['sleep_hours']?.toString() ?? '',

      waterIntake: json['water_intake']?.toString() ?? '',

      job: json['job']?.toString() ?? '',

      officeTime: json['office_time']?.toString() ?? '',

      workoutTime: json['workout_time']?.toString() ?? '',

      breakTime: json['break_time']?.toString() ?? '',

      exercise: json['exercise']?.toString() ?? '',

      wakeUp: json['wake_up']?.toString() ?? '',

      budget: json['budget']?.toString() ?? '',

      workoutPrefer: json['workout_prefer']?.toString() ?? '',

      equipmentPrefer: json['equipment_prefer']?.toString() ?? '',

      split: json['split']?.toString() ?? '',

      // IMPORTANT:
      // Read custom_split from Supabase.
      customSplit: _toMap(json['custom_split']),

      skinTone: json['skin_tone']?.toString() ?? '',

      skinConcerns: _toStringList(json['skin_concerns']),

      hairType: json['hair_type']?.toString() ?? '',

      hairConcerns: _toStringList(json['hair_concerns']),

      scalpType: json['scalp_type']?.toString() ?? '',

      bodyType: json['body_type']?.toString() ?? '',

      bodyGoal: json['body_goal']?.toString() ?? '',

      fitnessLevel: json['fitness_level']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) {
      return [];
    }

    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    return [];
  }

  static Map<String, dynamic>? _toMap(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }
}
