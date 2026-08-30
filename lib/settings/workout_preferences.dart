import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fitnova/models/user_profile_model.dart';
import 'package:fitnova/services/supabase_service.dart';

class WorkoutPreferencesScreen extends StatefulWidget {
  const WorkoutPreferencesScreen({super.key});

  @override
  State<WorkoutPreferencesScreen> createState() =>
      _WorkoutPreferencesScreenState();
}

class _WorkoutPreferencesScreenState extends State<WorkoutPreferencesScreen> {
  final SupabaseService _service = SupabaseService();

  UserProfileModel? profile;

  bool isLoading = true;
  bool isSaving = false;

  String workoutPreference = "";
  String workoutPlace = "";
  String equipmentPreference = "";
  String workoutSplit = "";
  String fitnessLevel = "";
  String cardioPreference = "";
  String sportName = "";
  String competitionLevel = "";

  int workoutDays = 0;

  final List<String> workoutPreferenceOptions = [
    "Strength Training",
    "Weight Training",
    "Cardio",
    "HIIT",
    "Yoga",
    "Home Workout",
    "Gym Workout",
    "Sports",
    "Mixed Training",
  ];

  final List<String> workoutPlaceOptions = [
    "Gym",
    "Home",
    "Outdoor",
    "Both Gym & Home",
  ];

  final List<String> equipmentOptions = [
    "No Equipment",
    "Basic Equipment",
    "Full Gym Equipment",
    "Dumbbells",
    "Resistance Bands",
  ];

  final List<String> splitOptions = [
    "Full Body",
    "Upper / Lower",
    "Push / Pull / Legs",
    "Push / Pull",
    "Bro Split",
    "Custom",
  ];

  final List<String> fitnessLevelOptions = [
    "Beginner",
    "Intermediate",
    "Advanced",
  ];

  final List<String> cardioOptions = [
    "None",
    "Walking",
    "Running",
    "Cycling",
    "Swimming",
    "HIIT",
    "Mixed Cardio",
  ];

  final List<String> competitionOptions = [
    "None",
    "Recreational",
    "Amateur",
    "Competitive",
    "Professional",
  ];

  final Color primary = const Color(0xFF3A6F4B);
  final Color lightGreen = const Color(0xFFEAF4ED);

  @override
  void initState() {
    super.initState();

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final result = await _service.getUserProfile(user.id);

      if (result != null) {
        profile = result;

        workoutPreference = result.workoutPrefer;
        workoutPlace = result.workoutPlace;
        equipmentPreference = result.equipmentPrefer;
        workoutSplit = result.split;
        fitnessLevel = result.fitnessLevel;
        cardioPreference = result.cardioPreference;
        sportName = result.sportName;
        competitionLevel = result.competitionLevel;

        workoutDays = result.workoutDays;
      }
    } catch (e) {
      _showMessage("Failed to load workout preferences: $e", Colors.red);
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _savePreferences() async {
    if (profile == null) return;

    setState(() {
      isSaving = true;
    });

    try {
      final updatedProfile = UserProfileModel(
        uid: profile!.uid,

        // PROFILE
        fullName: profile!.fullName,
        age: profile!.age,
        gender: profile!.gender,
        height: profile!.height,
        weight: profile!.weight,
        phone: profile!.phone,

        // GOALS
        goal: profile!.goal,
        targetWeight: profile!.targetWeight,
        durationMonths: profile!.durationMonths,
        muscleGainTarget: profile!.muscleGainTarget,
        strengthGoal: profile!.strengthGoal,
        primaryLift: profile!.primaryLift,
        repRange: profile!.repRange,
        enduranceGoal: profile!.enduranceGoal,
        fitnessGoals: profile!.fitnessGoals,

        // WORKOUT - UPDATED
        workoutPlace: workoutPlace,
        sportName: sportName,
        performanceGoals: profile!.performanceGoals,
        competitionLevel: competitionLevel,
        workoutDays: workoutDays,
        activityLevel: profile!.activityLevel,

        // DIET
        dietaryPreferences: profile!.dietaryPreferences,
        allergies: profile!.allergies,
        comments: profile!.comments,
        mealsPerDay: profile!.mealsPerDay,

        // ROUTINE
        sleepHours: profile!.sleepHours,
        waterIntake: profile!.waterIntake,
        job: profile!.job,
        workoutTime: profile!.workoutTime,
        breakTime: profile!.breakTime,
        officeTime: profile!.officeTime,
        exercise: profile!.exercise,
        wakeUp: profile!.wakeUp,
        budget: profile!.budget,

        // WORKOUT PREFERENCES - UPDATED
        workoutPrefer: workoutPreference,
        equipmentPrefer: equipmentPreference,
        split: workoutSplit,

        // SKIN
        skinTone: profile!.skinTone,
        skinConcerns: profile!.skinConcerns,

        // HAIR
        hairType: profile!.hairType,
        hairConcerns: profile!.hairConcerns,
        scalpType: profile!.scalpType,

        // BODY
        bodyType: profile!.bodyType,
        bodyGoal: profile!.bodyGoal,
        fitnessLevel: fitnessLevel,

        // EXTRA WORKOUT
        cardioPreference: cardioPreference,
      );

      await _service.updateUserProfile(updatedProfile);

      profile = updatedProfile;

      if (!mounted) return;

      _showMessage("Workout preferences updated successfully.", Colors.green);

      Navigator.pop(context, true);
    } catch (e) {
      _showMessage("Failed to update workout preferences: $e", Colors.red);
    }

    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }

  void _showMessage(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Widget _dropdown({
    required String title,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : null,

        decoration: InputDecoration(
          labelText: title,
          prefixIcon: Icon(icon, color: primary),
          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),

        items: items
            .map(
              (item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)),
            )
            .toList(),

        onChanged: onChanged,
      ),
    );
  }

  Widget _textField({
    required String label,
    required String value,
    required IconData icon,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: TextFormField(
        initialValue: value,

        onChanged: onChanged,

        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primary),
          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: primary)),
      );
    }

    if (profile == null) {
      return const Scaffold(body: Center(child: Text("Profile not found")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F5),

      appBar: AppBar(
        title: const Text(
          "Workout Preferences",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F8F5),
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: primary,

                      child: const Icon(
                        Icons.fitness_center,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Workout Preferences",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "Customize how FitNova creates your workouts.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Training",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              _dropdown(
                title: "Workout Preference",
                value: workoutPreference,
                items: workoutPreferenceOptions,
                icon: Icons.fitness_center,
                onChanged: (value) {
                  setState(() {
                    workoutPreference = value ?? "";
                  });
                },
              ),

              _dropdown(
                title: "Workout Place",
                value: workoutPlace,
                items: workoutPlaceOptions,
                icon: Icons.location_on_outlined,
                onChanged: (value) {
                  setState(() {
                    workoutPlace = value ?? "";
                  });
                },
              ),

              _dropdown(
                title: "Equipment Preference",
                value: equipmentPreference,
                items: equipmentOptions,
                icon: Icons.sports_gymnastics,
                onChanged: (value) {
                  setState(() {
                    equipmentPreference = value ?? "";
                  });
                },
              ),

              _dropdown(
                title: "Workout Split",
                value: workoutSplit,
                items: splitOptions,
                icon: Icons.view_week_outlined,
                onChanged: (value) {
                  setState(() {
                    workoutSplit = value ?? "";
                  });
                },
              ),

              _dropdown(
                title: "Fitness Level",
                value: fitnessLevel,
                items: fitnessLevelOptions,
                icon: Icons.trending_up,
                onChanged: (value) {
                  setState(() {
                    fitnessLevel = value ?? "";
                  });
                },
              ),

              const SizedBox(height: 8),

              const Text(
                "Training Schedule",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_month_outlined, color: primary),

                        const SizedBox(width: 10),

                        const Text(
                          "Workout Days Per Week",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),

                        const Spacer(),

                        Text(
                          "$workoutDays days",
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    Slider(
                      value: workoutDays.toDouble(),
                      min: 1,
                      max: 7,
                      divisions: 6,
                      activeColor: primary,

                      onChanged: (value) {
                        setState(() {
                          workoutDays = value.round();
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Cardio & Sports",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              _dropdown(
                title: "Cardio Preference",
                value: cardioPreference,
                items: cardioOptions,
                icon: Icons.directions_run,
                onChanged: (value) {
                  setState(() {
                    cardioPreference = value ?? "";
                  });
                },
              ),

              _textField(
                label: "Sport / Activity",
                value: sportName,
                icon: Icons.sports,
                onChanged: (value) {
                  sportName = value;
                },
              ),

              _dropdown(
                title: "Competition Level",
                value: competitionLevel,
                items: competitionOptions,
                icon: Icons.emoji_events_outlined,
                onChanged: (value) {
                  setState(() {
                    competitionLevel = value ?? "";
                  });
                },
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 54,

                child: ElevatedButton(
                  onPressed: isSaving ? null : _savePreferences,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  child: isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Save Changes",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
