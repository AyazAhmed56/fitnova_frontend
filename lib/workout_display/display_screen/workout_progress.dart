import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/workout_day_model.dart';
import '../models/workout_plan_model.dart';
import '../services/workout_repository.dart';

class WorkoutProgressScreen extends StatefulWidget {
  const WorkoutProgressScreen({super.key});

  @override
  State<WorkoutProgressScreen> createState() => _WorkoutProgressScreenState();
}

class _WorkoutProgressScreenState extends State<WorkoutProgressScreen> {
  final WorkoutRepository _repository = WorkoutRepository.instance;

  late Future<WorkoutPlanModel?> _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = _repository.getWorkoutPlan();
  }

  Future<void> _refresh() async {
    setState(() {
      _progressFuture = _repository.getWorkoutPlan();
    });

    await _progressFuture;
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
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text(
            "Workout Progress",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        body: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<WorkoutPlanModel?>(
            future: _progressFuture,
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

              if (plan == null || plan.allDays.isEmpty) {
                return const Center(
                  child: Text(
                    "No Workout Progress Available",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                );
              }

              final List<WorkoutDayModel> days = plan.allDays;

              final int totalDays = days.length;
              final int completedDays = 0;
              final int remainingDays = totalDays - completedDays;

              final double progress = totalDays == 0
                  ? 0
                  : completedDays / totalDays;

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
                                Row(
                                  children: [
                                    Icon(
                                      Icons.show_chart,
                                      color: Colors.white,
                                      size: 42,
                                    ),
                                    SizedBox(width: 16),
                                    Text(
                                      "Workout Progress",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: sw * .060,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  "${(progress * 100).toStringAsFixed(0)}% Completed",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: sw * .040,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 10,
                                  borderRadius: BorderRadius.circular(30),
                                ),

                                const SizedBox(height: 20),

                                Row(
                                  children: [
                                    Expanded(
                                      child: _StatTile(
                                        icon: Icons.check_circle,
                                        title: "Completed",
                                        value: "$completedDays",
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: _StatTile(
                                        icon: Icons.pending,
                                        title: "Remaining",
                                        value: "$remainingDays",
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        "Workout Statistics",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw * .050,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.15),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _StatTile(
                                  icon: Icons.calendar_today,
                                  title: "Total Days",
                                  value: "$totalDays",
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: _StatTile(
                                  icon: Icons.fitness_center,
                                  title: "Exercises",
                                  value:
                                      "${days.fold<int>(0, (sum, day) => sum + day.workout.length)}",
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: _StatTile(
                                  icon: Icons.local_fire_department,
                                  title: "Warm Ups",
                                  value:
                                      "${days.fold<int>(0, (sum, day) => sum + day.warmUp.length)}",
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: _StatTile(
                                  icon: Icons.self_improvement,
                                  title: "Cool Downs",
                                  value:
                                      "${days.fold<int>(0, (sum, day) => sum + day.coolDown.length)}",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        "Workout Days",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw * .050,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    ...days.asMap().entries.map((entry) {
                      final index = entry.key;
                      final day = entry.value;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    day.dayName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    day.focus,
                                    style: TextStyle(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Icon(
                              completedDays > index
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: completedDays > index
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      );
                    }),

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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color.fromARGB(255, 1, 252, 9)),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
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
