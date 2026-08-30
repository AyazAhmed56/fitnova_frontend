import 'package:fitnova/mainscreen.dart';
import 'package:fitnova/models/onboarding_data.dart';
import 'package:fitnova/models/user_profile_model.dart';
import 'package:fitnova/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlanGenerator extends StatefulWidget {
  const PlanGenerator({super.key});

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
        phone: data.phone,

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

        // NEW FIELDS
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

      await supabaseService.saveUserProfile(profile);

      await supabaseService.generateAndSavePlans(uid);

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
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
          builder: (context, constraints) {
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
                      'Personalized fitness Plan',
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
