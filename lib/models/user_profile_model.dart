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

  final String skinTone;
  final List<String> skinConcerns;

  final String hairType;
  final List<String> hairConcerns;

  final String bodyType;
  final String bodyGoal;
  final String fitnessLevel;
  final String scalpType;

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
    required this.officeTime,
    required this.breakTime,
    required this.exercise,
    required this.wakeUp,
    required this.budget,
    required this.workoutPrefer,
    required this.equipmentPrefer,
    required this.split,
    required this.skinTone,
    required this.skinConcerns,
    required this.hairConcerns,
    required this.hairType,
    required this.bodyGoal,
    required this.bodyType,
    required this.fitnessLevel,
    required this.scalpType,
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
      uid: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',

      height: (json['height'] ?? 0).toDouble(),
      weight: (json['weight'] ?? 0).toDouble(),
      phone: json['phone'] ?? 0,

      goal: json['goal'] ?? '',

      targetWeight: (json['target_weight'] ?? 0).toDouble(),

      durationMonths: (json['duration_months'] ?? 0).toDouble(),

      muscleGainTarget: json['muscle_gain_target'] ?? '',

      strengthGoal: json['strength_goal'] ?? '',

      primaryLift: json['primary_lift'] ?? '',

      repRange: json['rep_range'] ?? '',

      enduranceGoal: json['endurance_goal'] ?? '',

      cardioPreference: json['cardio_preference'] ?? '',

      sportName: json['sport_name'] ?? '',

      fitnessGoals: List<String>.from(json['fitness_goals'] ?? []),

      performanceGoals: List<String>.from(json['performance_goals'] ?? []),

      workoutPlace: json['workout_place'] ?? '',

      competitionLevel: json['competition_level'] ?? '',

      workoutDays: json['workout_days'] ?? 0,

      activityLevel: json['activity_level'] ?? '',

      dietaryPreferences: List<String>.from(json['dietary_preferences'] ?? []),

      allergies: json['allergies'] ?? '',

      comments: json['comments'] ?? '',

      mealsPerDay: json['meals_per_day'] ?? '',

      sleepHours: json['sleep_hours'] ?? '',

      waterIntake: json['water_intake'] ?? '',

      job: json['job'] ?? '',

      officeTime: json['office_time'] ?? '',

      workoutTime: json['workout_time'] ?? '',

      breakTime: json['break_time'] ?? '',

      exercise: json['exercise'] ?? '',

      wakeUp: json['wake_up'] ?? '',

      budget: json['budget'] ?? '',

      workoutPrefer: json['workout_prefer'] ?? '',

      equipmentPrefer: json['equipment_prefer'] ?? '',

      split: json['split'] ?? '',

      skinConcerns: List<String>.from(json['skin_concerns'] ?? []),

      skinTone: json['skin_tone'] ?? '',

      hairConcerns: List<String>.from(json['hair_concerns'] ?? []),

      hairType: json['hair_type'] ?? '',

      bodyGoal: json['body_goal'] ?? '',

      bodyType: json['body_type'] ?? '',

      fitnessLevel: json['fitness_level'] ?? '',

      scalpType: json['scalp_type'] ?? '',
    );
  }
}
