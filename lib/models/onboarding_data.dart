class OnboardingData {
  static final OnboardingData instance = OnboardingData._();

  OnboardingData._();

  String fullName = '';
  int age = 0;
  String gender = '';
  double height = 0;
  double weight = 0;
  int phone = 0;

  String goal = '';
  // Lose Weight & Weight Gain
  double targetWeight = 0;
  // Build Muscle
  String muscleGainTarget = "";
  // Strength & Power
  String strengthGoal = "";
  String primaryLift = "";
  String repRange = "";
  // Improve Endurance
  String enduranceGoal = "";
  String cardioPreference = "";
  // General Fitness
  List<String> fitnessGoals = [];
  String workoutPlace = "";
  // Athletic Performance
  String sportName = "";
  List<String> performanceGoals = [];
  String competitionLevel = "";
  // Common
  int workoutDays = 0;
  double durationMonths = 0;

  String activityLevel = '';

  List<String> dietaryPreferences = [];
  String allergies = '';
  String comments = '';

  String mealsPerDay = '';
  String sleepHours = '';
  String waterIntake = '';
  String job = '';
  String workoutTime = '';
  String breakTime = '';
  String officeTime = '';
  String exercise = '';
  String wakeUp = '';
  String budget = '';
  String workoutPrefer = '';

  String equipmentPrefer = '';
  String split = '';

  String skinTone = "";
  List<String> skinConcerns = [];

  String hairType = "";
  List<String> hairConcerns = [];

  String bodyType = "";
  String bodyGoal = "";
  String fitnessLevel = "";
  String scalpType = "";
}
