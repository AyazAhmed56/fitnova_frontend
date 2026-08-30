import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fitnova/models/user_profile_model.dart';
import 'package:fitnova/services/supabase_service.dart';

class DietPreferencesScreen extends StatefulWidget {
  const DietPreferencesScreen({super.key});

  @override
  State<DietPreferencesScreen> createState() => _DietPreferencesScreenState();
}

class _DietPreferencesScreenState extends State<DietPreferencesScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  UserProfileModel? profile;

  bool isLoading = true;
  bool isSaving = false;

  final allergiesController = TextEditingController();
  final commentsController = TextEditingController();
  final mealsController = TextEditingController();
  final budgetController = TextEditingController();

  List<String> selectedDiet = [];

  final List<String> dietOptions = [
    "Vegetarian",
    "Vegan",
    "Eggetarian",
    "Non-Vegetarian",
    "Jain",
    "Gluten Free",
    "Dairy Free",
    "Low Carb",
    "Low Fat",
    "High Protein",
    "Keto",
    "Pescatarian",
  ];

  @override
  void initState() {
    super.initState();
    loadDietData();
  }

  Future<void> loadDietData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final data = await _supabaseService.getUserProfile(user.id);

      if (data != null) {
        profile = data;

        selectedDiet = List<String>.from(data.dietaryPreferences);

        allergiesController.text = data.allergies;

        commentsController.text = data.comments;

        mealsController.text = data.mealsPerDay;

        budgetController.text = data.budget;
      }
    } catch (e) {
      debugPrint("Diet preference loading error: $e");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateDietPreferences() async {
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
        goal: profile!.goal,
        targetWeight: profile!.targetWeight,
        durationMonths: profile!.durationMonths,

        muscleGainTarget: profile!.muscleGainTarget,

        strengthGoal: profile!.strengthGoal,

        primaryLift: profile!.primaryLift,

        repRange: profile!.repRange,

        enduranceGoal: profile!.enduranceGoal,

        cardioPreference: profile!.cardioPreference,

        sportName: profile!.sportName,

        fitnessGoals: profile!.fitnessGoals,

        workoutPlace: profile!.workoutPlace,

        performanceGoals: profile!.performanceGoals,

        competitionLevel: profile!.competitionLevel,

        workoutDays: profile!.workoutDays,

        activityLevel: profile!.activityLevel,

        // DIET
        dietaryPreferences: selectedDiet,

        allergies: allergiesController.text.trim(),

        comments: commentsController.text.trim(),

        mealsPerDay: mealsController.text.trim(),

        budget: budgetController.text.trim(),

        // DAILY ROUTINE
        sleepHours: profile!.sleepHours,

        waterIntake: profile!.waterIntake,

        job: profile!.job,

        workoutTime: profile!.workoutTime,

        breakTime: profile!.breakTime,

        officeTime: profile!.officeTime,

        exercise: profile!.exercise,

        wakeUp: profile!.wakeUp,

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

        bodyGoal: profile!.bodyGoal,

        fitnessLevel: profile!.fitnessLevel,
      );

      await _supabaseService.updateUserProfile(updatedProfile);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Diet preferences updated successfully."),
          backgroundColor: Color(0xFF3A6F4B),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update diet preferences.\n$e"),
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

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 12),
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Diet Preferences"), centerTitle: true),

      backgroundColor: const Color(0xFFF5F8F5),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Diet Type"),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: dietOptions.map((diet) {
                  final selected = selectedDiet.contains(diet);

                  return FilterChip(
                    label: Text(diet),
                    selected: selected,
                    selectedColor: const Color(0xFFCFE8D7),
                    checkmarkColor: const Color(0xFF24583A),

                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          if (!selectedDiet.contains(diet)) {
                            selectedDiet.add(diet);
                          }
                        } else {
                          selectedDiet.remove(diet);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              _sectionTitle("Food Restrictions"),

              _field(allergiesController, "Allergies"),

              _field(
                commentsController,
                "Additional Food Preferences / Comments",
              ),

              _sectionTitle("Meal Settings"),

              _field(
                mealsController,
                "Meals Per Day",
                keyboardType: TextInputType.number,
              ),

              _field(budgetController, "Daily / Weekly Food Budget"),

              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F3EB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF3A6F4B)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "These preferences are used when FitNova generates your personalized meal plan.",
                        style: TextStyle(color: Color(0xFF24583A)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isSaving ? null : updateDietPreferences,

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
                          "Update Diet Preferences",
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
    allergiesController.dispose();
    commentsController.dispose();
    mealsController.dispose();
    budgetController.dispose();

    super.dispose();
  }
}
