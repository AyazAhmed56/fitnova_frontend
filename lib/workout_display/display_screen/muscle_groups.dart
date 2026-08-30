import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/exercise_catalog_model.dart';
import '../models/exercise_model.dart';
import '../models/workout_day_model.dart';
import '../services/exercise_catalog_service.dart';
import '../widget/muscle_chip.dart';

class MuscleGroupsScreen extends StatefulWidget {
  final WorkoutDayModel workoutDay;

  const MuscleGroupsScreen({super.key, required this.workoutDay});

  @override
  State<MuscleGroupsScreen> createState() => _MuscleGroupsScreenState();
}

class _MuscleGroupsScreenState extends State<MuscleGroupsScreen> {
  final ExerciseCatalogService _catalogService =
      ExerciseCatalogService.instance;

  late Future<List<_ExerciseMuscleData>> _muscleFuture;

  @override
  void initState() {
    super.initState();
    _muscleFuture = _loadMuscles();
  }

  Future<List<_ExerciseMuscleData>> _loadMuscles() async {
    return Future.wait(
      widget.workoutDay.workout.map((exercise) async {
        try {
          final catalog =
              await _catalogService.findBestMatch(exercise.exerciseName);

          return _ExerciseMuscleData(
            geminiExercise: exercise,
            catalog: catalog,
          );
        } catch (_) {
          return _ExerciseMuscleData(
            geminiExercise: exercise,
            catalog: null,
          );
        }
      }),
    );
  }

  void _reload() {
    setState(() {
      _muscleFuture = _loadMuscles();
    });
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
          image: const AssetImage('assets/workout_background.png'),
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
            'Muscle Groups',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh catalog',
            ),
          ],
        ),
        body: FutureBuilder<List<_ExerciseMuscleData>>(
          future: _muscleFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data ?? const <_ExerciseMuscleData>[];

            final primaryMuscles = <String>{};
            final secondaryMuscles = <String>{};

            for (final item in data) {
              final catalog = item.catalog;

              if (catalog != null) {
                primaryMuscles.addAll(
                  catalog.targetMuscles
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty),
                );

                secondaryMuscles.addAll(
                  catalog.secondaryMuscles
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty),
                );
              } else {
                final gemini = item.geminiExercise;

                if (gemini.muscleGroup.trim().isNotEmpty) {
                  primaryMuscles.add(gemini.muscleGroup.trim());
                }

                secondaryMuscles.addAll(gemini.secondaryMuscles);
              }
            }

            final primary = primaryMuscles.toList()..sort();
            final secondary = secondaryMuscles.toList()..sort();

            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: sh * .03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),

                  _HeaderCard(
                    dayName: widget.workoutDay.dayName,
                    focus: widget.workoutDay.focus,
                    exerciseCount: widget.workoutDay.workout.length,
                    primaryCount: primary.length,
                    secondaryCount: secondary.length,
                    sw: sw,
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      'Primary Muscle Groups',
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
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: primary
                          .map((muscle) => MuscleChip(muscle: muscle))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      'Secondary Muscle Groups',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: sw * .050,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (secondary.isEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      child: const Center(
                        child: Text(
                          'No Secondary Muscles',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: secondary
                            .map((muscle) => MuscleChip(muscle: muscle))
                            .toList(),
                      ),
                    ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.analytics_outlined,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Workout Distribution',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: sw * .046,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        ...data.map(
                          (item) => _MuscleDistributionCard(
                            data: item,
                            sw: sw,
                          ),
                        ),

                        SizedBox(height: sh * .04),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ExerciseMuscleData {
  final ExerciseModel geminiExercise;
  final ExerciseCatalogModel? catalog;

  const _ExerciseMuscleData({
    required this.geminiExercise,
    required this.catalog,
  });

  List<String> get primaryMuscles {
    if (catalog?.targetMuscles.isNotEmpty == true) {
      return catalog!.targetMuscles;
    }

    final value = geminiExercise.muscleGroup.trim();
    return value.isEmpty ? const [] : [value];
  }

  List<String> get secondaryMuscles {
    if (catalog?.secondaryMuscles.isNotEmpty == true) {
      return catalog!.secondaryMuscles;
    }

    return geminiExercise.secondaryMuscles;
  }
}

class _HeaderCard extends StatelessWidget {
  final String dayName;
  final String focus;
  final int exerciseCount;
  final int primaryCount;
  final int secondaryCount;
  final double sw;

  const _HeaderCard({
    required this.dayName,
    required this.focus,
    required this.exerciseCount,
    required this.primaryCount,
    required this.secondaryCount,
    required this.sw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(.15),
            Colors.white.withOpacity(.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.15),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.accessibility_new,
                color: Colors.white,
                size: 42,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  dayName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: sw * .060,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            focus,
            style: TextStyle(
              color: Colors.white70,
              fontSize: sw * .040,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _TopCard(
                  icon: Icons.fitness_center,
                  title: 'Exercises',
                  value: '$exerciseCount',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TopCard(
                  icon: Icons.accessibility,
                  title: 'Primary',
                  value: '$primaryCount',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TopCard(
                  icon: Icons.groups,
                  title: 'Secondary',
                  value: '$secondaryCount',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MuscleDistributionCard extends StatelessWidget {
  final _ExerciseMuscleData data;
  final double sw;

  const _MuscleDistributionCard({
    required this.data,
    required this.sw,
  });

  @override
  Widget build(BuildContext context) {
    final exercise = data.geminiExercise;
    final name = data.catalog?.exerciseName ?? exercise.exerciseName;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(.15),
            Colors.white.withOpacity(.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 12),

          if (data.primaryMuscles.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.primaryMuscles
                  .map((muscle) => MuscleChip(muscle: muscle))
                  .toList(),
            ),

          if (data.secondaryMuscles.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.secondaryMuscles
                  .map((muscle) => MuscleChip(muscle: muscle))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _TopCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _TopCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
