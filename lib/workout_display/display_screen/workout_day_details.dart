import 'package:flutter/material.dart';

import '../models/exercise_model.dart';
import '../models/workout_day_model.dart';

class WorkoutDayDetails extends StatelessWidget {
  final WorkoutDayModel workoutDay;

  const WorkoutDayDetails({super.key, required this.workoutDay});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EF),

      appBar: AppBar(
        title: Text(
          workoutDay.dayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          _Header(day: workoutDay),

          const SizedBox(height: 20),

          if (workoutDay.restDay || workoutDay.workout.isEmpty)
            _RestDayCard(day: workoutDay)
          else ...[
            if (workoutDay.warmUp.isNotEmpty)
              _Section(
                title: 'Warm Up',
                icon: Icons.directions_run,
                child: Column(
                  children: workoutDay.warmUp
                      .map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            item.exerciseName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('${item.bodyPart} • ${item.duration}'),
                        ),
                      )
                      .toList(),
                ),
              ),

            const SizedBox(height: 16),

            _Section(
              title: 'Main Workout',
              icon: Icons.fitness_center,
              child: Column(
                children: [
                  for (int i = 0; i < workoutDay.workout.length; i++)
                    _ExerciseCard(
                      exercise: workoutDay.workout[i],
                      number: i + 1,
                    ),
                ],
              ),
            ),

            if (workoutDay.stretching.isNotEmpty) ...[
              const SizedBox(height: 16),

              _Section(
                title: 'Stretching',
                icon: Icons.self_improvement,
                child: Column(
                  children: workoutDay.stretching
                      .map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            item.exerciseName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('${item.bodyPart} • ${item.duration}'),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],

            if (workoutDay.coolDown.isNotEmpty) ...[
              const SizedBox(height: 16),

              _Section(
                title: 'Cool Down',
                icon: Icons.accessibility_new,
                child: Column(
                  children: workoutDay.coolDown
                      .map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            item.exerciseName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(item.duration),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],

            if (workoutDay.dailyTips.isNotEmpty) ...[
              const SizedBox(height: 16),

              _Section(
                title: 'Daily Tips',
                icon: Icons.lightbulb_outline,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: workoutDay.dailyTips
                      .map(
                        (tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('• $tip'),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],

            if (workoutDay.precautions.isNotEmpty) ...[
              const SizedBox(height: 16),

              _Section(
                title: 'Precautions',
                icon: Icons.warning_amber,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: workoutDay.precautions
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('• $item'),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ],

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ============================================================
// HEADER
// ============================================================

class _Header extends StatelessWidget {
  final WorkoutDayModel day;

  const _Header({required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),

        gradient: const LinearGradient(
          colors: [Color(0xFF7C6253), Color(0xFFB79B87)],
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            day.focus.isEmpty ? 'Workout' : day.focus,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          if (day.estimatedDuration.isNotEmpty)
            Text(
              day.estimatedDuration,
              style: const TextStyle(color: Colors.white70),
            ),

          if (day.difficulty.isNotEmpty)
            Text(
              'Difficulty: ${day.difficulty}',
              style: const TextStyle(color: Colors.white70),
            ),

          if (day.motivation.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              day.motivation,
              style: const TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// EXERCISE CARD
// ============================================================

class _ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final int number;

  const _ExerciseCard({required this.exercise, required this.number});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),

      elevation: 1,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      clipBehavior: Clip.antiAlias,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ==================================================
          // GIF
          // ==================================================
          if (exercise.gifUrl != null && exercise.gifUrl!.trim().isNotEmpty)
            SizedBox(
              height: 230,
              width: double.infinity,

              child: Image.network(
                exercise.gifUrl!,
                fit: BoxFit.contain,

                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const Center(child: CircularProgressIndicator());
                },

                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image_outlined, size: 45),
                  );
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 17, child: Text('$number')),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        exercise.exerciseName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,

                  children: [
                    if (exercise.sets.isNotEmpty)
                      _Chip('${exercise.sets} sets'),

                    if (exercise.reps.isNotEmpty)
                      _Chip('${exercise.reps} reps'),

                    if (exercise.rest.isNotEmpty)
                      _Chip('Rest ${exercise.rest}'),

                    if (exercise.tempo.isNotEmpty)
                      _Chip('Tempo ${exercise.tempo}'),
                  ],
                ),

                if (exercise.targetMuscles.isNotEmpty) ...[
                  const SizedBox(height: 14),

                  _Label(title: 'Target Muscles'),

                  const SizedBox(height: 6),

                  Text(exercise.targetMuscles.join(', ')),
                ],

                if (exercise.bodyParts.isNotEmpty) ...[
                  const SizedBox(height: 12),

                  _Label(title: 'Body Part'),

                  const SizedBox(height: 6),

                  Text(exercise.bodyParts.join(', ')),
                ],

                if (exercise.equipments.isNotEmpty) ...[
                  const SizedBox(height: 12),

                  _Label(title: 'Equipment'),

                  const SizedBox(height: 6),

                  Text(exercise.equipments.join(', ')),
                ],

                // ==========================================
                // SUPABASE INSTRUCTIONS
                // ==========================================
                if (exercise.instructions.isNotEmpty) ...[
                  const SizedBox(height: 16),

                  _Label(title: 'How To Perform'),

                  const SizedBox(height: 8),

                  ...List.generate(
                    exercise.instructions.length,

                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 7),

                      child: Text(
                        '${index + 1}. '
                        '${exercise.instructions[index]}',
                      ),
                    ),
                  ),
                ],

                // ==========================================
                // GEMINI TIPS
                // ==========================================
                if (exercise.tips.isNotEmpty) ...[
                  const SizedBox(height: 16),

                  _Label(title: 'Trainer Tips'),

                  const SizedBox(height: 8),

                  ...exercise.tips.map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('• $tip'),
                    ),
                  ),
                ],

                // ==========================================
                // PRECAUTIONS
                // ==========================================
                if (exercise.precautions.isNotEmpty) ...[
                  const SizedBox(height: 16),

                  _Label(title: 'Precautions'),

                  const SizedBox(height: 8),

                  ...exercise.precautions.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('• $item'),
                    ),
                  ),
                ],

                // ==========================================
                // COMMON MISTAKES
                // ==========================================
                if (exercise.commonMistakes.isNotEmpty) ...[
                  const SizedBox(height: 16),

                  _Label(title: 'Common Mistakes'),

                  const SizedBox(height: 8),

                  ...exercise.commonMistakes.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('• $item'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// REST DAY
// ============================================================

class _RestDayCard extends StatelessWidget {
  final WorkoutDayModel day;

  const _RestDayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),

        child: Column(
          children: [
            const Icon(Icons.self_improvement, size: 60),

            const SizedBox(height: 14),

            Text(
              day.activity.isEmpty ? 'Recovery Day' : day.activity,

              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 14),

            ...day.recoveryTips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('• $tip', textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SECTION
// ============================================================

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _Section({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Icon(icon),

                const SizedBox(width: 8),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            child,
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SMALL WIDGETS
// ============================================================

class _Chip extends StatelessWidget {
  final String text;

  const _Chip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFEDE4DD),
      ),

      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String title;

  const _Label({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }
}
