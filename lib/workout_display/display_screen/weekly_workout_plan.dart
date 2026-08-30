import 'package:flutter/material.dart';

import '../models/workout_day_model.dart';
import '../models/workout_plan_model.dart';
import '../services/workout_repository.dart';
import 'workout_day_details.dart';

class WeeklyWorkoutPlan extends StatefulWidget {
  const WeeklyWorkoutPlan({super.key});

  @override
  State<WeeklyWorkoutPlan> createState() => _WeeklyWorkoutPlanState();
}

class _WeeklyWorkoutPlanState extends State<WeeklyWorkoutPlan> {
  final WorkoutRepository _repository = WorkoutRepository.instance;

  late Future<WorkoutPlanModel?> _planFuture;

  @override
  void initState() {
    super.initState();

    _planFuture = _repository.getWorkoutPlan();
  }

  Future<void> _refresh() async {
    setState(() {
      _planFuture = _repository.getWorkoutPlan();
    });

    await _planFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EF),

      appBar: AppBar(
        title: const Text(
          'Weekly Workout Plan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
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
              return _ErrorView(
                message: snapshot.error.toString(),
                onRetry: _refresh,
              );
            }

            final plan = snapshot.data;

            if (plan == null || plan.days.isEmpty) {
              return const Center(
                child: Text(
                  'No workout plan found.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              );
            }

            final days = _orderedDays(plan);

            final totalExercises = days.fold<int>(
              0,
              (total, day) => total + day.workout.length,
            );

            final workoutDays = days
                .where((day) => !day.restDay && day.workout.isNotEmpty)
                .length;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _SummaryCard(
                  plan: plan,
                  workoutDays: workoutDays,
                  totalExercises: totalExercises,
                ),

                const SizedBox(height: 20),

                const Text(
                  '7-Day Schedule',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                ...days.map(
                  (day) => _DayCard(
                    day: day,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkoutDayDetails(workoutDay: day),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<WorkoutDayModel> _orderedDays(WorkoutPlanModel plan) {
    const order = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return order
        .where(plan.days.containsKey)
        .map((day) => plan.days[day]!)
        .toList();
  }
}

// ============================================================
// SUMMARY
// ============================================================

class _SummaryCard extends StatelessWidget {
  final WorkoutPlanModel plan;
  final int workoutDays;
  final int totalExercises;

  const _SummaryCard({
    required this.plan,
    required this.workoutDays,
    required this.totalExercises,
  });

  @override
  Widget build(BuildContext context) {
    final summary = plan.weeklySummary;

    final goal = summary['goal']?.toString() ?? '';

    final level = summary['fitnessLevel']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C6253), Color(0xFFB79B87)],
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Your Weekly Program',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (goal.isNotEmpty) ...[
            const SizedBox(height: 8),

            Text(
              goal,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ],

          if (level.isNotEmpty) ...[
            const SizedBox(height: 4),

            Text(level, style: const TextStyle(color: Colors.white70)),
          ],

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _Stat(
                  label: 'Workout Days',
                  value: workoutDays.toString(),
                ),
              ),

              Expanded(
                child: _Stat(
                  label: 'Exercises',
                  value: totalExercises.toString(),
                ),
              ),

              Expanded(
                child: _Stat(label: 'Days', value: plan.totalDays.toString()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

// ============================================================
// DAY CARD
// ============================================================

class _DayCard extends StatelessWidget {
  final WorkoutDayModel day;
  final VoidCallback onTap;

  const _DayCard({required this.day, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isRest = day.restDay || day.workout.isEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      elevation: 1,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(17),

          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isRest
                      ? const Color(0xFFE6DED7)
                      : const Color(0xFFD8C4B5),
                ),

                child: Icon(
                  isRest ? Icons.self_improvement : Icons.fitness_center,
                  color: const Color(0xFF5E493D),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      day.dayName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      isRest
                          ? day.activity.isEmpty
                                ? 'Rest Day'
                                : day.activity
                          : day.focus.isEmpty
                          ? 'Workout'
                          : day.focus,

                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(color: Colors.black54),
                    ),

                    if (!isRest && day.estimatedDuration.isNotEmpty) ...[
                      const SizedBox(height: 5),

                      Text(
                        '${day.workout.length} exercises • ${day.estimatedDuration}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ERROR
// ============================================================

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const Icon(Icons.error_outline, size: 50),

            const SizedBox(height: 12),

            Text(message, textAlign: TextAlign.center),

            const SizedBox(height: 16),

            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
