import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fitnova/models/user_profile_model.dart';
import 'package:fitnova/services/supabase_service.dart';

class MyGoalsScreen extends StatefulWidget {
  const MyGoalsScreen({super.key});

  @override
  State<MyGoalsScreen> createState() => _MyGoalsScreenState();
}

class _MyGoalsScreenState extends State<MyGoalsScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  UserProfileModel? profile;

  bool isLoading = true;
  bool isSaving = false;

  String goal = '';
  String activityLevel = '';
  String bodyGoal = '';
  String fitnessLevel = '';

  String muscleGainTarget = '';
  String strengthGoal = '';
  String primaryLift = '';
  String repRange = '';

  String enduranceGoal = '';
  String cardioPreference = '';

  String sportName = '';
  String competitionLevel = '';

  int workoutDays = 3;

  List<String> fitnessGoals = [];
  List<String> performanceGoals = [];

  final targetWeightController = TextEditingController();
  final durationController = TextEditingController();

  final muscleGainTargetController = TextEditingController();
  final strengthGoalController = TextEditingController();
  final primaryLiftController = TextEditingController();
  final repRangeController = TextEditingController();

  final enduranceGoalController = TextEditingController();
  final cardioPreferenceController = TextEditingController();

  final sportNameController = TextEditingController();
  final competitionLevelController = TextEditingController();

  final List<String> goals = [
    "Weight Loss",
    "Weight Gain",
    "Muscle Gain",
    "Maintain Weight",
    "Improve Health",
  ];

  final List<String> activities = [
    "Sedentary",
    "Lightly Active",
    "Moderately Active",
    "Very Active",
    "Extra Active",
  ];

  final List<String> fitnessLevels = ["Beginner", "Intermediate", "Advanced"];

  final List<String> fitnessGoalOptions = [
    "General Fitness",
    "Better Health",
    "Fat Loss",
    "Muscle Gain",
    "Strength",
    "Endurance",
    "Flexibility",
    "Mobility",
    "Better Sleep",
    "Stress Reduction",
  ];

  final List<String> performanceGoalOptions = [
    "Improve Performance",
    "Increase Speed",
    "Increase Strength",
    "Increase Stamina",
    "Improve Agility",
    "Improve Power",
    "Competition Preparation",
  ];

  final List<String> bodyGoalsMale = [
    "Lean Bulk",
    "Clean Bulk",
    "Muscle Gain",
    "Fat Loss",
    "Body Recomposition",
    "Cutting",
    "Maintain",
  ];

  final List<String> bodyGoalsFemale = [
    "Weight Loss",
    "Fat Loss",
    "Lean & Toned",
    "Overall Wellness",
    "Maintain",
    "Slim Fit",
  ];

  final List<String> liftOptions = [
    "Squat",
    "Bench Press",
    "Deadlift",
    "Overhead Press",
    "Barbell Row",
    "Other",
  ];

  final List<String> repRangeOptions = [
    "1 - 3 Reps",
    "3 - 5 Reps",
    "5 - 8 Reps",
    "8 - 12 Reps",
    "12 - 15 Reps",
    "15+ Reps",
  ];

  final List<String> cardioOptions = [
    "Walking",
    "Running",
    "Cycling",
    "Swimming",
    "HIIT",
    "Jogging",
    "Sports",
    "Mixed Cardio",
  ];

  final List<String> competitionOptions = [
    "None",
    "Beginner",
    "Intermediate",
    "Advanced",
    "Professional",
  ];

  @override
  void initState() {
    super.initState();
    loadGoalData();
  }

  Future<void> loadGoalData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      final data = await _supabaseService.getUserProfile(user.id);

      if (data != null) {
        profile = data;

        goal = data.goal;
        activityLevel = data.activityLevel;
        bodyGoal = data.bodyGoal;
        fitnessLevel = data.fitnessLevel;

        targetWeightController.text = data.targetWeight == 0
            ? ''
            : data.targetWeight.toString();

        durationController.text = data.durationMonths == 0
            ? ''
            : data.durationMonths.toString();

        muscleGainTarget = data.muscleGainTarget;
        strengthGoal = data.strengthGoal;
        primaryLift = data.primaryLift;
        repRange = data.repRange;

        enduranceGoal = data.enduranceGoal;
        cardioPreference = data.cardioPreference;

        sportName = data.sportName;
        competitionLevel = data.competitionLevel;

        workoutDays = data.workoutDays == 0 ? 3 : data.workoutDays;

        fitnessGoals = List<String>.from(data.fitnessGoals);
        performanceGoals = List<String>.from(data.performanceGoals);

        muscleGainTargetController.text = data.muscleGainTarget;
        strengthGoalController.text = data.strengthGoal;
        primaryLiftController.text = data.primaryLift;
        repRangeController.text = data.repRange;

        enduranceGoalController.text = data.enduranceGoal;
        cardioPreferenceController.text = data.cardioPreference;

        sportNameController.text = data.sportName;
        competitionLevelController.text = data.competitionLevel;
      }
    } catch (e) {
      debugPrint("Goal loading error: $e");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<String> get bodyGoalOptions {
    if (profile?.gender.toLowerCase() == "female") {
      return bodyGoalsFemale;
    }

    return bodyGoalsMale;
  }

  void onGoalChanged(String value) {
    setState(() {
      goal = value;
    });
  }

  Future<void> updateGoal() async {
    if (profile == null) return;

    setState(() {
      isSaving = true;
    });

    try {
      final updatedProfile = UserProfileModel(
        uid: profile!.uid,
        fullName: profile!.fullName,
        age: profile!.age,
        gender: profile!.gender,
        height: profile!.height,
        weight: profile!.weight,
        phone: profile!.phone,

        // GOALS
        goal: goal,
        targetWeight:
            double.tryParse(targetWeightController.text.trim()) ??
            profile!.targetWeight,

        durationMonths:
            double.tryParse(durationController.text.trim()) ??
            profile!.durationMonths,

        muscleGainTarget: muscleGainTargetController.text.trim(),

        strengthGoal: strengthGoalController.text.trim(),

        primaryLift: primaryLiftController.text.trim(),

        repRange: repRangeController.text.trim(),

        enduranceGoal: enduranceGoalController.text.trim(),

        cardioPreference: cardioPreferenceController.text.trim(),

        sportName: sportNameController.text.trim(),

        performanceGoals: List<String>.from(performanceGoals),

        competitionLevel: competitionLevelController.text.trim(),

        workoutDays: workoutDays,

        activityLevel: activityLevel,

        fitnessGoals: List<String>.from(fitnessGoals),

        workoutPlace: profile!.workoutPlace,

        // DIET
        dietaryPreferences: profile!.dietaryPreferences,

        allergies: profile!.allergies,

        comments: profile!.comments,

        mealsPerDay: profile!.mealsPerDay,

        // DAILY ROUTINE
        sleepHours: profile!.sleepHours,

        waterIntake: profile!.waterIntake,

        job: profile!.job,

        workoutTime: profile!.workoutTime,

        breakTime: profile!.breakTime,

        officeTime: profile!.officeTime,

        exercise: profile!.exercise,

        wakeUp: profile!.wakeUp,

        budget: profile!.budget,

        // WORKOUT
        workoutPrefer: profile!.workoutPrefer,

        equipmentPrefer: profile!.equipmentPrefer,

        split: profile!.split,

        // SKIN
        skinTone: profile!.skinTone,

        skinConcerns: profile!.skinConcerns,

        // HAIR
        hairType: profile!.hairType,

        hairConcerns: profile!.hairConcerns,

        scalpType: profile!.scalpType,

        // BODY
        bodyType: profile!.bodyType,

        bodyGoal: bodyGoal,

        fitnessLevel: fitnessLevel,
      );

      await _supabaseService.updateUserProfile(updatedProfile);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Goals updated successfully."),
          backgroundColor: Color(0xFF3A6F4B),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update goals.\n$e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF24583A),
          ),
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    final validValue = items.contains(value) ? value : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: validValue,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _multiSelect(
    String title,
    List<String> options,
    List<String> selected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((item) {
            final isSelected = selected.contains(item);

            return FilterChip(
              label: Text(item),
              selected: isSelected,
              selectedColor: const Color(0xFFCFE8D7),
              checkmarkColor: const Color(0xFF24583A),
              onSelected: (value) {
                setState(() {
                  if (value) {
                    if (!selected.contains(item)) {
                      selected.add(item);
                    }
                  } else {
                    selected.remove(item);
                  }
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _goalSpecificFields() {
    switch (goal) {
      case "Weight Loss":
        return Column(
          children: [
            _textField(
              targetWeightController,
              "Target Weight (kg)",
              keyboardType: TextInputType.number,
            ),
            _textField(
              durationController,
              "Duration (Months)",
              keyboardType: TextInputType.number,
            ),
            _dropdown("Body Goal", bodyGoal, bodyGoalOptions, (value) {
              if (value != null) {
                setState(() => bodyGoal = value);
              }
            }),
          ],
        );

      case "Weight Gain":
        return Column(
          children: [
            _textField(
              targetWeightController,
              "Target Weight (kg)",
              keyboardType: TextInputType.number,
            ),
            _textField(
              durationController,
              "Duration (Months)",
              keyboardType: TextInputType.number,
            ),
            _textField(
              muscleGainTargetController,
              "Weight / Muscle Gain Target",
            ),
            _dropdown("Body Goal", bodyGoal, bodyGoalOptions, (value) {
              if (value != null) {
                setState(() => bodyGoal = value);
              }
            }),
          ],
        );

      case "Muscle Gain":
        return Column(
          children: [
            _textField(muscleGainTargetController, "Muscle Gain Target"),
            _dropdown("Fitness Experience", fitnessLevel, fitnessLevels, (
              value,
            ) {
              if (value != null) {
                setState(() => fitnessLevel = value);
              }
            }),
            _dropdown("Primary Lift", primaryLift, liftOptions, (value) {
              if (value != null) {
                setState(() {
                  primaryLift = value;
                  primaryLiftController.text = value;
                });
              }
            }),
            _dropdown("Preferred Rep Range", repRange, repRangeOptions, (
              value,
            ) {
              if (value != null) {
                setState(() {
                  repRange = value;
                  repRangeController.text = value;
                });
              }
            }),
            _dropdown("Body Goal", bodyGoal, bodyGoalOptions, (value) {
              if (value != null) {
                setState(() => bodyGoal = value);
              }
            }),
          ],
        );

      case "Maintain Weight":
        return Column(
          children: [
            _dropdown("Body Goal", bodyGoal, bodyGoalOptions, (value) {
              if (value != null) {
                setState(() => bodyGoal = value);
              }
            }),
            _dropdown("Fitness Experience", fitnessLevel, fitnessLevels, (
              value,
            ) {
              if (value != null) {
                setState(() => fitnessLevel = value);
              }
            }),
            _multiSelect("Fitness Goals", fitnessGoalOptions, fitnessGoals),
          ],
        );

      case "Improve Health":
        return Column(
          children: [
            _dropdown("Fitness Experience", fitnessLevel, fitnessLevels, (
              value,
            ) {
              if (value != null) {
                setState(() => fitnessLevel = value);
              }
            }),
            _dropdown("Cardio Preference", cardioPreference, cardioOptions, (
              value,
            ) {
              if (value != null) {
                setState(() {
                  cardioPreference = value;
                  cardioPreferenceController.text = value;
                });
              }
            }),
            _textField(enduranceGoalController, "Endurance Goal"),
            _multiSelect("Fitness Goals", fitnessGoalOptions, fitnessGoals),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Goals"), centerTitle: true),

      backgroundColor: const Color(0xFFF5F8F5),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),

          child: Column(
            children: [
              _sectionTitle("Main Goal"),

              _dropdown("Goal", goal, goals, (value) {
                if (value != null) {
                  onGoalChanged(value);
                }
              }),

              _dropdown("Activity Level", activityLevel, activities, (value) {
                if (value != null) {
                  setState(() {
                    activityLevel = value;
                  });
                }
              }),

              _sectionTitle("$goal Details"),

              _goalSpecificFields(),

              _sectionTitle("Workout Schedule"),

              _dropdown(
                "Workout Days Per Week",
                workoutDays.toString(),
                List.generate(7, (index) => "${index + 1}"),
                (value) {
                  if (value != null) {
                    setState(() {
                      workoutDays = int.parse(value);
                    });
                  }
                },
              ),

              _sectionTitle("Performance Goals"),

              _multiSelect(
                "Performance Goals",
                performanceGoalOptions,
                performanceGoals,
              ),

              _textField(sportNameController, "Sport / Activity Name"),

              _dropdown(
                "Competition Level",
                competitionLevel,
                competitionOptions,
                (value) {
                  if (value != null) {
                    setState(() {
                      competitionLevel = value;
                      competitionLevelController.text = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isSaving ? null : updateGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A6F4B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Update Goals",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    targetWeightController.dispose();
    durationController.dispose();

    muscleGainTargetController.dispose();
    strengthGoalController.dispose();
    primaryLiftController.dispose();
    repRangeController.dispose();

    enduranceGoalController.dispose();
    cardioPreferenceController.dispose();

    sportNameController.dispose();
    competitionLevelController.dispose();

    super.dispose();
  }
}
