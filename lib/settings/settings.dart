import 'package:fitnova/settings/body_profile.dart';
import 'package:fitnova/settings/daily_routine.dart';
import 'package:fitnova/settings/diet_preferences.dart';
import 'package:fitnova/settings/skin_hair.dart';
import 'package:fitnova/settings/workout_preferences.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fitnova/settings/editprofile.dart';
import 'package:fitnova/settings/mygoals.dart';
import 'package:fitnova/settings/myplan.dart';
import 'package:fitnova/login.dart';

import 'package:fitnova/models/user_profile_model.dart';
import 'package:fitnova/services/supabase_service.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final Color primary = const Color(0xFF3A6F4B);
  final Color background = const Color(0xFFF5F8F6);

  bool generatingBoth = false;
  bool generatingMeal = false;
  bool generatingWorkout = false;

  Future<void> _openPage(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // GENERATE BOTH
  // ============================================================

  Future<void> _generateBoth(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Generate New Plans"),
          content: const Text(
            "This will generate a new diet plan and workout plan. "
            "Your current plans will be replaced.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Generate"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      generatingBoth = true;
    });

    try {
      await SupabaseService().generateAndSavePlans(userId);

      if (!mounted) return;

      _showMessage(
        "New diet and workout plans generated successfully.",
        Colors.green,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage("Failed to generate plans.", Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          generatingBoth = false;
        });
      }
    }
  }

  // ============================================================
  // GENERATE MEAL
  // ============================================================

  Future<void> _generateMealPlan(String userId) async {
    setState(() {
      generatingMeal = true;
    });

    try {
      await SupabaseService().generateAndSaveMealPlan(userId);

      if (!mounted) return;

      _showMessage("New meal plan generated successfully.", Colors.green);
    } catch (e) {
      if (!mounted) return;

      _showMessage("Failed to generate meal plan.", Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          generatingMeal = false;
        });
      }
    }
  }

  // ============================================================
  // GENERATE WORKOUT
  // ============================================================

  Future<void> _generateWorkoutPlan(String userId) async {
    setState(() {
      generatingWorkout = true;
    });

    try {
      await SupabaseService().generateAndSaveWorkoutPlan(userId);

      if (!mounted) return;

      _showMessage("New workout plan generated successfully.", Colors.green);
    } catch (e, stackTrace) {
      debugPrint('========== WORKOUT GENERATION ERROR ==========');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      debugPrint('==============================================');

      if (!mounted) return;

      _showMessage("Failed to generate workout plan.\n$e", Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          generatingWorkout = false;
        });
      }
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ============================================================
  // SETTING CARD
  // ============================================================

  Widget _settingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4ED),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: primary, size: 21),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 12, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: primary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // PLAN GENERATOR CARD
  // ============================================================

  Widget _planGeneratorCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool loading,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAF4ED), Color(0xFFF7FBF8)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD8EADD)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: loading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              if (loading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(Icons.arrow_forward_ios, size: 15, color: primary),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: background,
        elevation: 0,
      ),

      body: FutureBuilder<UserProfileModel?>(
        future: SupabaseService().getUserProfile(user.id),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primary));
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Unable to load profile"));
          }

          final profile = snapshot.data;

          if (profile == null) {
            return const Center(child: Text("Profile not found"));
          }

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final sw = constraints.maxWidth > 600
                    ? 600.0
                    : constraints.maxWidth;

                return Center(
                  child: SizedBox(
                    width: sw,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(15, 5, 15, 30),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ==================================================
                          // PROFILE HEADER
                          // ==================================================
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primary, const Color(0xFF2E5D3E)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    profile.fullName.isNotEmpty
                                        ? profile.fullName[0].toUpperCase()
                                        : "U",
                                    style: TextStyle(
                                      color: primary,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 14),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Your Profile",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                        ),
                                      ),

                                      const SizedBox(height: 3),

                                      Text(
                                        profile.fullName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 3),

                                      Text(
                                        profile.goal.isEmpty
                                            ? "Fitness profile"
                                            : profile.goal,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ==================================================
                          // PROFILE & GOALS
                          // ==================================================
                          _sectionTitle("PROFILE & GOALS"),

                          _settingCard(
                            icon: Icons.person_outline,
                            title: "Edit Profile",
                            subtitle:
                                "${profile.age} years • ${profile.gender} • ${profile.weight} kg",
                            onTap: () => _openPage(const EditProfileScreen()),
                          ),

                          _settingCard(
                            icon: Icons.flag_outlined,
                            title: "My Goals",
                            subtitle: profile.goal.isEmpty
                                ? "Set your fitness goal"
                                : profile.goal,
                            onTap: () => _openPage(const MyGoalsScreen()),
                          ),

                          // ==================================================
                          // DIET & NUTRITION
                          // ==================================================
                          _sectionTitle("DIET & NUTRITION"),

                          _settingCard(
                            icon: Icons.restaurant_menu,
                            title: "Diet Preferences",
                            subtitle: profile.dietaryPreferences.isEmpty
                                ? "No preferences selected"
                                : profile.dietaryPreferences.join(", "),
                            onTap: () =>
                                _openPage(const DietPreferencesScreen()),
                          ),

                          _settingCard(
                            icon: Icons.schedule,
                            title: "Daily Routine",
                            subtitle:
                                "Wake ${profile.wakeUp} • Sleep ${profile.sleepHours}",
                            onTap: () => _openPage(const DailyRoutineScreen()),
                          ),

                          // ==================================================
                          // WORKOUT
                          // ==================================================
                          _sectionTitle("WORKOUT"),

                          _settingCard(
                            icon: Icons.fitness_center,
                            title: "Workout Preferences & Schedules",
                            subtitle: profile.workoutPrefer.isEmpty
                                ? "Not configured"
                                : profile.workoutPrefer,
                            onTap: () =>
                                _openPage(const WorkoutPreferencesScreen()),
                          ),

                          // ==================================================
                          // BODY & APPEARANCE
                          // ==================================================
                          _sectionTitle("BODY & APPEARANCE"),

                          _settingCard(
                            icon: Icons.accessibility_new,
                            title: "Body Profile",
                            subtitle:
                                "${profile.bodyType} • ${profile.bodyGoal}",
                            onTap: () => _openPage(const BodyProfileScreen()),
                          ),

                          _settingCard(
                            icon: Icons.face_retouching_natural,
                            title: "Skin & Hair",
                            subtitle:
                                "${profile.skinTone} • ${profile.hairType}",
                            onTap: () => _openPage(const SkinHairScreen()),
                          ),

                          // ==================================================
                          // PLANS
                          // ==================================================
                          _sectionTitle("PLANS"),

                          _settingCard(
                            icon: Icons.menu_book_outlined,
                            title: "My Plan",
                            subtitle: "View your current plans",
                            onTap: () => _openPage(const MyPlanScreen()),
                          ),

                          const SizedBox(height: 4),

                          _planGeneratorCard(
                            title: "Generate Meal Plan",
                            subtitle: "Create a new personalized diet plan",
                            icon: Icons.restaurant,
                            loading: generatingMeal,
                            onTap: () => _generateMealPlan(user.id),
                          ),

                          _planGeneratorCard(
                            title: "Generate Workout Plan",
                            subtitle: "Create a new personalized workout plan",
                            icon: Icons.fitness_center,
                            loading: generatingWorkout,
                            onTap: () => _generateWorkoutPlan(user.id),
                          ),

                          _planGeneratorCard(
                            title: "Generate New Plan",
                            subtitle: "Generate both diet and workout plans",
                            icon: Icons.auto_awesome,
                            loading: generatingBoth,
                            onTap: () => _generateBoth(user.id),
                          ),

                          // ==================================================
                          // ACCOUNT
                          // ==================================================
                          _sectionTitle("ACCOUNT"),

                          _settingCard(
                            icon: Icons.logout,
                            title: "Logout",
                            subtitle: "Sign out from FitNova",
                            onTap: _logout,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
