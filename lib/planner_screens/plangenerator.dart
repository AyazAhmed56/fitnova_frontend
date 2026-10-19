import 'package:fitnova/mainscreen.dart';
import 'package:fitnova/diet_display/display_screen/skincare_screen.dart';
import 'package:fitnova/diet_display/display_screen/haircare_screen.dart';
import 'package:fitnova/models/onboarding_data.dart';
import 'package:fitnova/models/user_profile_model.dart';
import 'package:fitnova/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum PlanGenerationMode { profileOnly, diet, workout, skin, hair, both }

class PlanGenerator extends StatefulWidget {
  final PlanGenerationMode mode;

  const PlanGenerator({super.key, this.mode = PlanGenerationMode.both});

  @override
  State<PlanGenerator> createState() => _PlanGeneratorState();
}

class _PlanGeneratorState extends State<PlanGenerator> {
  @override
  void initState() {
    super.initState();

    generatePlan();
  }

  Future<void> generatePlan() async {
    try {
      final data = OnboardingData.instance;

      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception("User not logged in.");
      }

      final uid = user.id;

      final profile = UserProfileModel(
        uid: uid,

        fullName: data.fullName,
        age: data.age,
        gender: data.gender,

        height: data.height,
        weight: data.weight,
        medical: data.medical,
        phone: data.phone,
        state: data.state,
        nativeState: data.nativeState,
        goal: data.goal,
        targetWeight: data.targetWeight,
        durationMonths: data.durationMonths,

        muscleGainTarget: data.muscleGainTarget,

        strengthGoal: data.strengthGoal,

        primaryLift: data.primaryLift,

        repRange: data.repRange,

        enduranceGoal: data.enduranceGoal,

        cardioPreference: data.cardioPreference,

        sportName: data.sportName,

        fitnessGoals: data.fitnessGoals,

        workoutPlace: data.workoutPlace,

        performanceGoals: data.performanceGoals,

        competitionLevel: data.competitionLevel,

        workoutDays: data.workoutDays,

        activityLevel: data.activityLevel,

        dietaryPreferences: data.dietaryPreferences,

        allergies: data.allergies,

        comments: data.comments,

        mealsPerDay: data.mealsPerDay,

        sleepHours: data.sleepHours,

        waterIntake: data.waterIntake,

        job: data.job,

        workoutTime: data.workoutTime,

        officeTime: data.officeTime,

        breakTime: data.breakTime,

        exercise: data.exercise,

        wakeUp: data.wakeUp,

        budget: data.budget,

        workoutPrefer: data.workoutPrefer,

        equipmentPrefer: data.equipmentPrefer,

        split: data.split,

        // Custom split is configured later
        // from Workout Preferences.
        customSplit: null,

        skinTone: data.skinTone,

        skinConcerns: data.skinConcerns,

        hairType: data.hairType,

        scalpType: data.scalpType,

        hairConcerns: data.hairConcerns,

        bodyType: data.bodyType,

        bodyGoal: data.bodyGoal,

        fitnessLevel: data.fitnessLevel,
      );

      final supabaseService = SupabaseService();

      // Initial onboarding creates the profile and goal records, but must not
      // generate a diet or workout plan yet.
      if (widget.mode == PlanGenerationMode.profileOnly) {
        await supabaseService.saveUserProfile(profile);
      } else if (widget.mode == PlanGenerationMode.both) {
        // Preserve the legacy Review -> PlanGenerator behavior for any older
        // navigation still pointing here.
        await supabaseService.saveUserProfile(profile);
        await supabaseService.generateAndSavePlans(uid);
      } else if (widget.mode == PlanGenerationMode.diet) {
        // Update only diet/lifestyle fields. Do not overwrite workout, skin,
        // hair, body, or goal answers already stored in Supabase.
        await supabaseService.updateProfileFields(uid, {
          'dietary_preferences': data.dietaryPreferences,
          'allergies': data.allergies,
          'comments': data.comments,
          'meals_per_day': data.mealsPerDay,
          'sleep_hours': data.sleepHours,
          'water_intake': data.waterIntake,
          'job': data.job,
          'office_time': data.officeTime,
          'break_time': data.breakTime,
          'wake_up': data.wakeUp,
          'budget': data.budget,
        });
        await supabaseService.generateAndSaveMealPlan(uid);
      } else if (widget.mode == PlanGenerationMode.workout) {
        await supabaseService.updateProfileFields(uid, {
          'exercise': data.exercise,
          'workout_prefer': data.workoutPrefer,
          'equipment_prefer': data.equipmentPrefer,
          'split': data.split,
          'workout_time': data.workoutTime,
          'job': data.job,
          'office_time': data.officeTime,
          'break_time': data.breakTime,
          'wake_up': data.wakeUp,
        });
        await supabaseService.generateAndSaveWorkoutPlan(uid);
      } else if (widget.mode == PlanGenerationMode.skin) {
        await supabaseService.updateProfileFields(uid, {
          'skin_tone': data.skinTone,
          'skin_concerns': data.skinConcerns,
        });
      } else if (widget.mode == PlanGenerationMode.hair) {
        await supabaseService.updateProfileFields(uid, {
          'hair_type': data.hairType,
          'scalp_type': data.scalpType,
          'hair_concerns': data.hairConcerns,
        });
      }

      if (!mounted) return;

      if (widget.mode == PlanGenerationMode.skin) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SkinCareScreen()),
          (route) => false,
        );
      } else if (widget.mode == PlanGenerationMode.hair) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HairCareScreen()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double sw = constraints.maxWidth;

            final double sh = constraints.maxHeight;

            return SizedBox(
              width: double.infinity,
              height: sh,

              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.08),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Image.asset(
                      'assets/genplan.png',
                      width: sw * 0.5,
                      height: sw * 0.5,
                      fit: BoxFit.contain,
                    ),

                    Text(
                      'Creating Your',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: sw * 0.07,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: sh * 0.008),

                    Text(
                      widget.mode == PlanGenerationMode.profileOnly
                          ? 'Saving Your Profile'
                          : widget.mode == PlanGenerationMode.diet
                          ? 'Generating Your Diet Plan'
                          : widget.mode == PlanGenerationMode.workout
                          ? 'Generating Your Workout Plan'
                          : widget.mode == PlanGenerationMode.skin
                          ? 'Saving Your Skin Profile'
                          : widget.mode == PlanGenerationMode.hair
                          ? 'Saving Your Hair Profile'
                          : 'Personalized Fitness Plan',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: sw * 0.07,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: sh * 0.025),

                    Text(
                      'This may take sometime',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: sw * 0.04,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    SizedBox(height: sh * 0.04),

                    SizedBox(
                      width: sw * 0.08,
                      height: sw * 0.08,

                      child: const CircularProgressIndicator(strokeWidth: 3),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
