import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fitnova/models/user_profile_model.dart';
import 'package:fitnova/services/supabase_service.dart';

class BodyProfileScreen extends StatefulWidget {
  const BodyProfileScreen({super.key});

  @override
  State<BodyProfileScreen> createState() => _BodyProfileScreenState();
}

class _BodyProfileScreenState extends State<BodyProfileScreen> {
  final SupabaseService _service = SupabaseService();

  UserProfileModel? profile;

  bool isLoading = true;
  bool isSaving = false;

  String bodyType = "";
  String bodyGoal = "";
  String fitnessLevel = "";

  final Color primary = const Color(0xFF3A6F4B);
  final Color lightGreen = const Color(0xFFEAF4ED);

  final List<String> bodyTypes = [
    "Ectomorph",
    "Mesomorph",
    "Endomorph",
    "Athletic",
    "Slim",
    "Average",
    "Broad",
  ];

  final List<String> bodyGoals = [
    "Lean",
    "Lean & Toned",
    "Muscle Gain",
    "Fat Loss",
    "Body Recomposition",
    "Athletic",
    "Maintain",
  ];

  final List<String> fitnessLevels = ["Beginner", "Intermediate", "Advanced"];

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

        bodyType = result.bodyType;
        bodyGoal = result.bodyGoal;
        fitnessLevel = result.fitnessLevel;
      }
    } catch (e) {
      _showMessage("Failed to load body profile: $e", Colors.red);
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveBodyProfile() async {
    if (profile == null) return;

    setState(() {
      isSaving = true;
    });

    try {
      final updated = UserProfileModel(
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
        cardioPreference: profile!.cardioPreference,
        fitnessGoals: profile!.fitnessGoals,
        workoutPlace: profile!.workoutPlace,
        sportName: profile!.sportName,
        performanceGoals: profile!.performanceGoals,
        competitionLevel: profile!.competitionLevel,
        workoutDays: profile!.workoutDays,
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

        // BODY - UPDATED
        bodyType: bodyType,
        bodyGoal: bodyGoal,
        fitnessLevel: fitnessLevel,
      );

      await _service.updateUserProfile(updated);

      profile = updated;

      if (!mounted) return;

      _showMessage("Body profile updated successfully.", Colors.green);

      Navigator.pop(context, true);
    } catch (e) {
      _showMessage("Failed to update body profile: $e", Colors.red);
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
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : null,
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
          "Body Profile",
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
                      radius: 27,
                      backgroundColor: primary,
                      child: const Icon(
                        Icons.accessibility_new,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Body Profile",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Tell FitNova how you want to shape your body.",
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

              const SizedBox(height: 28),

              const Text(
                "Body Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              _dropdown(
                label: "Body Type",
                value: bodyType,
                items: bodyTypes,
                icon: Icons.person_outline,
                onChanged: (value) {
                  setState(() {
                    bodyType = value ?? "";
                  });
                },
              ),

              _dropdown(
                label: "Body Goal",
                value: bodyGoal,
                items: bodyGoals,
                icon: Icons.track_changes,
                onChanged: (value) {
                  setState(() {
                    bodyGoal = value ?? "";
                  });
                },
              ),

              _dropdown(
                label: "Fitness Level",
                value: fitnessLevel,
                items: fitnessLevels,
                icon: Icons.trending_up,
                onChanged: (value) {
                  setState(() {
                    fitnessLevel = value ?? "";
                  });
                },
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Your body information helps FitNova personalize your workout and nutrition recommendations.",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _saveBodyProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
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
