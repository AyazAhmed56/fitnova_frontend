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
    "Build Muscle",
    "Lose Weight",
    "Strength & Power",
    "Improve Endurance",
    "General Fitness",
    "Athletic Performance",
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

        // These are still stored in profiles.
        goal = data.goal;
        activityLevel = data.activityLevel;
        bodyGoal = data.bodyGoal;
        fitnessLevel = data.fitnessLevel;

        // Default values for UI.
        workoutDays = data.workoutDays == 0 ? 3 : data.workoutDays;

        // Load the selected goal's actual table.
        await _loadGoalSpecificData(profileId: data.uid, goalName: data.goal);
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

  Future<void> _loadGoalSpecificData({
    required String profileId,
    required String goalName,
  }) async {
    final client = Supabase.instance.client;

    final goalDetails = await client
        .from('goal_details')
        .select('id')
        .eq('profile_id', profileId)
        .maybeSingle();

    if (goalDetails == null) {
      return;
    }

    final goalId = goalDetails['id'].toString();

    switch (goalName) {
      case "Build Muscle":
        final data = await client
            .from('build_muscle_goals')
            .select()
            .eq('goal_id', goalId)
            .limit(1)
            .maybeSingle();

        if (data != null) {
          muscleGainTarget = data['muscle_gain_target']?.toString() ?? '';

          muscleGainTargetController.text = muscleGainTarget;

          workoutDays = data['workout_days'] ?? workoutDays;

          durationController.text = data['duration_months']?.toString() ?? '';
        }
        break;

      case "Lose Weight":
        final data = await client
            .from('lose_weight_goals')
            .select()
            .eq('goal_id', goalId)
            .limit(1)
            .maybeSingle();

        if (data != null) {
          targetWeightController.text = data['target_weight']?.toString() ?? '';

          durationController.text = data['duration_months']?.toString() ?? '';

          workoutDays = data['workout_days'] ?? workoutDays;
        }
        break;

      case "Strength & Power":
        final data = await client
            .from('strength_power_goals')
            .select()
            .eq('goal_id', goalId)
            .limit(1)
            .maybeSingle();

        if (data != null) {
          strengthGoal = data['strength_goal']?.toString() ?? '';

          primaryLift = data['primary_lift']?.toString() ?? '';

          repRange = data['rep_range']?.toString() ?? '';

          strengthGoalController.text = strengthGoal;

          primaryLiftController.text = primaryLift;

          repRangeController.text = repRange;

          workoutDays = data['workout_days'] ?? workoutDays;

          durationController.text = data['duration_months']?.toString() ?? '';
        }
        break;

      case "Improve Endurance":
        final data = await client
            .from('endurance_goals')
            .select()
            .eq('goal_id', goalId)
            .limit(1)
            .maybeSingle();

        if (data != null) {
          enduranceGoal = data['endurance_goal']?.toString() ?? '';

          cardioPreference = data['cardio_preference']?.toString() ?? '';

          enduranceGoalController.text = enduranceGoal;

          cardioPreferenceController.text = cardioPreference;

          workoutDays = data['workout_days'] ?? workoutDays;

          durationController.text = data['duration_months']?.toString() ?? '';
        }
        break;

      case "General Fitness":
        final data = await client
            .from('general_fitness_goals')
            .select()
            .eq('goal_id', goalId)
            .limit(1)
            .maybeSingle();

        if (data != null) {
          final value = data['fitness_goals']?.toString() ?? '';

          fitnessGoals = value.isEmpty
              ? []
              : value
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

          workoutDays = data['workout_days'] ?? workoutDays;
        }
        break;

      case "Athletic Performance":
        final data = await client
            .from('athletic_performance_goals')
            .select()
            .eq('goal_id', goalId)
            .limit(1)
            .maybeSingle();

        if (data != null) {
          sportName = data['sport_name']?.toString() ?? '';

          competitionLevel = data['competition_level']?.toString() ?? '';

          final performance = data['performance_goals']?.toString() ?? data['performance_goal']?.toString() ?? '';

          performanceGoals = performance.isEmpty
              ? []
              : performance
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

          sportNameController.text = sportName;

          competitionLevelController.text = competitionLevel;

          workoutDays = data['workout_days'] ?? workoutDays;

          durationController.text = data['duration_months']?.toString() ?? '';
        }
        break;
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
      final profileId = profile!.uid;

      /*
     * ----------------------------------------------------------
     * 1. UPDATE ONLY PROFILE FIELDS THAT BELONG TO PROFILES
     * ----------------------------------------------------------
     */

      final Map<String, dynamic> profileUpdates = {};

      if (activityLevel.trim().isNotEmpty &&
          activityLevel != profile!.activityLevel) {
        profileUpdates['activity_level'] = activityLevel.trim();
      }

      if (bodyGoal.trim().isNotEmpty && bodyGoal != profile!.bodyGoal) {
        profileUpdates['body_goal'] = bodyGoal.trim();
      }

      if (fitnessLevel.trim().isNotEmpty &&
          fitnessLevel != profile!.fitnessLevel) {
        profileUpdates['fitness_level'] = fitnessLevel.trim();
      }

      /*
     * Update profiles only when required.
     */
      if (profileUpdates.isNotEmpty) {
        await _supabaseService.updateProfileFields(profileId, profileUpdates);
      }

      /*
     * ----------------------------------------------------------
     * 2. GET / CREATE goal_details
     * ----------------------------------------------------------
     */

      if (goal.trim().isEmpty) {
        throw Exception("Please select a goal.");
      }

      final goalId = await _supabaseService.getOrCreateGoalDetails(
        profileId: profileId,
        goalName: goal.trim(),
      );

      /*
     * ----------------------------------------------------------
     * 3. LINK goal_details TO profiles
     * ----------------------------------------------------------
     */

      await _supabaseService.updateProfileFields(profileId, {
        'goal_id': goalId,
      });

      /*
     * ----------------------------------------------------------
     * 4. UPDATE THE CORRECT GOAL TABLE
     * ----------------------------------------------------------
     */

      switch (goal) {
        case "Build Muscle":
          await _saveBuildMuscleGoal(goalId);
          break;

        case "Lose Weight":
          await _saveLoseWeightGoal(goalId);
          break;

        case "Strength & Power":
          await _saveStrengthPowerGoal(goalId);
          break;

        case "Improve Endurance":
          await _saveEnduranceGoal(goalId);
          break;

        case "General Fitness":
          await _saveGeneralFitnessGoal(goalId);
          break;

        case "Athletic Performance":
          await _saveAthleticPerformanceGoal(goalId);
          break;

        default:
          throw Exception("Unsupported goal: $goal");
      }

      /*
     * ----------------------------------------------------------
     * DONE
     * ----------------------------------------------------------
     */

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goals updated successfully.'),
          backgroundColor: Color(0xFF3A6F4B),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update goals.\n$e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Future<void> _saveBuildMuscleGoal(String goalId) async {
    final Map<String, dynamic> fields = {};

    final target = muscleGainTargetController.text.trim();

    final duration = double.tryParse(durationController.text.trim());

    if (target.isNotEmpty) {
      fields['muscle_gain_target'] = target;
    }

    if (duration != null) {
      fields['duration_months'] = duration;
    }

    if (workoutDays > 0) {
      fields['workout_days'] = workoutDays;
    }

    if (fields.isEmpty) return;

    await _supabaseService.updateGoalTable(
      table: 'build_muscle_goals',
      goalId: goalId,
      fields: fields,
    );
  }

  Future<void> _saveLoseWeightGoal(String goalId) async {
    final Map<String, dynamic> fields = {};

    final targetWeight = double.tryParse(targetWeightController.text.trim());

    final duration = double.tryParse(durationController.text.trim());

    if (targetWeight != null) {
      fields['target_weight'] = targetWeight;
    }

    if (duration != null) {
      fields['duration_months'] = duration;
    }

    if (workoutDays > 0) {
      fields['workout_days'] = workoutDays;
    }

    if (fields.isEmpty) return;

    await _supabaseService.updateGoalTable(
      table: 'lose_weight_goals',
      goalId: goalId,
      fields: fields,
    );
  }

  Future<void> _saveStrengthPowerGoal(String goalId) async {
    final Map<String, dynamic> fields = {};

    final strength = strengthGoalController.text.trim();

    final lift = primaryLiftController.text.trim();

    final reps = repRangeController.text.trim();

    final duration = double.tryParse(durationController.text.trim());

    if (strength.isNotEmpty) {
      fields['strength_goal'] = strength;
    }

    if (lift.isNotEmpty) {
      fields['primary_lift'] = lift;
    }

    if (reps.isNotEmpty) {
      fields['rep_range'] = reps;
    }

    if (duration != null) {
      fields['duration_months'] = duration;
    }

    if (workoutDays > 0) {
      fields['workout_days'] = workoutDays;
    }

    if (fields.isEmpty) return;

    await _supabaseService.updateGoalTable(
      table: 'strength_power_goals',
      goalId: goalId,
      fields: fields,
    );
  }

  Future<void> _saveEnduranceGoal(String goalId) async {
    final Map<String, dynamic> fields = {};

    final endurance = enduranceGoalController.text.trim();

    final cardio = cardioPreferenceController.text.trim();

    final duration = double.tryParse(durationController.text.trim());

    if (endurance.isNotEmpty) {
      fields['endurance_goal'] = endurance;
    }

    if (cardio.isNotEmpty) {
      fields['cardio_preference'] = cardio;
    }

    if (duration != null) {
      fields['duration_months'] = duration;
    }

    if (workoutDays > 0) {
      fields['workout_days'] = workoutDays;
    }

    if (fields.isEmpty) return;

    await _supabaseService.updateGoalTable(
      table: 'endurance_goals',
      goalId: goalId,
      fields: fields,
    );
  }

  Future<void> _saveGeneralFitnessGoal(String goalId) async {
    final Map<String, dynamic> fields = {};

    if (fitnessGoals.isNotEmpty) {
      fields['fitness_goals'] = fitnessGoals.join(', ');
    }

    if (profile!.workoutPlace.trim().isNotEmpty) {
      fields['workout_place'] = profile!.workoutPlace.trim();
    }

    final duration = double.tryParse(durationController.text.trim());

    if (duration != null) {
      fields['duration_months'] = duration;
    }

    if (workoutDays > 0) {
      fields['workout_days'] = workoutDays;
    }

    if (fields.isEmpty) return;

    await _supabaseService.updateGoalTable(
      table: 'general_fitness_goals',
      goalId: goalId,
      fields: fields,
    );
  }

  Future<void> _saveAthleticPerformanceGoal(String goalId) async {
    final Map<String, dynamic> fields = {};

    final sport = sportNameController.text.trim();

    final competition = competitionLevelController.text.trim();

    if (sport.isNotEmpty) {
      fields['sport_name'] = sport;
    }

    if (performanceGoals.isNotEmpty) {
      fields['performance_goals'] = performanceGoals.join(', ');
    }

    if (competition.isNotEmpty) {
      fields['competition_level'] = competition;
    }

    final duration = double.tryParse(durationController.text.trim());

    if (duration != null) {
      fields['duration_months'] = duration;
    }

    if (workoutDays > 0) {
      fields['workout_days'] = workoutDays;
    }

    if (fields.isEmpty) return;

    await _supabaseService.updateGoalTable(
      table: 'athletic_performance_goals',
      goalId: goalId,
      fields: fields,
    );
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
      case "Build Muscle":
        return Column(
          children: [
            _textField(muscleGainTargetController, "Muscle Gain Target"),

            _textField(
              durationController,
              "Duration (Months)",
              keyboardType: TextInputType.number,
            ),
          ],
        );

      case "Lose Weight":
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
          ],
        );

      case "Strength & Power":
        return Column(
          children: [
            _textField(strengthGoalController, "Strength Goal"),

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

            _textField(
              durationController,
              "Duration (Months)",
              keyboardType: TextInputType.number,
            ),
          ],
        );

      case "Improve Endurance":
        return Column(
          children: [
            _textField(enduranceGoalController, "Endurance Goal / Target"),

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

            _textField(
              durationController,
              "Duration (Months)",
              keyboardType: TextInputType.number,
            ),
          ],
        );

      case "General Fitness":
        return Column(
          children: [
            _multiSelect("Fitness Goals", fitnessGoalOptions, fitnessGoals),

            _textField(
              durationController,
              "Duration (Months)",
              keyboardType: TextInputType.number,
            ),
          ],
        );

      case "Athletic Performance":
        return Column(
          children: [
            _textField(sportNameController, "Sport / Activity Name"),

            _multiSelect(
              "Performance Goals",
              performanceGoalOptions,
              performanceGoals,
            ),

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

            _textField(
              durationController,
              "Duration (Months)",
              keyboardType: TextInputType.number,
            ),
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
