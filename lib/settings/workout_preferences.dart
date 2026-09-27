import 'dart:convert';

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

  int workoutDays = 0;

  final List<String> workoutPreferenceOptions = [
    "Strength Training",
    "Weight Training",
    "HIIT",
    "Yoga",
    "Home Workout",
    "Gym Workout",
    "Gym Workout + Cardio",
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
    "Upper / Lower / Rest",
    "Upper / Cardio / Lower",
    "Upper / Lower / Cardio",
    "Push / Pull / Legs",
    "Legs / Push / Pull",
    "Single Muscle",
    "Double Muscle",
    "Bro Split",
    "Custom",
  ];

  final List<String> fitnessLevelOptions = [
    "Beginner",
    "Intermediate",
    "Advanced",
  ];

  final List<String> weekDays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  final Map<String, TextEditingController> customSplitControllers = {};

  final Color primary = const Color(0xFF3A6F4B);
  final Color lightGreen = const Color(0xFFEAF4ED);

  @override
  void initState() {
    super.initState();

    for (final day in weekDays) {
      customSplitControllers[day] = TextEditingController();
    }

    _loadProfile();
  }

  @override
  void dispose() {
    for (final controller in customSplitControllers.values) {
      controller.dispose();
    }

    super.dispose();
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
        workoutDays = result.workoutDays;

        /*
         * Load custom split.
         *
         * UserProfileModel should contain:
         *
         * Map<String, dynamic>? customSplit;
         */
        if (result.customSplit != null) {
          final custom = result.customSplit!;

          for (final day in weekDays) {
            customSplitControllers[day]!.text = custom[day]?.toString() ?? "";
          }
        }
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

  bool _validateCustomSplit() {
    if (workoutSplit != "Custom") {
      return true;
    }

    for (final day in weekDays) {
      final value = customSplitControllers[day]!.text.trim();

      if (value.isEmpty) {
        _showMessage("Please enter a workout split for $day.", Colors.red);

        return false;
      }
    }

    return true;
  }

  Map<String, String> _getCustomSplit() {
    final Map<String, String> customSplit = {};

    for (final day in weekDays) {
      customSplit[day] = customSplitControllers[day]!.text.trim();
    }

    return customSplit;
  }

  Future<void> _savePreferences() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    if (!_validateCustomSplit()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      Map<String, String>? customSplit;

      if (workoutSplit == "Custom") {
        customSplit = _getCustomSplit();
      }

      await _service.updateCurrentGoalWorkoutSettings(
        profileId: user.id,
        workoutPrefer: workoutPreference,
        equipmentPrefer: equipmentPreference,
        split: workoutSplit,
        fitnessLevel: fitnessLevel,
        workoutDays: workoutDays,
        workoutPlace: workoutPlace,
        customSplit: customSplit,
      );

      if (!mounted) return;

      _showMessage('Workout preferences updated successfully.', Colors.green);

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      _showMessage('Failed to update workout preferences: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
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

  Widget _customSplitField(String day) {
    final controller = customSplitControllers[day]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,

        textCapitalization: TextCapitalization.words,

        decoration: InputDecoration(
          labelText: day,
          hintText: "Example: Chest, Back, Legs, Rest",
          prefixIcon: Icon(Icons.fitness_center, color: primary),
          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _customSplitSection() {
    if (workoutSplit != "Custom") {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(top: 2, bottom: 16),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFFF7FBF8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withOpacity(0.12)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(Icons.view_week_outlined, color: primary),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  "Custom Weekly Split",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            "Enter the workout split you want for each day.",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),

          const SizedBox(height: 16),

          ...weekDays.map((day) => _customSplitField(day)),
        ],
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

              // CUSTOM SPLIT FIELDS
              _customSplitSection(),

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
                      value: workoutDays.toDouble().clamp(1, 7),

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

              const SizedBox(height: 20),

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
