import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fitnova/models/user_profile_model.dart';
import 'package:fitnova/services/supabase_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final phoneController = TextEditingController();

  String gender = "";

  bool isLoading = true;
  bool isSaving = false;

  UserProfileModel? profile;

  final Color primary = const Color(0xFF3A6F4B);
  final Color background = const Color(0xFFF5F8F6);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> _loadProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final data = await SupabaseService().getUserProfile(user.id);

      if (data != null) {
        profile = data;

        fullNameController.text = data.fullName;
        ageController.text = data.age.toString();
        heightController.text = data.height.toString();
        weightController.text = data.weight.toString();

        if (data.phone != 0) {
          phoneController.text = data.phone.toString();
        }

        gender = data.gender;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Unable to load profile")));
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (profile == null) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      /*
       * Preserve ALL existing profile information.
       *
       * Only these values are changed here:
       * fullName
       * age
       * gender
       * height
       * weight
       * phone
       */

      final updatedProfile = UserProfileModel(
        uid: profile!.uid,

        // BASIC PROFILE
        fullName: fullNameController.text.trim(),
        age: int.parse(ageController.text.trim()),
        gender: gender,
        height: double.parse(heightController.text.trim()),
        weight: double.parse(weightController.text.trim()),
        phone: int.tryParse(phoneController.text.trim()) ?? 0,

        // GOALS
        goal: profile!.goal,
        targetWeight: profile!.targetWeight,
        durationMonths: profile!.durationMonths,
        muscleGainTarget: profile!.muscleGainTarget,
        sportName: profile!.sportName,
        strengthGoal: profile!.strengthGoal,
        primaryLift: profile!.primaryLift,
        repRange: profile!.repRange,
        enduranceGoal: profile!.enduranceGoal,
        cardioPreference: profile!.cardioPreference,
        fitnessGoals: List<String>.from(profile!.fitnessGoals),
        workoutPlace: profile!.workoutPlace,
        performanceGoals: List<String>.from(profile!.performanceGoals),
        competitionLevel: profile!.competitionLevel,
        workoutDays: profile!.workoutDays,

        // ACTIVITY
        activityLevel: profile!.activityLevel,

        // DIET
        dietaryPreferences: List<String>.from(profile!.dietaryPreferences),
        allergies: profile!.allergies,
        comments: profile!.comments,
        mealsPerDay: profile!.mealsPerDay,
        budget: profile!.budget,

        // DAILY ROUTINE
        sleepHours: profile!.sleepHours,
        waterIntake: profile!.waterIntake,
        officeTime: profile!.officeTime,
        breakTime: profile!.breakTime,
        job: profile!.job,
        workoutTime: profile!.workoutTime,
        exercise: profile!.exercise,
        wakeUp: profile!.wakeUp,

        // WORKOUT
        workoutPrefer: profile!.workoutPrefer,
        equipmentPrefer: profile!.equipmentPrefer,
        split: profile!.split,

        // SKIN
        skinTone: profile!.skinTone,
        skinConcerns: List<String>.from(profile!.skinConcerns),

        // HAIR
        hairType: profile!.hairType,
        hairConcerns: List<String>.from(profile!.hairConcerns),
        scalpType: profile!.scalpType,

        // BODY
        bodyType: profile!.bodyType,
        bodyGoal: profile!.bodyGoal,
        fitnessLevel: profile!.fitnessLevel,
      );

      await SupabaseService().updateUserProfile(updatedProfile);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update profile: $e"),
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

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,

        validator: validator,

        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primary),
          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: background,
        body: Center(child: CircularProgressIndicator(color: primary)),
      );
    }

    if (profile == null) {
      return Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: const Text("Edit Profile"),
          backgroundColor: background,
          elevation: 0,
        ),
        body: const Center(child: Text("Profile not found")),
      );
    }

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: background,
        elevation: 0,
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sw = constraints.maxWidth > 600
                ? 600.0
                : constraints.maxWidth;

            return Center(
              child: SizedBox(
                width: sw,

                child: Form(
                  key: _formKey,

                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),

                    child: Column(
                      children: [
                        // ==================================================
                        // PROFILE ICON
                        // ==================================================
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primary,
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              fullNameController.text.isNotEmpty
                                  ? fullNameController.text[0].toUpperCase()
                                  : "U",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          "Personal Information",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "Update your basic profile information",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ==================================================
                        // BASIC INFORMATION
                        // ==================================================
                        _sectionTitle("BASIC INFORMATION"),

                        _textField(
                          controller: fullNameController,
                          label: "Full Name",
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Enter your full name";
                            }

                            return null;
                          },
                        ),

                        _textField(
                          controller: ageController,
                          label: "Age",
                          icon: Icons.cake_outlined,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Enter your age";
                            }

                            if (int.tryParse(value.trim()) == null) {
                              return "Enter a valid age";
                            }

                            return null;
                          },
                        ),

                        // ==================================================
                        // GENDER
                        // ==================================================
                        Container(
                          margin: const EdgeInsets.only(bottom: 14),

                          child: DropdownButtonFormField<String>(
                            value: gender.isEmpty ? null : gender,

                            decoration: InputDecoration(
                              labelText: "Gender",
                              prefixIcon: Icon(
                                Icons.wc_outlined,
                                color: primary,
                              ),
                              filled: true,
                              fillColor: Colors.white,

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),

                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                            ),

                            items: const [
                              DropdownMenuItem(
                                value: "Male",
                                child: Text("Male"),
                              ),
                              DropdownMenuItem(
                                value: "Female",
                                child: Text("Female"),
                              ),
                            ],

                            onChanged: (value) {
                              if (value == null) return;

                              setState(() {
                                gender = value;
                              });
                            },
                          ),
                        ),

                        _textField(
                          controller: heightController,
                          label: "Height (cm)",
                          icon: Icons.height,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Enter your height";
                            }

                            if (double.tryParse(value.trim()) == null) {
                              return "Enter a valid height";
                            }

                            return null;
                          },
                        ),

                        _textField(
                          controller: weightController,
                          label: "Weight (kg)",
                          icon: Icons.monitor_weight_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Enter your weight";
                            }

                            if (double.tryParse(value.trim()) == null) {
                              return "Enter a valid weight";
                            }

                            return null;
                          },
                        ),

                        _textField(
                          controller: phoneController,
                          label: "Phone Number",
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),

                        // ==================================================
                        // CURRENT INFORMATION
                        // ==================================================
                        _sectionTitle("CURRENT FITNESS INFORMATION"),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF4ED),
                            borderRadius: BorderRadius.circular(18),
                          ),

                          child: Column(
                            children: [
                              _infoRow("Current Goal", profile!.goal),

                              _infoRow("Target Weight", profile!.targetWeight),

                              _infoRow(
                                "Activity Level",
                                profile!.activityLevel,
                              ),

                              _infoRow("Workout Days", profile!.workoutDays),

                              _infoRow("Wake Up", profile!.wakeUp),

                              _infoRow("Workout Time", profile!.workoutTime),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ==================================================
                        // SAVE
                        // ==================================================
                        SizedBox(
                          width: double.infinity,
                          height: 52,

                          child: ElevatedButton(
                            onPressed: isSaving ? null : _updateProfile,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),

                            child: isSaving
                                ? const SizedBox(
                                    width: 23,
                                    height: 23,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.save_outlined),
                                      SizedBox(width: 8),
                                      Text(
                                        "Save Changes",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // INFORMATION ROW
  // ============================================================

  Widget _infoRow(String title, dynamic value) {
    final text = value == null || value.toString().trim().isEmpty
        ? "Not set"
        : value.toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
          ),

          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    phoneController.dispose();

    super.dispose();
  }
}
