import 'dart:ui';

import 'package:fitnova/workout_display/display_screen/workout_day_details.dart';
import 'package:flutter/material.dart';

import '../models/workout_day_model.dart';
import '../models/workout_plan_model.dart';
import '../services/workout_repository.dart';

class WorkoutSummaryScreen extends StatefulWidget {
  const WorkoutSummaryScreen({super.key});

  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen> {
  final WorkoutRepository _repository = WorkoutRepository.instance;

  late Future<WorkoutPlanModel?> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _repository.getWorkoutPlan();
  }

  Future<void> _refresh() async {
    setState(() {
      _summaryFuture = _repository.getWorkoutPlan();
    });

    await _summaryFuture;
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
            "Workout Summary",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        body: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<WorkoutPlanModel?>(
            future: _summaryFuture,
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

              final plan = snapshot.data;

              if (plan == null || plan.allDays.isEmpty) {
                return const Center(
                  child: Text(
                    "Workout Summary Not Available",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                );
              }

              final List<WorkoutDayModel> days = plan.allDays;
              final int totalExercises = days
                  .where((day) => !day.restDay)
                  .fold<int>(0, (sum, day) => sum + day.workout.length);

              // final int totalWarmups = days.fold<int>(
              //   0,
              //   (sum, day) => sum + day.warmUp.length,
              // );

              // final int totalCooldowns = days.fold<int>(
              //   0,
              //   (sum, day) => sum + day.coolDown.length,
              // );

              // final int totalTips = days.fold<int>(
              //   0,
              //   (sum, day) => sum + day.dailyTips.length,
              // );

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
                                  "Workout Overview",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: sw * .060,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  "${plan.totalDays} Day Training Program",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: sw * .040,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                Row(
                                  children: [
                                    Expanded(
                                      child: _StatTile(
                                        icon: Icons.calendar_today,
                                        title: "Days",
                                        value: "${plan.totalDays}",
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: _StatTile(
                                        icon: Icons.fitness_center,
                                        title: "Exercises",
                                        value: "$totalExercises",
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

                    // const SizedBox(height: 24),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 18),
                    //   child: Text(
                    //     "Overall Statistics",
                    //     style: TextStyle(
                    //       color: Colors.white,
                    //       fontSize: sw * .050,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    // ),

                    // const SizedBox(height: 14),

                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 16),
                    //   child: GridView.count(
                    //     shrinkWrap: true,
                    //     physics: const NeverScrollableScrollPhysics(),
                    //     crossAxisCount: 2,
                    //     crossAxisSpacing: 14,
                    //     mainAxisSpacing: 14,
                    //     childAspectRatio: 1.25,
                    //     children: [
                    //       _StatTile(
                    //         icon: Icons.local_fire_department,
                    //         title: "Warm Ups",
                    //         value: "$totalWarmups",
                    //       ),

                    //       _StatTile(
                    //         icon: Icons.self_improvement,
                    //         title: "Cool Downs",
                    //         value: "$totalCooldowns",
                    //       ),

                    //       _StatTile(
                    //         icon: Icons.lightbulb_outline,
                    //         title: "Daily Tips",
                    //         value: "$totalTips",
                    //       ),

                    //       _StatTile(
                    //         icon: Icons.warning_amber_rounded,
                    //         title: "Precautions",
                    //         value:
                    //             "${days.fold<int>(0, (sum, day) => sum + day.precautions.length)}",
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        "Workout Plan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw * .050,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    ...days.map(
                      (day) => Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(.50),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: InkWell(
                          onTap: () {
                            // Navigate to WorkoutDayDetails
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    WorkoutDayDetails(workoutDay: day),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      day.dayName.replaceAll("Day ", ""),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 6),
                                    Text(
                                      day.restDay ? day.activity : day.focus,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      day.restDay
                                          ? "Recovery Day • ${day.stretching.length} Stretching Exercises"
                                          : "${day.workout.length} Exercises • ${day.estimatedDuration}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: sh * .04),
                  ],
                ),
              );
            },
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
          Icon(icon, color: const Color.fromARGB(255, 2, 245, 10)),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

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
