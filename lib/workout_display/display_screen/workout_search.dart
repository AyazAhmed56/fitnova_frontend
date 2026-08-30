import 'package:fitnova/workout_display/display_screen/exercise_details.dart';
import 'package:flutter/material.dart';

import '../models/exercise_catalog_model.dart';
import '../models/exercise_model.dart';
import '../models/workout_day_model.dart';
import '../models/workout_plan_model.dart';
import '../services/exercise_catalog_service.dart';
import '../services/workout_repository.dart';

class WorkoutSearchScreen extends StatefulWidget {
  const WorkoutSearchScreen({super.key});

  @override
  State<WorkoutSearchScreen> createState() => _WorkoutSearchScreenState();
}

class _WorkoutSearchScreenState extends State<WorkoutSearchScreen> {
  final WorkoutRepository _repository = WorkoutRepository.instance;
  final ExerciseCatalogService _catalogService =
      ExerciseCatalogService.instance;

  final Map<String, Future<ExerciseCatalogModel?>> _catalogLookups = {};

  final TextEditingController _searchController = TextEditingController();

  Future<ExerciseCatalogModel?> _catalogFor(String exerciseName) {
    final key = ExerciseCatalogService.normalizeExerciseName(exerciseName);

    return _catalogLookups.putIfAbsent(
      key,
      () => _catalogService.findBestMatch(exerciseName),
    );
  }

  late Future<WorkoutPlanModel?> _future;

  String _query = "";

  @override
  void initState() {
    super.initState();
    _future = _repository.getWorkoutPlan();
  }

  List<ExerciseModel> _searchExercises(WorkoutPlanModel plan) {
    final List<ExerciseModel> results = [];

    for (WorkoutDayModel day in plan.allDays) {
      for (ExerciseModel exercise in day.workout) {
        if (_query.isEmpty) {
          results.add(exercise);
          continue;
        }

        if (exercise.exerciseName.toLowerCase().contains(
              _query.toLowerCase(),
            ) ||
            exercise.exerciseType.toLowerCase().contains(
              _query.toLowerCase(),
            ) ||
            exercise.muscleGroup.toLowerCase().contains(_query.toLowerCase()) ||
            exercise.equipmentRequired.toLowerCase().contains(
              _query.toLowerCase(),
            )) {
          results.add(exercise);
        }
      }
    }

    return results;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          "Workout Search",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: FutureBuilder<WorkoutPlanModel?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Workout Plan Not Found"));
          }

          final plan = snapshot.data!;
          final exercises = _searchExercises(plan);

          return Column(
            children: [
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _query = value.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search exercises, muscles, equipment...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();

                              setState(() {
                                _query = "";
                              });
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "${exercises.length}",
                            style: TextStyle(
                              fontSize: sw * .060,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text("Results"),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "${plan.totalDays}",
                            style: TextStyle(
                              fontSize: sw * .060,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text("Workout Days"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: exercises.isEmpty
                    ? const Center(
                        child: Text(
                          "No Exercises Found",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: sh * .03),
                        itemCount: exercises.length,
                        itemBuilder: (context, index) {
                          final exercise = exercises[index];

                          return _WorkoutSearchExerciseCard(
                            exercise: exercise,
                            catalogFuture: _catalogFor(exercise.exerciseName),
                            onTap: (catalog) {
                              if (catalog == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Exercise details are not available in the catalog.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ExerciseDetailsScreen(
                                    exercise: catalog,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),

              if (_query.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          "Showing ${exercises.length} result${exercises.length == 1 ? '' : 's'} for \"$_query\"",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.fitness_center,
                        title: "Exercises",
                        value:
                            "${plan.allDays.fold<int>(0, (sum, day) => sum + day.workout.length)}",
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_fire_department,
                        title: "Warm Ups",
                        value:
                            "${plan.allDays.fold<int>(0, (sum, day) => sum + day.warmUp.length)}",
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _StatCard(
                        icon: Icons.self_improvement,
                        title: "Cool Downs",
                        value:
                            "${plan.allDays.fold<int>(0, (sum, day) => sum + day.coolDown.length)}",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 28),

          const SizedBox(height: 10),

          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// CATALOG-AWARE SEARCH RESULT
// ============================================================

class _WorkoutSearchExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final Future<ExerciseCatalogModel?> catalogFuture;
  final ValueChanged<ExerciseCatalogModel?> onTap;

  const _WorkoutSearchExerciseCard({
    required this.exercise,
    required this.catalogFuture,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ExerciseCatalogModel?>(
      future: catalogFuture,
      builder: (context, snapshot) {
        final catalog = snapshot.data;

        return Card(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onTap(catalog),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (snapshot.connectionState == ConnectionState.waiting)
                  Container(
                    width: double.infinity,
                    height: 190,
                    color: Colors.white,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (catalog?.gifUrl != null &&
                    catalog!.gifUrl!.trim().isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    height: 190,
                    child: Image.network(
                      catalog.gifUrl!,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 45,
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 110,
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: Icon(
                        Icons.fitness_center,
                        size: 42,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        catalog?.exerciseName ?? exercise.exerciseName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (catalog != null) ...[
                        const SizedBox(height: 10),

                        if (catalog.targetMuscles.isNotEmpty)
                          _SearchInfoRow(
                            icon: Icons.fitness_center,
                            text: catalog.targetMuscles.join(', '),
                          ),

                        if (catalog.equipments.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          _SearchInfoRow(
                            icon: Icons.sports_gymnastics,
                            text: catalog.equipments.join(', '),
                          ),
                        ],
                      ],

                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (exercise.sets.isNotEmpty)
                            _SearchChip('${exercise.sets} sets'),
                          if (exercise.reps.isNotEmpty)
                            _SearchChip('${exercise.reps} reps'),
                          if (exercise.rest.isNotEmpty)
                            _SearchChip('Rest ${exercise.rest}'),
                        ],
                      ),

                      const SizedBox(height: 12),

                      const Row(
                        children: [
                          Text(
                            'View Exercise Details',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 13,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SearchInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SearchInfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).primaryColor),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SearchChip extends StatelessWidget {
  final String text;

  const _SearchChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE4DD),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
