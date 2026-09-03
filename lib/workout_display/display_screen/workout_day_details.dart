import 'package:flutter/material.dart';

import '../models/exercise_model.dart';
import '../models/workout_day_model.dart';
import '../services/exercise_catalog_service.dart';

class WorkoutDayDetails extends StatefulWidget {
  final WorkoutDayModel workoutDay;

  const WorkoutDayDetails({super.key, required this.workoutDay});

  @override
  State<WorkoutDayDetails> createState() => _WorkoutDayDetailsState();
}

class _WorkoutDayDetailsState extends State<WorkoutDayDetails> {
  final ExerciseCatalogService _catalogService =
      ExerciseCatalogService.instance;

  late Future<List<ExerciseModel>> _enrichedExercisesFuture;

  @override
  void initState() {
    super.initState();
    _enrichedExercisesFuture = _loadEnrichedExercises();
  }

  Future<List<ExerciseModel>> _loadEnrichedExercises() async {
    final originalExercises = widget.workoutDay.workout;

    if (originalExercises.isEmpty) {
      return [];
    }

    return Future.wait(originalExercises.map(_enrichExercise));
  }

  Future<ExerciseModel> _enrichExercise(ExerciseModel exercise) async {
    try {
      final catalog = await _catalogService.findBestMatch(
        exercise.exerciseName,
      );

      if (catalog == null) {
        return exercise;
      }

      return exercise.copyWith(
        exerciseDbId: catalog.exerciseDbId,
        gifUrl: catalog.gifUrl,
        bodyParts: catalog.bodyParts,
        targetMuscles: catalog.targetMuscles,
        catalogSecondaryMuscles: catalog.secondaryMuscles,
        catalogInstructions: catalog.instructions,
        equipmentRequired: catalog.equipments.isNotEmpty
            ? catalog.equipments.join(', ')
            : exercise.equipmentRequired,
      );
    } catch (_) {
      return exercise;
    }
  }

  Future<void> _refreshCatalogData() async {
    setState(() {
      _enrichedExercisesFuture = _loadEnrichedExercises();
    });

    await _enrichedExercisesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EF),
      appBar: AppBar(
        title: Text(
          widget.workoutDay.dayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh exercise data',
            onPressed: _refreshCatalogData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCatalogData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _Header(day: widget.workoutDay),

            const SizedBox(height: 20),

            if (widget.workoutDay.restDay || widget.workoutDay.workout.isEmpty)
              _RestDayCard(day: widget.workoutDay)
            else ...[
              if (widget.workoutDay.warmUp.isNotEmpty)
                _Section(
                  title: 'Warm Up',
                  icon: Icons.directions_run,
                  child: Column(
                    children: widget.workoutDay.warmUp
                        .map(
                          (item) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              item.exerciseName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${item.bodyPart} • ${item.duration}',
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),

              const SizedBox(height: 16),

              _Section(
                title: 'Main Workout',
                icon: Icons.fitness_center,
                child: FutureBuilder<List<ExerciseModel>>(
                  future: _enrichedExercisesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text(
                              'Loading exercise GIFs and details...',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    final exercises =
                        snapshot.data ?? widget.workoutDay.workout;

                    if (exercises.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('No exercises available.'),
                      );
                    }

                    return Column(
                      children: [
                        for (int i = 0; i < exercises.length; i++)
                          _ExerciseCard(exercise: exercises[i], number: i + 1),
                      ],
                    );
                  },
                ),
              ),

              if (widget.workoutDay.stretching.isNotEmpty) ...[
                const SizedBox(height: 16),
                _Section(
                  title: 'Stretching',
                  icon: Icons.self_improvement,
                  child: Column(
                    children: widget.workoutDay.stretching
                        .map(
                          (item) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              item.exerciseName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${item.bodyPart} • ${item.duration}',
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],

              if (widget.workoutDay.coolDown.isNotEmpty) ...[
                const SizedBox(height: 16),
                _Section(
                  title: 'Cool Down',
                  icon: Icons.accessibility_new,
                  child: Column(
                    children: widget.workoutDay.coolDown
                        .map(
                          (item) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              item.exerciseName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(item.duration),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],

              if (widget.workoutDay.dailyTips.isNotEmpty) ...[
                const SizedBox(height: 16),
                _Section(
                  title: 'Daily Tips',
                  icon: Icons.lightbulb_outline,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.workoutDay.dailyTips
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

              if (widget.workoutDay.precautions.isNotEmpty) ...[
                const SizedBox(height: 16),
                _Section(
                  title: 'Precautions',
                  icon: Icons.warning_amber,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.workoutDay.precautions
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
    final instructions = exercise.effectiveInstructions;
    final secondaryMuscles = exercise.effectiveSecondaryMuscles;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================================================
          // SUPABASE / EXERCISEDB GIF
          // ==================================================
          if (exercise.hasGif) _GifViewer(gifUrl: exercise.gifUrl!),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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

                // if (exercise.hasCatalogData) ...[
                //   const SizedBox(height: 8),
                //   Row(
                //     children: [
                //       const Icon(
                //         Icons.verified_outlined,
                //         size: 16,
                //         color: Color(0xFF6D574A),
                //       ),
                //       const SizedBox(width: 5),
                //       const Expanded(
                //         child: Text(
                //           'ExerciseDB catalog matched',
                //           style: TextStyle(
                //             fontSize: 12,
                //             color: Color(0xFF6D574A),
                //             fontWeight: FontWeight.w600,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ],
                const SizedBox(height: 14),

                // Gemini programming data is preserved.
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (exercise.sets.isNotEmpty)
                      _Chip('${exercise.sets} sets'),

                    if (exercise.reps.isNotEmpty)
                      _Chip('${exercise.reps} reps'),

                    if (exercise.duration.isNotEmpty) _Chip(exercise.duration),

                    if (exercise.rest.isNotEmpty)
                      _Chip('Rest ${exercise.rest}'),

                    if (exercise.tempo.isNotEmpty)
                      _Chip('Tempo ${exercise.tempo}'),
                  ],
                ),

                if (exercise.targetMuscles.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const _Label(title: 'Target Muscles'),
                  const SizedBox(height: 6),
                  Text(exercise.targetMuscles.join(', ')),
                ],

                if (secondaryMuscles.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const _Label(title: 'Secondary Muscles'),
                  const SizedBox(height: 6),
                  Text(secondaryMuscles.join(', ')),
                ],

                if (exercise.bodyParts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const _Label(title: 'Body Part'),
                  const SizedBox(height: 6),
                  Text(exercise.bodyParts.join(', ')),
                ],

                if (exercise.equipmentRequired.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const _Label(title: 'Equipment'),
                  const SizedBox(height: 6),
                  Text(exercise.equipmentRequired),
                ],

                // Supabase / ExerciseDB instructions take priority.
                if (instructions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const _Label(title: 'How To Perform'),
                  const SizedBox(height: 8),
                  ...List.generate(
                    instructions.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Text(instructions[index]),
                    ),
                  ),
                ],

                // ALTERNATIVE EXERCISES
                if (exercise.substituteExercises.isNotEmpty) ...[
                  const SizedBox(height: 18),

                  const _Label(title: 'Alternative Exercises'),

                  const SizedBox(height: 8),

                  ...exercise.substituteExercises
                      .take(2)
                      .toList()
                      .asMap()
                      .entries
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDE4DD),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],

                // Gemini trainer guidance is preserved.
                if (exercise.tips.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const _Label(title: 'Trainer Tips'),
                  const SizedBox(height: 8),
                  ...exercise.tips.map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('• $tip'),
                    ),
                  ),
                ],

                if (exercise.precautions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const _Label(title: 'Precautions'),
                  const SizedBox(height: 8),
                  ...exercise.precautions.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('• $item'),
                    ),
                  ),
                ],

                if (exercise.commonMistakes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const _Label(title: 'Common Mistakes'),
                  const SizedBox(height: 8),
                  ...exercise.commonMistakes.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('• $item'),
                    ),
                  ),
                ],

                //   if (exercise.exerciseDbId != null &&
                //       exercise.exerciseDbId!.trim().isNotEmpty) ...[
                //     const SizedBox(height: 16),
                //     Container(
                //       width: double.infinity,
                //       padding: const EdgeInsets.all(12),
                //       decoration: BoxDecoration(
                //         color: const Color(0xFFF4ECE6),
                //         borderRadius: BorderRadius.circular(14),
                //       ),
                //       child: Row(
                //         children: [
                //           const Icon(
                //             Icons.storage_rounded,
                //             size: 17,
                //             color: Color(0xFF6D574A),
                //           ),
                //           const SizedBox(width: 8),
                //           Expanded(
                //             child: Text(
                //               'ExerciseDB ID: ${exercise.exerciseDbId}',
                //               style: const TextStyle(
                //                 fontSize: 12,
                //                 color: Color(0xFF6D574A),
                //                 fontWeight: FontWeight.w600,
                //               ),
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// GIF VIEWER
// ============================================================

class _GifViewer extends StatelessWidget {
  final String gifUrl;

  const _GifViewer({required this.gifUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 260,
      color: Colors.white,
      child: Image.network(
        gifUrl,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon(Icons.broken_image_outlined, size: 45, color: Colors.grey),
                // SizedBox(height: 8),
                Text(
                  'Animated Video Coming Soon ....',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
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
