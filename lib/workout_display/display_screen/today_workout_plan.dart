import 'package:flutter/material.dart';

import '../models/workout_day_model.dart';
import '../models/workout_plan_model.dart';
import '../services/workout_repository.dart';
import 'workout_day_details.dart';

class TodayWorkoutPlan extends StatefulWidget {
  const TodayWorkoutPlan({super.key});

  @override
  State<TodayWorkoutPlan> createState() => _TodayWorkoutPlanState();
}

class _TodayWorkoutPlanState extends State<TodayWorkoutPlan> {
  final WorkoutRepository _repository = WorkoutRepository.instance;

  late Future<WorkoutPlanModel?> _planFuture;

  @override
  void initState() {
    super.initState();

    _planFuture = _repository.getWorkoutPlan();
  }

  // ===========================================================================
  // REFRESH
  // ===========================================================================

  Future<void> _refresh() async {
    setState(() {
      _planFuture = _repository.getWorkoutPlan();
    });

    await _planFuture;
  }

  // ===========================================================================
  // TODAY'S DAY NAME
  // ===========================================================================

  String _getTodayName() {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[DateTime.now().weekday - 1];
  }

  // ===========================================================================
  // GET TODAY'S WORKOUT
  // ===========================================================================

  WorkoutDayModel? _getTodayWorkout(WorkoutPlanModel plan) {
    final today = _getTodayName();

    // First try exact weekday match.
    if (plan.days.containsKey(today)) {
      return plan.days[today];
    }

    // Fallback in case keys have different capitalization.
    for (final entry in plan.days.entries) {
      if (entry.key.toLowerCase() == today.toLowerCase()) {
        return entry.value;
      }
    }

    return null;
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final today = _getTodayName();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EF),

      // ========================================================================
      // APP BAR
      // ========================================================================
      appBar: AppBar(
        title: const Text(
          "Today's Workout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        centerTitle: true,

        backgroundColor: Colors.white,

        elevation: 0,

        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),

      // ========================================================================
      // BODY
      // ========================================================================
      body: RefreshIndicator(
        onRefresh: _refresh,

        child: FutureBuilder<WorkoutPlanModel?>(
          future: _planFuture,

          builder: (context, snapshot) {
            // ==================================================================
            // LOADING
            // ==================================================================

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // ==================================================================
            // ERROR
            // ==================================================================

            if (snapshot.hasError) {
              return _ErrorView(
                message: snapshot.error.toString(),
                onRetry: _refresh,
              );
            }

            // ==================================================================
            // NO PLAN
            // ==================================================================

            final plan = snapshot.data;

            if (plan == null || plan.days.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 250,
                    child: Center(
                      child: Text(
                        'No workout plan found.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            // ==================================================================
            // TODAY'S WORKOUT
            // ==================================================================

            final todayWorkout = _getTodayWorkout(plan);

            if (todayWorkout == null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 100),

                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 60,
                    color: Color(0xFF7C6253),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'No workout found for $today.',
                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Check your weekly workout plan.',
                    textAlign: TextAlign.center,

                    style: TextStyle(color: Colors.black54),
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      icon: const Icon(Icons.calendar_view_week),

                      label: const Text('View Weekly Plan'),
                    ),
                  ),
                ],
              );
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),

              padding: const EdgeInsets.all(16),

              children: [
                // ==============================================================
                // TODAY HEADER
                // ==============================================================
                _TodayHeaderCard(day: todayWorkout, plan: plan),

                const SizedBox(height: 20),

                // ==============================================================
                // WORKOUT INFORMATION
                // ==============================================================
                if (!todayWorkout.restDay &&
                    todayWorkout.workout.isNotEmpty) ...[
                  const Text(
                    "Today's Exercises",
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  // ============================================================
                  // EXERCISE PREVIEW
                  // ============================================================
                  ...List.generate(todayWorkout.workout.length, (index) {
                    final exercise = todayWorkout.workout[index];

                    return _ExercisePreviewCard(
                      exercise: exercise,
                      index: index,
                    );
                  }),

                  const SizedBox(height: 8),

                  // ============================================================
                  // OPEN FULL WORKOUT
                  // ============================================================
                  SizedBox(
                    width: double.infinity,
                    height: 54,

                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                WorkoutDayDetails(workoutDay: todayWorkout),
                          ),
                        );
                      },

                      icon: const Icon(Icons.play_arrow_rounded),

                      label: const Text(
                        "Start Today's Workout",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C6253),
                        foregroundColor: Colors.white,

                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ]
                // ==============================================================
                // REST DAY
                // ==============================================================
                else
                  _RestDayCard(day: todayWorkout),
              ],
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// TODAY HEADER CARD
// =============================================================================

class _TodayHeaderCard extends StatelessWidget {
  final WorkoutDayModel day;
  final WorkoutPlanModel plan;

  const _TodayHeaderCard({required this.day, required this.plan});

  @override
  Widget build(BuildContext context) {
    final bool isRest = day.restDay || day.workout.isEmpty;

    final String duration = day.estimatedDuration.isEmpty
        ? '--'
        : day.estimatedDuration;

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
          // ===================================================================
          // TODAY LABEL
          // ===================================================================
          Row(
            children: [
              Container(
                width: 48,
                height: 48,

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  borderRadius: BorderRadius.circular(15),
                ),

                child: Icon(
                  isRest ? Icons.self_improvement : Icons.fitness_center,

                  color: Colors.white,

                  size: 26,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'TODAY',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      day.dayName,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ===================================================================
          // FOCUS
          // ===================================================================
          Text(
            isRest
                ? (day.activity.isEmpty ? 'Rest Day' : day.activity)
                : (day.focus.isEmpty ? 'Workout' : day.focus),

            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // ===================================================================
          // STATS
          // ===================================================================
          Row(
            children: [
              Expanded(
                child: _HeaderStat(
                  icon: Icons.fitness_center,
                  value: isRest ? 'Rest' : '${day.workout.length}',
                  label: isRest ? 'Today' : 'Exercises',
                ),
              ),

              Expanded(
                child: _HeaderStat(
                  icon: Icons.timer_outlined,
                  value: duration,
                  label: 'Duration',
                ),
              ),

              Expanded(
                child: _HeaderStat(
                  icon: Icons.calendar_today_outlined,
                  value: plan.totalDays.toString(),
                  label: 'Plan Days',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// HEADER STAT
// =============================================================================

class _HeaderStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _HeaderStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 19),

        const SizedBox(height: 5),

        Text(
          value,

          maxLines: 1,
          overflow: TextOverflow.ellipsis,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          label,

          textAlign: TextAlign.center,

          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}

// =============================================================================
// EXERCISE PREVIEW CARD
// =============================================================================

class _ExercisePreviewCard extends StatelessWidget {
  final dynamic exercise;
  final int index;

  const _ExercisePreviewCard({required this.exercise, required this.index});

  @override
  Widget build(BuildContext context) {
    final String name =
        exercise.exerciseName?.toString() ??
        exercise.name?.toString() ??
        'Exercise ${index + 1}';

    final String sets = exercise.sets?.toString() ?? '';

    final String reps = exercise.reps?.toString() ?? '';

    final String duration = exercise.duration?.toString() ?? '';

    String prescription = '';

    if (sets.isNotEmpty && reps.isNotEmpty) {
      prescription = '$sets sets • $reps reps';
    } else if (sets.isNotEmpty) {
      prescription = '$sets sets';
    } else if (reps.isNotEmpty) {
      prescription = '$reps reps';
    } else if (duration.isNotEmpty) {
      prescription = duration;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(15),

        child: Row(
          children: [
            // =================================================================
            // NUMBER
            // =================================================================
            Container(
              width: 40,
              height: 40,

              alignment: Alignment.center,

              decoration: BoxDecoration(
                color: const Color(0xFFE7D9CF),
                borderRadius: BorderRadius.circular(12),
              ),

              child: Text(
                '${index + 1}',

                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A5144),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // =================================================================
            // EXERCISE NAME
            // =================================================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    name,

                    maxLines: 2,

                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (prescription.isNotEmpty) ...[
                    const SizedBox(height: 4),

                    Text(
                      prescription,

                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // =================================================================
            // ARROW
            // =================================================================
            const Icon(Icons.chevron_right, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// REST DAY
// =============================================================================

class _RestDayCard extends StatelessWidget {
  final WorkoutDayModel day;

  const _RestDayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: const Color(0xFFE3D9D1)),
      ),

      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,

            decoration: BoxDecoration(
              color: const Color(0xFFE8DED7),
              borderRadius: BorderRadius.circular(22),
            ),

            child: const Icon(
              Icons.self_improvement,
              color: Color(0xFF6A5144),
              size: 36,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Rest Day',

            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            day.activity.isEmpty
                ? 'Take time to recover and recharge.'
                : day.activity,

            textAlign: TextAlign.center,

            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),

          const SizedBox(height: 16),

          if (day.notes.isNotEmpty)
            Text(
              day.notes,

              textAlign: TextAlign.center,

              style: const TextStyle(color: Colors.black45, fontSize: 13),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// ERROR VIEW
// =============================================================================

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

            const Text(
              'Unable to load today\'s workout',

              textAlign: TextAlign.center,

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              message,

              textAlign: TextAlign.center,

              maxLines: 4,

              overflow: TextOverflow.ellipsis,

              style: const TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: onRetry,

              icon: const Icon(Icons.refresh),

              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
