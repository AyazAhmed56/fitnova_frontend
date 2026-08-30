import 'dart:ui';

import 'package:fitnova/ai_coach/ai_coach_screen.dart';
import 'package:fitnova/diet_display/display_screen/diethome.dart';
import 'package:fitnova/models/user_profile_model.dart';
import 'package:fitnova/services/supabase_service.dart';
import 'package:fitnova/workout_display/display_screen/workout_home.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final SupabaseService supabase = SupabaseService();
  bool loading = false;

  Future<UserProfileModel?> _loadProfile() async {
    final uid = Supabase.instance.client.auth.currentUser!.id;
    return supabase.getUserProfile(uid);
  }

  Future<Map<String, dynamic>?> _loadMealPlan() async {
    final uid = Supabase.instance.client.auth.currentUser!.id;
    return supabase.getMealPlan(uid);
  }

  Future<Map<String, dynamic>?> _loadWorkoutPlan() async {
    final uid = Supabase.instance.client.auth.currentUser!.id;
    return supabase.getWorkoutPlan(uid);
  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning";
    }

    if (hour < 17) {
      return "Good Afternoon";
    }

    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/main_background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Scaffold(
          backgroundColor: Colors.transparent,

          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final sw = constraints.maxWidth;
                final sh = constraints.maxHeight;

                return FutureBuilder<UserProfileModel?>(
                  future: _loadProfile(),
                  builder: (context, profileSnapshot) {
                    if (profileSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!profileSnapshot.hasData) {
                      return const Center(child: Text("Profile not found"));
                    }

                    final profile = profileSnapshot.data!;

                    return FutureBuilder<List<Map<String, dynamic>?>>(
                      future: Future.wait([
                        _loadMealPlan(),
                        _loadWorkoutPlan(),
                      ]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final mealPlan = snapshot.data?[0];
                        final workoutPlan = snapshot.data?[1];

                        final mealExists = mealPlan != null;
                        final workoutExists = workoutPlan != null;

                        final mealProgress = mealExists
                            ? supabase.getPlanProgress(mealPlan)
                            : 0.0;

                        final mealRemaining = mealExists
                            ? supabase.formatRemainingTime(
                                supabase.getRemainingTime(mealPlan),
                              )
                            : "--";

                        final bool mealExpired = mealExists
                            ? supabase.isPlanExpired(mealPlan)
                            : true;

                        final workoutRemaining = workoutExists
                            ? supabase.formatRemainingTime(
                                supabase.getRemainingTime(workoutPlan),
                              )
                            : "--";

                        final bool workoutExpired = workoutExists
                            ? supabase.isPlanExpired(workoutPlan)
                            : true;

                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * .05,
                            vertical: sh * .015,
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 15,
                                    sigmaY: 15,
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(sw * .05),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(.28),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(.45),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(.08),
                                          blurRadius: 18,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${getGreeting()} 👋",
                                                style: TextStyle(
                                                  fontSize: sw * .05,
                                                  color: const Color(
                                                    0xff355C3B,
                                                  ),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),

                                              SizedBox(height: sh * .008),

                                              Text(
                                                profile.fullName,
                                                style: TextStyle(
                                                  fontSize: sw * .055,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),

                                              SizedBox(height: sh * .006),

                                              Text(
                                                "Welcome back to your AI Fitness Coach",
                                                style: TextStyle(
                                                  fontSize: sw * .038,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Hero(
                                          tag: "dashboard_avatar",
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: const Color(0xff355C3B),
                                                width: 3,
                                              ),
                                            ),
                                            child: CircleAvatar(
                                              radius: sw * .09,
                                              backgroundColor: const Color(
                                                0xff355C3B,
                                              ),
                                              child: Text(
                                                profile.fullName
                                                    .trim()[0]
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: sw * .09,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: sh * .025),

                              GlassCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: 44,
                                          width: 44,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xff355C3B),
                                                Color(0xff1E4027),
                                              ],
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.insights,
                                            color: Colors.white,
                                          ),
                                        ),

                                        SizedBox(width: sw * .04),

                                        Expanded(
                                          child: Text(
                                            "Today's Progress",
                                            style: TextStyle(
                                              fontSize: sw * .05,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        Text(
                                          "${(mealProgress * 100).toInt()}%",
                                          style: TextStyle(
                                            fontSize: sw * .055,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xff355C3B),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: sh * .025),

                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: LinearProgressIndicator(
                                        minHeight: 10,
                                        value: mealProgress,
                                        backgroundColor: Colors.grey.shade300,
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                              Color(0xff355C3B),
                                            ),
                                      ),
                                    ),

                                    SizedBox(height: sh * .025),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              color: Colors.white.withOpacity(
                                                .18,
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                const Icon(
                                                  Icons.restaurant_menu,
                                                  color: Color(0xff355C3B),
                                                ),

                                                const SizedBox(height: 8),

                                                const Text(
                                                  "Diet Plan",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),

                                                const SizedBox(height: 6),

                                                Text(
                                                  mealExpired
                                                      ? "Expired"
                                                      : "Active",
                                                  style: TextStyle(
                                                    color: mealExpired
                                                        ? Colors.red
                                                        : Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        SizedBox(width: sw * .03),

                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              color: Colors.white.withOpacity(
                                                .18,
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                const Icon(
                                                  Icons.fitness_center,
                                                  color: Color(0xff355C3B),
                                                ),

                                                const SizedBox(height: 8),

                                                const Text(
                                                  "Workout",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),

                                                const SizedBox(height: 6),

                                                Text(
                                                  workoutExists
                                                      ? "Active"
                                                      : "Not Generated",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: workoutExists
                                                        ? Colors.green
                                                        : Colors.orange,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: sh * .03),

                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: const Color(0xff1E4027),
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withOpacity(
                                              .10,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.track_changes,
                                            color: Color(0xffA8DB69),
                                          ),
                                        ),

                                        SizedBox(width: sw * .04),

                                        const Text(
                                          "Current Goal",
                                          style: TextStyle(
                                            color: Color(0xffA8DB69),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: sh * .025),

                                    Center(
                                      child: Text(
                                        profile.goal,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: sh * .025),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              const Text(
                                                "Target Weight",
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                ),
                                              ),

                                              const SizedBox(height: 6),

                                              Text(
                                                "${profile.targetWeight} kg",
                                                style: const TextStyle(
                                                  color: Color(0xffA8DB69),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Container(
                                          width: 1,
                                          height: 60,
                                          color: Colors.white24,
                                        ),

                                        Expanded(
                                          child: Column(
                                            children: [
                                              const Text(
                                                "Duration",
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                ),
                                              ),

                                              const SizedBox(height: 6),

                                              Text(
                                                "${profile.durationMonths} Months",
                                                style: const TextStyle(
                                                  color: Color(0xffA8DB69),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: sh * .03),
                              Text(
                                "Choose Your Focus",
                                style: TextStyle(
                                  fontSize: sw * .05,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff1E2B22),
                                ),
                              ),

                              SizedBox(height: sh * .02),

                              GlassCard(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const DietHome(),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      height: 60,
                                      width: 60,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xff355C3B),
                                            Color(0xff1E4027),
                                          ],
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.restaurant_menu,
                                        color: Colors.white,
                                      ),
                                    ),

                                    SizedBox(width: sw * .04),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Diet Plan",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: sw * .045,
                                            ),
                                          ),

                                          SizedBox(height: sh * .006),

                                          Text(
                                            "Personalized meal plan",
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Color(0xff355C3B),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: sh * .018),

                              GlassCard(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const WorkoutHome(),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      height: 60,
                                      width: 60,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xff355C3B),
                                            Color(0xff1E4027),
                                          ],
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.fitness_center,
                                        color: Colors.white,
                                      ),
                                    ),

                                    SizedBox(width: sw * .04),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Workout Plan",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: sw * .045,
                                            ),
                                          ),

                                          SizedBox(height: sh * .006),

                                          Text(
                                            "Personalized workout schedule",
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Color(0xff355C3B),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: sh * .03),

                              Text(
                                "Recent Activity",
                                style: TextStyle(
                                  fontSize: sw * .05,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff1E2B22),
                                ),
                              ),

                              SizedBox(height: sh * .02),

                              GlassCard(
                                child: Column(
                                  children: [
                                    _ActivityTile(
                                      icon: Icons.restaurant_menu,
                                      title: "Meal Plan",
                                      subtitle: mealExists
                                          ? "Your 2-day AI meal plan is active"
                                          : "Meal plan not generated yet",
                                      color: const Color(0xff355C3B),
                                    ),

                                    const Divider(
                                      height: 28,
                                      color: Colors.black,
                                      thickness: 1,
                                    ),

                                    _ActivityTile(
                                      icon: Icons.fitness_center,
                                      title: "Workout Plan",
                                      subtitle: workoutExists
                                          ? "Workout schedule is ready"
                                          : "Workout plan not generated",
                                      color: const Color(0xff1E4027),
                                    ),

                                    const Divider(
                                      height: 28,
                                      color: Colors.black,
                                      thickness: 1,
                                    ),

                                    _ActivityTile(
                                      icon: Icons.schedule,
                                      title: "Meal Plan Status",
                                      subtitle: mealExpired
                                          ? "Expired • Generate a new plan"
                                          : "Expires in $mealRemaining",
                                      color: mealExpired
                                          ? Colors.red
                                          : const Color(0xff355C3B),
                                    ),

                                    const Divider(
                                      height: 28,
                                      color: Colors.black,
                                      thickness: 1,
                                    ),

                                    _ActivityTile(
                                      icon: Icons.schedule,
                                      title: "Workout Plan Status",
                                      subtitle: mealExpired
                                          ? "Expired • Generate a new plan"
                                          : "Expires in $workoutRemaining",
                                      color: workoutExpired
                                          ? Colors.red
                                          : const Color(0xff355C3B),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: sh * .03),

                              GradientButton(
                                text: "View Progress",
                                icon: Icons.person_outline,
                                onTap: () {
                                  // TODO:
                                  // Navigate to Profile Screen
                                },
                              ),

                              SizedBox(height: sh * .04),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color(0xffA8DB69),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(50),
            ),
            onPressed: () {
              // Add your action code here!
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiCoachScreen()),
              );
            },
            child: const Icon(Icons.smart_toy, color: Color(0xff1E4027)),
          ),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const GlassCard({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xff355C3B).withOpacity(.22),
                    const Color(0xff1E4027).withOpacity(.10),
                  ],
                ),
                border: Border.all(color: Colors.white.withOpacity(.25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xff355C3B), Color(0xff1E4027)],
              ),
            ),
            child: Icon(icon, color: Colors.white),
          ),

          const SizedBox(height: 14),

          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff1E2B22),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const GradientButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xff355C3B), Color(0xff4F7A57), Color(0xff1E4027)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff355C3B).withOpacity(.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),

                const SizedBox(width: 12),

                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(.12),
          ),
          child: Icon(icon, color: color),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 4),

              Text(subtitle, style: TextStyle(color: Colors.black)),
            ],
          ),
        ),
      ],
    );
  }
}
