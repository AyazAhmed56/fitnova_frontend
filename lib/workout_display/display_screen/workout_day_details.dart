import 'package:flutter/material.dart';
import '../models/exercise_catalog_model.dart';
import 'package:flutter/foundation.dart';
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

  Future<List<ExerciseModel>>? _enrichedExercisesFuture;
  Future<List<_PreparationExercise>>? _warmUpFuture;
  Future<List<_PreparationExercise>>? _stretchingFuture;
  Future<List<_PreparationExercise>>? _coolDownFuture;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  void _loadAllData() {
    _enrichedExercisesFuture = _loadEnrichedExercises();
    _warmUpFuture = _loadWarmUp();
    _stretchingFuture = _loadStretching();
    _coolDownFuture = _loadCoolDown();
  }

  // ============================================================
  // MAIN WORKOUT
  // ============================================================

  Future<List<ExerciseModel>> _loadEnrichedExercises() async {
    final originalExercises = widget.workoutDay.workout;

    if (originalExercises.isEmpty) {
      return [];
    }

    return Future.wait(originalExercises.map(_enrichExercise));
  }

  Future<ExerciseModel> _enrichExercise(ExerciseModel exercise) async {
    try {
      ExerciseCatalogModel? catalog;

      // ============================================================
      // 1. FIRST: EXACT EXERCISEDB ID
      // ============================================================
      if (exercise.exerciseDbId?.trim().isNotEmpty == true) {
        catalog = await _catalogService.findByExerciseDbId(
          exercise.exerciseDbId!.trim(),
        );
      }

      // ============================================================
      // 2. SECOND: EXACT NORMALIZED NAME
      // ============================================================

      if (catalog == null && exercise.exerciseName.trim().isNotEmpty) {
        catalog = await _catalogService.findByName(
          exercise.exerciseName.trim(),
        );
      }

      // ============================================================
      // 3. LAST: SAFE FALLBACK
      // ============================================================

      if (catalog == null && exercise.exerciseName.trim().isNotEmpty) {
        catalog = await _catalogService.findBestMatch(
          exercise.exerciseName.trim(),
        );
      }

      // ============================================================
      // 4. NOTHING FOUND
      // ============================================================

      if (catalog == null) {
        debugPrint(
          'NO CATALOG MATCH: '
          '${exercise.exerciseName} '
          '[${exercise.exerciseDbId}]',
        );

        return exercise;
      }

      debugPrint(
        'CATALOG MATCH: '
        '${exercise.exerciseName} '
        '→ ${catalog.exerciseName} '
        '[${catalog.exerciseDbId}] '
        'GIF=${catalog.gifUrl}',
      );

      return exercise.copyWith(
        // Keep the canonical database identity.
        exerciseName: catalog.exerciseName,
        exerciseDbId: catalog.exerciseDbId,

        // Use catalog GIF.
        gifUrl: catalog.gifUrl,

        bodyParts: catalog.bodyParts,
        targetMuscles: catalog.targetMuscles,
        catalogSecondaryMuscles: catalog.secondaryMuscles,
        catalogInstructions: catalog.instructions,

        equipmentRequired: catalog.equipments.isNotEmpty
            ? catalog.equipments.join(', ')
            : exercise.equipmentRequired,
      );
    } catch (e) {
      debugPrint(
        'EXERCISE ENRICHMENT ERROR '
        '${exercise.exerciseName}: $e',
      );

      return exercise;
    }
  }
  // ============================================================
  // WARM UP
  // ============================================================

  Future<List<_PreparationExercise>> _loadWarmUp() async {
    return Future.wait(
      widget.workoutDay.warmUp.map(
        (item) => _enrichPreparationExercise(
          exerciseId: item.exerciseId,
          exerciseName: item.exerciseName,
          bodyPart: item.bodyPart,
          duration: item.duration,
          instructions: item.instructions,
        ),
      ),
    );
  }

  // ============================================================
  // STRETCHING
  // ============================================================

  Future<List<_PreparationExercise>> _loadStretching() async {
    return Future.wait(
      widget.workoutDay.stretching.map(
        (item) => _enrichPreparationExercise(
          exerciseId: item.exerciseId,
          exerciseName: item.exerciseName,
          bodyPart: item.bodyPart,
          duration: item.duration,
          instructions: item.instructions,
        ),
      ),
    );
  }

  // ============================================================
  // COOL DOWN
  // ============================================================

  Future<List<_PreparationExercise>> _loadCoolDown() async {
    return Future.wait(
      widget.workoutDay.coolDown.map(
        (item) => _enrichPreparationExercise(
          exerciseId: item.exerciseId,
          exerciseName: item.exerciseName,
          bodyPart: '',
          duration: item.duration,
          instructions: item.instructions,
        ),
      ),
    );
  }

  // ============================================================
  // PREPARATION EXERCISE ENRICHMENT
  // ============================================================

  Future<_PreparationExercise> _enrichPreparationExercise({
    required String exerciseId,
    required String exerciseName,
    required String bodyPart,
    required String duration,
    required List<String> instructions,
  }) async {
    String? gifUrl;
    String finalBodyPart = bodyPart;
    List<String> finalInstructions = instructions;

    try {
      // ============================================================
      // 1. FIRST TRY EXERCISE ID
      // ============================================================
      //
      // Gemini already gives us the ExerciseDB ID.
      // This is the most reliable and fastest way to find the GIF.
      //
      if (exerciseId.trim().isNotEmpty) {
        final catalog = await _catalogService
            .findByExerciseDbId(exerciseId.trim())
            .timeout(const Duration(seconds: 8), onTimeout: () => null);

        if (catalog != null) {
          gifUrl = catalog.gifUrl;

          if (finalBodyPart.trim().isEmpty && catalog.bodyParts.isNotEmpty) {
            finalBodyPart = catalog.bodyParts.join(', ');
          }

          if (catalog.instructions.isNotEmpty) {
            finalInstructions = catalog.instructions;
          }

          return _PreparationExercise(
            exerciseId: exerciseId,
            exerciseName: exerciseName,
            bodyPart: finalBodyPart,
            duration: duration,
            instructions: finalInstructions,
            gifUrl: gifUrl,
          );
        }
      }

      // ============================================================
      // 2. FALLBACK TO EXERCISE NAME
      // ============================================================
      //
      // Only use name matching if the ExerciseDB ID was not found.
      //
      if (exerciseName.trim().isNotEmpty) {
        final catalog = await _catalogService
            .findBestMatch(exerciseName.trim())
            .timeout(const Duration(seconds: 8), onTimeout: () => null);

        if (catalog != null) {
          gifUrl = catalog.gifUrl;

          if (finalBodyPart.trim().isEmpty && catalog.bodyParts.isNotEmpty) {
            finalBodyPart = catalog.bodyParts.join(', ');
          }

          if (catalog.instructions.isNotEmpty) {
            finalInstructions = catalog.instructions;
          }

          // Use the catalog ID if Gemini's ID was empty.
          if (exerciseId.trim().isEmpty) {
            exerciseId = catalog.exerciseDbId;
          }
        }
      }
    } catch (_) {
      // Keep Gemini's original information.
    }

    // ============================================================
    // 3. ALWAYS RETURN THE EXERCISE
    // ============================================================

    return _PreparationExercise(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      bodyPart: finalBodyPart,
      duration: duration,
      instructions: finalInstructions,
      gifUrl: gifUrl,
    );
  }
  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refreshCatalogData() async {
    setState(() {
      _loadAllData();
    });

    await Future.wait([
      if (_enrichedExercisesFuture != null) _enrichedExercisesFuture!,
      if (_warmUpFuture != null) _warmUpFuture!,
      if (_stretchingFuture != null) _stretchingFuture!,
      if (_coolDownFuture != null) _coolDownFuture!,
    ]);
  }

  // ============================================================
  // BUILD
  // ============================================================

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
              // ========================================================
              // WARM UP
              // ========================================================
              if (widget.workoutDay.warmUp.isNotEmpty)
                _Section(
                  title: 'Warm Up',
                  icon: Icons.directions_run,
                  child: _warmUpFuture == null
                      ? const Padding(
                          padding: EdgeInsets.all(25),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : FutureBuilder<List<_PreparationExercise>>(
                          future: _warmUpFuture!,
                          builder: (context, snapshot) {
                            return _buildPreparationSection(
                              snapshot: snapshot,
                              emptyMessage: 'No warm-up exercises available.',
                            );
                          },
                        ),
                ),

              const SizedBox(height: 16),

              // ========================================================
              // MAIN WORKOUT
              // ========================================================
              _Section(
                title: 'Main Workout',
                icon: Icons.fitness_center,
                initiallyExpanded: true,
                child: _enrichedExercisesFuture == null
                    ? const Padding(
                        padding: EdgeInsets.all(25),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : FutureBuilder<List<ExerciseModel>>(
                        future: _enrichedExercisesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                              child: Text(
                                'No exercises available.',
                                textAlign: TextAlign.center,
                              ),
                            );
                          }

                          return Column(
                            children: [
                              for (int i = 0; i < exercises.length; i++)
                                _ExerciseCard(
                                  exercise: exercises[i],
                                  number: i + 1,
                                ),
                            ],
                          );
                        },
                      ),
              ),

              // ========================================================
              // STRETCHING
              // ========================================================
              if (widget.workoutDay.stretching.isNotEmpty) ...[
                const SizedBox(height: 16),
                _Section(
                  title: 'Stretching',
                  icon: Icons.self_improvement,
                  child: _stretchingFuture == null
                      ? const Padding(
                          padding: EdgeInsets.all(25),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : FutureBuilder<List<_PreparationExercise>>(
                          future: _stretchingFuture!,
                          builder: (context, snapshot) {
                            return _buildPreparationSection(
                              snapshot: snapshot,
                              emptyMessage:
                                  'No stretching exercises available.',
                            );
                          },
                        ),
                ),
              ],

              // ========================================================
              // COOL DOWN
              // ========================================================
              if (widget.workoutDay.coolDown.isNotEmpty) ...[
                const SizedBox(height: 16),
                _Section(
                  title: 'Cool Down',
                  icon: Icons.accessibility_new,
                  child: _coolDownFuture == null
                      ? const Padding(
                          padding: EdgeInsets.all(25),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : FutureBuilder<List<_PreparationExercise>>(
                          future: _coolDownFuture!,
                          builder: (context, snapshot) {
                            return _buildPreparationSection(
                              snapshot: snapshot,
                              emptyMessage: 'No cool-down exercises available.',
                            );
                          },
                        ),
                ),
              ],

              // ========================================================
              // DAILY TIPS
              // ========================================================
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
                            child: Text(
                              '• $tip',
                              style: const TextStyle(height: 1.35),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],

              // ========================================================
              // PRECAUTIONS
              // ========================================================
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
                            child: Text(
                              '• $item',
                              style: const TextStyle(height: 1.35),
                            ),
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

  // ============================================================
  // PREPARATION SECTION BUILDER
  // ============================================================

  Widget _buildPreparationSection({
    required AsyncSnapshot<List<_PreparationExercise>> snapshot,
    required String emptyMessage,
  }) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 25),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text(
              'Loading exercise GIFs and details...',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (snapshot.hasError) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'Unable to load exercise details.',
          textAlign: TextAlign.center,
        ),
      );
    }

    final exercises = snapshot.data ?? [];

    if (exercises.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(emptyMessage, textAlign: TextAlign.center),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < exercises.length; i++)
          _PreparationExerciseCard(exercise: exercises[i], number: i + 1),
      ],
    );
  }
}

// ============================================================
// PREPARATION EXERCISE DISPLAY MODEL
// ============================================================

class _PreparationExercise {
  final String exerciseId;
  final String exerciseName;
  final String bodyPart;
  final String duration;
  final List<String> instructions;
  final String? gifUrl;

  const _PreparationExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.bodyPart,
    required this.duration,
    required this.instructions,
    required this.gifUrl,
  });

  bool get hasGif => gifUrl != null && gifUrl!.trim().isNotEmpty;
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
// MAIN WORKOUT EXERCISE CARD
// ============================================================

class _ExerciseCard extends StatefulWidget {
  final ExerciseModel exercise;
  final int number;

  const _ExerciseCard({required this.exercise, required this.number});

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    final instructions = exercise.effectiveInstructions;
    final secondaryMuscles = exercise.effectiveSecondaryMuscles;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========================================================
          // LARGE GIF WHEN EXPANDED
          // ========================================================
          if (_isExpanded && exercise.hasGif)
            _GifViewer(gifUrl: exercise.gifUrl!),

          // ========================================================
          // HEADER
          // ========================================================
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  // NUMBER
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE4DD),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      '${widget.number}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6D574A),
                      ),
                    ),
                  ),

                  const SizedBox(width: 9),

                  // SMALL GIF
                  if (!_isExpanded) ...[
                    _SmallGif(gifUrl: exercise.hasGif ? exercise.gifUrl : null),
                    const SizedBox(width: 10),
                  ],

                  // NAME
                  Expanded(
                    child: Text(
                      exercise.exerciseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E3028),
                      ),
                    ),
                  ),

                  const SizedBox(width: 5),

                  // ARROW
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 27,
                      color: Color(0xFF6D574A),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ========================================================
          // EXPANDED DETAILS
          // ========================================================
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: Color(0xFFEDE4DD)),

                  const SizedBox(height: 14),

                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      if (exercise.sets.isNotEmpty)
                        _Chip('${exercise.sets} sets'),

                      if (exercise.reps.isNotEmpty)
                        _Chip('${exercise.reps} reps'),

                      if (exercise.duration.isNotEmpty)
                        _Chip(exercise.duration),

                      if (exercise.rest.isNotEmpty)
                        _Chip('Rest ${exercise.rest}'),

                      if (exercise.tempo.isNotEmpty)
                        _Chip('Tempo ${exercise.tempo}'),
                    ],
                  ),

                  if (exercise.targetMuscles.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const _Label(title: 'Target Muscles'),
                    const SizedBox(height: 6),
                    Text(exercise.targetMuscles.join(', ')),
                  ],

                  if (secondaryMuscles.isNotEmpty) ...[
                    const SizedBox(height: 13),
                    const _Label(title: 'Secondary Muscles'),
                    const SizedBox(height: 6),
                    Text(secondaryMuscles.join(', ')),
                  ],

                  if (exercise.bodyParts.isNotEmpty) ...[
                    const SizedBox(height: 13),
                    const _Label(title: 'Body Part'),
                    const SizedBox(height: 6),
                    Text(exercise.bodyParts.join(', ')),
                  ],

                  if (exercise.equipmentRequired.trim().isNotEmpty) ...[
                    const SizedBox(height: 13),
                    const _Label(title: 'Equipment'),
                    const SizedBox(height: 6),
                    Text(exercise.equipmentRequired),
                  ],

                  if (instructions.isNotEmpty) ...[
                    const SizedBox(height: 17),
                    const _Label(title: 'How To Perform'),
                    const SizedBox(height: 8),

                    ...List.generate(
                      instructions.length,
                      (index) => _InstructionRow(
                        number: index + 1,
                        text: instructions[index],
                      ),
                    ),
                  ],

                  if (exercise.substituteExercises.isNotEmpty) ...[
                    const SizedBox(height: 17),
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
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6D574A),
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

                  if (exercise.tips.isNotEmpty) ...[
                    const SizedBox(height: 17),
                    const _Label(title: 'Trainer Tips'),
                    const SizedBox(height: 8),
                    ...exercise.tips.map(
                      (tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '• $tip',
                          style: const TextStyle(height: 1.35),
                        ),
                      ),
                    ),
                  ],

                  if (exercise.precautions.isNotEmpty) ...[
                    const SizedBox(height: 17),
                    const _Label(title: 'Precautions'),
                    const SizedBox(height: 8),
                    ...exercise.precautions.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '• $item',
                          style: const TextStyle(height: 1.35),
                        ),
                      ),
                    ),
                  ],

                  if (exercise.commonMistakes.isNotEmpty) ...[
                    const SizedBox(height: 17),
                    const _Label(title: 'Common Mistakes'),
                    const SizedBox(height: 8),
                    ...exercise.commonMistakes.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '• $item',
                          style: const TextStyle(height: 1.35),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PREPARATION EXERCISE CARD
//
// Used by:
// - Warm Up
// - Stretching
// - Cool Down
//
// Same visual behavior as main workout:
// - Small GIF when collapsed
// - Large GIF when expanded
// - Exercise name
// - Body part
// - Duration
// - Instructions
// ============================================================

class _PreparationExerciseCard extends StatefulWidget {
  final _PreparationExercise exercise;
  final int number;

  const _PreparationExerciseCard({
    required this.exercise,
    required this.number,
  });

  @override
  State<_PreparationExerciseCard> createState() =>
      _PreparationExerciseCardState();
}

class _PreparationExerciseCardState extends State<_PreparationExerciseCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========================================================
          // LARGE GIF
          // ========================================================
          if (_isExpanded && exercise.hasGif)
            _GifViewer(gifUrl: exercise.gifUrl!),

          // ========================================================
          // HEADER
          // ========================================================
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  // NUMBER
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE4DD),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      '${widget.number}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6D574A),
                      ),
                    ),
                  ),

                  const SizedBox(width: 9),

                  // SMALL GIF
                  if (!_isExpanded) ...[
                    _SmallGif(gifUrl: exercise.hasGif ? exercise.gifUrl : null),
                    const SizedBox(width: 10),
                  ],

                  // NAME
                  Expanded(
                    child: Text(
                      exercise.exerciseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E3028),
                      ),
                    ),
                  ),

                  const SizedBox(width: 5),

                  // ARROW
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 27,
                      color: Color(0xFF6D574A),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ========================================================
          // DETAILS
          // ========================================================
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: Color(0xFFEDE4DD)),

                  const SizedBox(height: 14),

                  // ====================================================
                  // DURATION / BODY PART
                  // ====================================================
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      if (exercise.duration.trim().isNotEmpty)
                        _Chip(exercise.duration),

                      if (exercise.bodyPart.trim().isNotEmpty)
                        _Chip(exercise.bodyPart),
                    ],
                  ),

                  // ====================================================
                  // EXERCISE ID
                  // ====================================================
                  if (exercise.exerciseId.trim().isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const _Label(title: 'Exercise ID'),
                    const SizedBox(height: 5),
                    Text(
                      exercise.exerciseId,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6D574A),
                      ),
                    ),
                  ],

                  // ====================================================
                  // BODY PART
                  // ====================================================
                  if (exercise.bodyPart.trim().isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const _Label(title: 'Body Part'),
                    const SizedBox(height: 6),
                    Text(
                      exercise.bodyPart,
                      style: const TextStyle(height: 1.4),
                    ),
                  ],

                  // ====================================================
                  // DURATION
                  // ====================================================
                  if (exercise.duration.trim().isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const _Label(title: 'Duration'),
                    const SizedBox(height: 6),
                    Text(
                      exercise.duration,
                      style: const TextStyle(height: 1.4),
                    ),
                  ],

                  // ====================================================
                  // INSTRUCTIONS
                  // ====================================================
                  if (exercise.instructions.isNotEmpty) ...[
                    const SizedBox(height: 17),
                    const _Label(title: 'How To Perform'),
                    const SizedBox(height: 8),

                    ...List.generate(
                      exercise.instructions.length,
                      (index) => _InstructionRow(
                        number: index + 1,
                        text: exercise.instructions[index],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// SMALL GIF
class _SmallGif extends StatelessWidget {
  final String? gifUrl;

  const _SmallGif({required this.gifUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3EF),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: gifUrl != null && gifUrl!.trim().isNotEmpty
          ? Image.network(
              gifUrl!,
              fit: BoxFit.contain,
              gaplessPlayback: true,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }

                return const Center(
                  child: SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.fitness_center,
                  size: 23,
                  color: Color(0xFF8C7768),
                );
              },
            )
          : const Icon(
              Icons.fitness_center,
              size: 23,
              color: Color(0xFF8C7768),
            ),
    );
  }
}

// INSTRUCTION ROW
class _InstructionRow extends StatelessWidget {
  final int number;
  final String text;

  const _InstructionRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE4DD),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6D574A),
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }
}

// GIF VIEWER
class _GifViewer extends StatelessWidget {
  final String gifUrl;

  const _GifViewer({required this.gifUrl});

  @override
  Widget build(BuildContext context) {
    final url = gifUrl.trim();

    if (url.isEmpty) {
      return Container(
        width: double.infinity,
        height: 260,
        alignment: Alignment.center,
        child: const Text(
          'GIF not available',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 260,
      color: Colors.white,
      child: Image.network(
        url,
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
            child: Column(children: [Text('Animated Video Coming Soon ....')]),
          );
        },
      ),
    );
  }
}

// REST DAY
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

// SECTION
class _Section extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final bool initiallyExpanded;

  const _Section({
    required this.title,
    required this.icon,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  State<_Section> createState() => _SectionState();
}

class _SectionState extends State<_Section> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: const Color(0xFFEDE4DD),
          highlightColor: const Color(0xFFF4ECE6),
        ),
        child: ExpansionTile(
          initiallyExpanded: widget.initiallyExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE4DD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(widget.icon, color: const Color(0xFF6D574A), size: 22),
          ),
          title: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E3028),
            ),
          ),
          trailing: AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF6D574A),
              size: 28,
            ),
          ),
          children: [
            const Divider(height: 1, color: Color(0xFFEDE4DD)),
            const SizedBox(height: 14),
            widget.child,
          ],
        ),
      ),
    );
  }
}

// CHIP
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

// LABEL
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
