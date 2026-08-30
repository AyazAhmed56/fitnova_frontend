import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fitnova/models/user_profile_model.dart';
import 'package:fitnova/services/supabase_service.dart';

class DailyRoutineScreen extends StatefulWidget {
  const DailyRoutineScreen({super.key});

  @override
  State<DailyRoutineScreen> createState() => _DailyRoutineScreenState();
}

class _DailyRoutineScreenState extends State<DailyRoutineScreen> {
  final SupabaseService _service = SupabaseService();

  UserProfileModel? profile;

  bool isLoading = true;
  bool isSaving = false;

  late TextEditingController wakeUpController;
  late TextEditingController officeController;
  late TextEditingController breakController;
  late TextEditingController workoutTimeController;
  late TextEditingController exerciseController;
  late TextEditingController sleepController;
  late TextEditingController waterController;

  final Color primary = const Color(0xFF3A6F4B);
  final Color lightGreen = const Color(0xFFEAF4ED);

  @override
  void initState() {
    super.initState();

    wakeUpController = TextEditingController();
    officeController = TextEditingController();
    breakController = TextEditingController();
    workoutTimeController = TextEditingController();
    exerciseController = TextEditingController();
    sleepController = TextEditingController();
    waterController = TextEditingController();

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

        wakeUpController.text = result.wakeUp;
        officeController.text = result.officeTime;
        breakController.text = result.breakTime;
        workoutTimeController.text = result.workoutTime;
        exerciseController.text = result.exercise;
        sleepController.text = result.sleepHours;
        waterController.text = result.waterIntake;
      }
    } catch (e) {
      _showMessage("Failed to load routine: $e", Colors.red);
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    TimeOfDay initialTime = TimeOfDay.now();

    final result = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (result != null) {
      controller.text = result.format(context);
    }
  }

  Future<void> _saveRoutine() async {
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
        cardioPreference: profile!.cardioPreference,
        fitnessGoals: profile!.fitnessGoals,

        // WORKOUT
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

        // DAILY ROUTINE - UPDATED
        sleepHours: sleepController.text.trim(),
        waterIntake: waterController.text.trim(),
        job: profile!.job,
        workoutTime: workoutTimeController.text.trim(),
        breakTime: breakController.text.trim(),
        officeTime: officeController.text.trim(),
        exercise: exerciseController.text.trim(),
        wakeUp: wakeUpController.text.trim(),
        budget: profile!.budget,

        // WORKOUT PREFERENCES
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

      await _service.updateUserProfile(updatedProfile);

      profile = updatedProfile;

      if (!mounted) return;

      _showMessage("Daily routine updated successfully.", Colors.green);

      Navigator.pop(context, true);
    } catch (e) {
      _showMessage("Failed to update routine: $e", Colors.red);
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

  Widget _timeField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectTime(controller),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primary),
          suffixIcon: const Icon(Icons.access_time),
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

  Widget _textField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
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
          "Daily Routine",
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
                      child: const Icon(Icons.schedule, color: Colors.white),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Daily Routine",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "Set your daily schedule for better planning.",
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
                "Your Schedule",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              _timeField(
                "Wake Up Time",
                wakeUpController,
                Icons.wb_sunny_outlined,
              ),

              _timeField(
                "Office / Work Time",
                officeController,
                Icons.work_outline,
              ),

              _timeField(
                "Break Time",
                breakController,
                Icons.free_breakfast_outlined,
              ),

              _timeField(
                "Workout Time",
                workoutTimeController,
                Icons.fitness_center_outlined,
              ),

              _textField(
                "Exercise Duration",
                exerciseController,
                Icons.timer_outlined,
              ),

              _textField(
                "Sleep Hours",
                sleepController,
                Icons.bedtime_outlined,
              ),

              _textField(
                "Daily Water Intake",
                waterController,
                Icons.water_drop_outlined,
              ),

              const SizedBox(height: 12),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 54,

                child: ElevatedButton(
                  onPressed: isSaving ? null : _saveRoutine,

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

  @override
  void dispose() {
    wakeUpController.dispose();
    officeController.dispose();
    breakController.dispose();
    workoutTimeController.dispose();
    exerciseController.dispose();
    sleepController.dispose();
    waterController.dispose();

    super.dispose();
  }
}
