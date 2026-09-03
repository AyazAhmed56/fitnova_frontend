import 'dart:ui';

import 'package:fitnova/ai_coach/ai_coach_screen.dart';
import 'package:fitnova/services/supabase_service.dart';
import 'package:fitnova/settings/settings.dart';
import 'package:fitnova/workout_display/display_screen/weekly_workout_plan.dart';
import 'package:fitnova/workout_display/display_screen/workout_history.dart';
import 'package:fitnova/workout_display/display_screen/workout_progress.dart';
import 'package:fitnova/workout_display/display_screen/workout_search.dart';
import 'package:fitnova/workout_display/display_screen/workout_session.dart';
import 'package:fitnova/workout_display/display_screen/workout_summary.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/workout_day_model.dart';
import '../models/workout_plan_model.dart';
import '../services/workout_repository.dart';

class WorkoutHome extends StatefulWidget {
  const WorkoutHome({super.key});

  @override
  State<WorkoutHome> createState() => _WorkoutHomeState();
}

class _WorkoutHomeState extends State<WorkoutHome> {
  final WorkoutRepository _repository = WorkoutRepository.instance;

  bool generating = false;

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

  // ============================================================
  // GENERATE WORKOUT
  // ============================================================

  Future<void> _generateWorkout() async {
    if (generating) return;

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      _showMessage("Please log in again.", Colors.red);
      return;
    }

    setState(() {
      generating = true;
    });

    try {
      final profile = await SupabaseService().getUserProfile(user.id);

      if (profile == null) {
        throw Exception("User profile not found.");
      }

      await _repository.generateAndSaveWorkoutPlan(profile);

      if (!mounted) return;

      setState(() {
        _loadPlan();
      });

      await _planFuture;

      if (!mounted) return;

      _showMessage("Workout plan generated successfully.", Colors.green);
    } catch (e) {
      if (!mounted) return;

      _showMessage(e.toString(), Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          generating = false;
        });
      }
    }
  }

  // ============================================================
  // TODAY
  // ============================================================

  WorkoutDayModel? _getTodayWorkout(WorkoutPlanModel plan) {
    const weekdays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];

    final today = weekdays[DateTime.now().weekday - 1];

    return plan.getDay(today);
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/workout_background.png'),
          fit: BoxFit.cover,
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
                return _errorView(snapshot.error.toString());
              }

              final plan = snapshot.data;

              // --------------------------------------------------
              // NO PLAN
              // --------------------------------------------------

              if (plan == null) {
                return _noPlanView(sw, sh);
              }

              // --------------------------------------------------
              // EXPIRY
              // --------------------------------------------------

              final expiry = plan.createdAt.add(
                SupabaseService.workoutPlanExpiry,
              );

              final remaining = expiry.difference(DateTime.now());

              if (remaining.isNegative) {
                return _expiredView(sw, sh);
              }

              // --------------------------------------------------
              // TODAY
              // --------------------------------------------------

              final today = _getTodayWorkout(plan);

              if (today == null) {
                return _errorView("Today's workout could not be found.");
              }

              final days = plan.allDays;

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

              final progress =
                  (remaining.inSeconds /
                          SupabaseService.workoutPlanExpiry.inSeconds)
                      .clamp(0.0, 1.0);

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ------------------------------------------------
                    // TODAY CARD
                    // ------------------------------------------------
                    _todayCard(sw, sh, today),

                    const SizedBox(height: 20),

                    // ------------------------------------------------
                    // PLAN STATUS
                    // ------------------------------------------------
                    _planStatusCard(progress, remaining.inDays.clamp(0, 30)),

                    const SizedBox(height: 20),

                    // ------------------------------------------------
                    // QUICK ACTIONS
                    // ------------------------------------------------
                    _sectionTitle("Quick Actions", sw),

                    const SizedBox(height: 12),

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
                          _actionCard(Icons.calendar_month, "Weekly Plan", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WeeklyWorkoutPlan(),
                              ),
                            );
                          }),

                          _actionCard(
                            Icons.play_circle_fill,
                            "Start Workout",
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      WorkoutSessionScreen(workoutDay: today),
                                ),
                              );
                            },
                          ),

                          _actionCard(Icons.show_chart, "Progress", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WorkoutProgressScreen(),
                              ),
                            );
                          }),

                          _actionCard(Icons.history, "History", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WorkoutHistoryScreen(),
                              ),
                            );
                          }),

                          _actionCard(Icons.insights, "Summary", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WorkoutSummaryScreen(),
                              ),
                            );
                          }),

                          _actionCard(Icons.settings, "Settings", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Settings(),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ------------------------------------------------
                    // OVERVIEW
                    // ------------------------------------------------
                    _sectionTitle("Workout Overview", sw),

                    const SizedBox(height: 12),

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
                          _infoCard(
                            Icons.calendar_today,
                            "Days",
                            "${plan.totalDays}",
                          ),
                          _infoCard(
                            Icons.fitness_center,
                            "Exercises",
                            "$totalExercises",
                          ),
                          _infoCard(
                            Icons.local_fire_department,
                            "Warm Ups",
                            "$totalWarmups",
                          ),
                          _infoCard(
                            Icons.self_improvement,
                            "Cool Downs",
                            "$totalCooldowns",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF889479),
          onPressed: () {
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

  // ============================================================
  // NO PLAN
  // ============================================================

  Widget _noPlanView(double sw, double sh) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: sw * .20, color: Colors.white),

            const SizedBox(height: 20),

            const Text(
              "No Workout Plan Yet",
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Create your personalized workout plan using your fitness profile.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: generating ? null : _generateWorkout,
                icon: generating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  generating ? "Generating..." : "Generate Workout Plan",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _errorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 55),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _refresh, child: const Text("Retry")),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EXPIRED
  // ============================================================

  Widget _expiredView(double sw, double sh) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center_rounded,
              size: sw * .20,
              color: Colors.orange,
            ),

            const SizedBox(height: 20),

            const Text(
              "Workout Plan Expired",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "Your 30-day workout cycle has completed.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: generating ? null : _generateWorkout,
                icon: generating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(
                  generating ? "Generating..." : "Generate New Workout",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TODAY CARD
  // ============================================================

  Widget _todayCard(double sw, double sh, WorkoutDayModel day) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.35),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Workout",
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            day.restDay ? "Rest Day" : day.focus,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _statTile(
                  Icons.schedule,
                  "Duration",
                  day.estimatedDuration,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statTile(Icons.bar_chart, "Difficulty", day.difficulty),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? "-" : value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PLAN STATUS
  // ============================================================

  Widget _planStatusCard(double progress, int days) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.timer, color: Colors.greenAccent),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Workout Plan",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "$days Days Left",
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.greenAccent),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "${(progress * 100).toInt()}% Remaining",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, double sw) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: sw * .05,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _actionCard(IconData icon, String title, VoidCallback onTap) {
    return Material(
      color: Colors.white.withOpacity(.5),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 20, child: Icon(icon, size: 22)),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.25),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 17),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
