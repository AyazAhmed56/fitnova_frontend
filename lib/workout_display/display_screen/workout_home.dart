import 'dart:ui';

import 'package:fitnova/ai_coach/ai_coach_screen.dart';
import 'package:fitnova/services/supabase_service.dart';
import 'package:fitnova/settings/settings.dart';
import 'package:fitnova/workout_display/display_screen/weekly_workout_plan.dart';
// import 'package:dietplan/workout_display/display_screen/workout_day_details.dart';
import 'package:fitnova/workout_display/display_screen/workout_history.dart';
import 'package:fitnova/workout_display/display_screen/workout_progress.dart';
import 'package:fitnova/workout_display/display_screen/workout_search.dart';
import 'package:fitnova/workout_display/display_screen/workout_session.dart';
// import 'package:dietplan/workout_display/display_screen/workout_settings.dart';
import 'package:fitnova/workout_display/display_screen/workout_summary.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout_day_model.dart';
import '../models/workout_plan_model.dart';
import '../services/workout_repository.dart';
// import '../widget/day_card.dart';

class WorkoutHome extends StatefulWidget {
  const WorkoutHome({super.key});

  @override
  State<WorkoutHome> createState() => _WorkoutHomeState();
}

class _WorkoutHomeState extends State<WorkoutHome> {
  final WorkoutRepository _repository = WorkoutRepository.instance;
  bool generateWorkoutPlan = false;
  late Future<WorkoutPlanModel?> _planFuture;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  void _loadPlan() {
    _planFuture = _repository.getWorkoutPlan();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadPlan();
    });

    await _planFuture;
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/workout_background.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.9),
            BlendMode.modulate,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text(
            "Workout",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Navigate to WorkoutSearchScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WorkoutSearchScreen(),
                  ),
                );
              },
            ),
          ],
        ),

        body: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<WorkoutPlanModel?>(
            future: _planFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final WorkoutPlanModel? plan = snapshot.data;
              if (plan == null) {
                return const Placeholder(
                  child: Center(child: Text("Empty page value is null")),
                );
              }
              const totalDuration = Duration(days: 30);

              final expiry = plan.createdAt.add(totalDuration);

              final remaining = expiry.difference(DateTime.now());

              final workoutProgress = remaining.isNegative
                  ? 0.0
                  : (remaining.inSeconds / totalDuration.inSeconds).clamp(
                      0.0,
                      1.0,
                    );

              final remainingDays = remaining.inDays.clamp(0, 30);
              final workoutExpired = remaining.isNegative;

              if (workoutExpired) {
                return SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(sw * .06),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fitness_center_rounded,
                            size: sw * .22,
                            color: Colors.orange,
                          ),

                          SizedBox(height: sh * .03),

                          Text(
                            "Workout Plan Expired",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: sw * .065,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: sh * .018),

                          Text(
                            "Your AI workout plan has completed its 30-day training cycle.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: sw * .042,
                              color: Colors.grey.shade700,
                            ),
                          ),

                          SizedBox(height: sh * .012),

                          Text(
                            "Generate a fresh workout plan based on your latest fitness progress to continue improving safely and effectively.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: sw * .038,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          SizedBox(height: sh * .05),

                          SizedBox(
                            width: double.infinity,
                            height: sh * .065,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text("Generate New Workout"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3A6F4B),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: generateWorkoutPlan
                                  ? null
                                  : () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text(
                                              "Generate New Plan",
                                            ),

                                            content: const Text(
                                              "This will replace your current workout plan. Continue?",
                                            ),

                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, false);
                                                },

                                                child: const Text("Cancel"),
                                              ),

                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context, true);
                                                },

                                                child: const Text("Generate"),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (confirm != true) return;

                                      final messenger = ScaffoldMessenger.of(
                                        context,
                                      );

                                      try {
                                        setState(() {
                                          generateWorkoutPlan = true;
                                        });

                                        final user = Supabase
                                            .instance
                                            .client
                                            .auth
                                            .currentUser;

                                        if (user == null) return;

                                        await SupabaseService()
                                            .generateAndSavePlans(user.id);

                                        if (mounted) {
                                          setState(() {});
                                        }

                                        if (!mounted) return;

                                        messenger.showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "New workout plan generated successfully",
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        if (!mounted) return;

                                        messenger.showSnackBar(
                                          SnackBar(content: Text(e.toString())),
                                        );
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            generateWorkoutPlan = false;
                                          });
                                        }
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final List<WorkoutDayModel> days = plan.allDays;

              final WorkoutDayModel today = days.first;

              final totalExercises = days.fold<int>(
                0,
                (sum, day) => sum + day.workout.length,
              );

              final totalWarmups = days.fold<int>(
                0,
                (sum, day) => sum + day.warmUp.length,
              );

              final totalCooldowns = days.fold<int>(
                0,
                (sum, day) => sum + day.coolDown.length,
              );

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: sh * .03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.15),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Today's Workout",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: sw * .060,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  today.focus,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: sw * .040,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                Row(
                                  children: [
                                    Expanded(
                                      child: _StatTile(
                                        icon: Icons.schedule,
                                        title: "Duration",
                                        value: today.estimatedDuration,
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: _StatTile(
                                        icon: Icons.bar_chart,
                                        title: "Difficulty",
                                        value: today.difficulty,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(.25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.timer,
                                color: Colors.greenAccent,
                              ),

                              const SizedBox(width: 10),

                              const Expanded(
                                child: Text(
                                  "Workout Plan",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ),

                              Text(
                                "$remainingDays Days Left",
                                style: TextStyle(
                                  color: Colors.greenAccent.shade100,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: workoutProgress,
                              minHeight: 10,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation(
                                Colors.greenAccent,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "${(workoutProgress * 100).toInt()}% Remaining",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18),

                    Container(
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Marquee(
                        text:
                            " 🔁 Repeat the same workout for every 4 weeks • Maintain proper form • Progressive overload • Stay consistent • ",
                        blankSpace: 80,
                        velocity: 35,
                        pauseAfterRound: const Duration(seconds: 1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        "Quick Actions",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw * .050,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 1.45,
                        children: [
                          _ActionCard(
                            icon: Icons.calendar_month,
                            title: "Weekly Plan",
                            color: const Color.fromARGB(255, 2, 250, 176),
                            onTap: () {
                              // Navigate to WeeklyWorkoutPlan
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WeeklyWorkoutPlan(),
                                ),
                              );
                            },
                          ),
                          _ActionCard(
                            icon: Icons.play_circle_fill,
                            title: "Start Workout",
                            color: const Color.fromARGB(255, 252, 2, 85),
                            onTap: () {
                              // Navigate to WorkoutSessionScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      WorkoutSessionScreen(workoutDay: today),
                                ),
                              );
                            },
                          ),
                          _ActionCard(
                            icon: Icons.show_chart,
                            title: "Progress",
                            color: const Color.fromARGB(255, 2, 248, 84),
                            onTap: () {
                              // Navigate to WorkoutProgressScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WorkoutProgressScreen(),
                                ),
                              );
                            },
                          ),
                          _ActionCard(
                            icon: Icons.history,
                            title: "History",
                            color: const Color.fromARGB(255, 91, 2, 245),
                            onTap: () {
                              // Navigate to WorkoutHistoryScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WorkoutHistoryScreen(),
                                ),
                              );
                            },
                          ),
                          _ActionCard(
                            icon: Icons.insights,
                            title: "Summary",
                            color: const Color.fromARGB(255, 1, 248, 223),
                            onTap: () {
                              // Navigate to WorkoutSummaryScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WorkoutSummaryScreen(),
                                ),
                              );
                            },
                          ),
                          _ActionCard(
                            icon: Icons.settings,
                            title: "Settings",
                            color: Colors.grey.shade200,
                            onTap: () {
                              // Navigate to WorkoutSettingsScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const Settings(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        "Workout Overview",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw * .050,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.6,
                        children: [
                          _InfoCard(
                            icon: Icons.calendar_today,
                            title: "Days",
                            value: "${plan.totalDays}",
                          ),

                          _InfoCard(
                            icon: Icons.fitness_center,
                            title: "Exercises",
                            value: "$totalExercises",
                          ),

                          _InfoCard(
                            icon: Icons.local_fire_department,
                            title: "Warm Ups",
                            value: "$totalWarmups",
                          ),

                          _InfoCard(
                            icon: Icons.self_improvement,
                            title: "Cool Downs",
                            value: "$totalCooldowns",
                          ),
                        ],
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 18),
                    //   child: Text(
                    //     "Workout Days",
                    //     style: TextStyle(
                    //       fontSize: sw * .050,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    // ),

                    // const SizedBox(height: 14),

                    // ListView.builder(
                    //   shrinkWrap: true,
                    //   physics: const NeverScrollableScrollPhysics(),
                    //   itemCount: days.length,
                    //   itemBuilder: (context, index) {
                    //     final day = days[index];

                    //     return DayCard(
                    //       day: day,
                    //       isToday: index == 0,
                    //       isCompleted: false,
                    // onTap: () {
                    //   // Navigate to WorkoutDayDetails
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (_) =>
                    //           WorkoutDayDetails(workoutDay: day),
                    //     ),
                    //   );
                    // },
                    //     );
                    //   },
                    // ),

                    // SizedBox(height: sh * .04),
                  ],
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color.fromARGB(255, 136, 148, 121),
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
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(.50),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(.12),
                child: Icon(icon, color: color, size: 28),
              ),

              SizedBox(height: 4),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color.fromARGB(255, 2, 252, 10)),
              SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            value.isEmpty ? "-" : value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(.30),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color.fromARGB(255, 2, 252, 10)),
              SizedBox(width: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade200,
            ),
          ),
        ],
      ),
    );
  }
}
