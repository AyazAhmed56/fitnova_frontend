import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/exercise_catalog_model.dart';
import '../models/exercise_model.dart';
import '../models/workout_day_model.dart';
import '../services/exercise_catalog_service.dart';
import '../widget/equipment_chip.dart';

class EquipmentLibraryScreen extends StatefulWidget {
  final WorkoutDayModel workoutDay;

  const EquipmentLibraryScreen({super.key, required this.workoutDay});

  @override
  State<EquipmentLibraryScreen> createState() => _EquipmentLibraryScreenState();
}

class _EquipmentLibraryScreenState extends State<EquipmentLibraryScreen> {
  final ExerciseCatalogService _catalogService =
      ExerciseCatalogService.instance;

  late Future<List<_ExerciseEquipmentData>> _equipmentFuture;

  @override
  void initState() {
    super.initState();
    _equipmentFuture = _loadEquipment();
  }

  Future<List<_ExerciseEquipmentData>> _loadEquipment() async {
    return Future.wait(
      widget.workoutDay.workout.map((exercise) async {
        try {
          final catalog =
              await _catalogService.findBestMatch(exercise.exerciseName);

          return _ExerciseEquipmentData(
            geminiExercise: exercise,
            catalog: catalog,
          );
        } catch (_) {
          return _ExerciseEquipmentData(
            geminiExercise: exercise,
            catalog: null,
          );
        }
      }),
    );
  }

  List<String> _equipmentList(List<_ExerciseEquipmentData> data) {
    final equipment = <String>{};

    for (final item in data) {
      final catalogEquipment = item.catalog?.equipments ?? const <String>[];

      if (catalogEquipment.isNotEmpty) {
        equipment.addAll(
          catalogEquipment
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty),
        );
        continue;
      }

      final geminiEquipment = item.geminiExercise.equipmentRequired.trim();

      if (geminiEquipment.isEmpty) continue;

      equipment.addAll(
        geminiEquipment
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty),
      );
    }

    return equipment.toList()..sort();
  }

  void _reload() {
    setState(() {
      _equipmentFuture = _loadEquipment();
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
            'Equipment Library',
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
        body: FutureBuilder<List<_ExerciseEquipmentData>>(
          future: _equipmentFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data ?? const <_ExerciseEquipmentData>[];
            final equipments = _equipmentList(data);

            if (equipments.isEmpty) {
              return const Center(
                child: Text(
                  'No Equipment Required',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }

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
                    equipmentCount: equipments.length,
                    sw: sw,
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      'Required Equipment',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: sw * .050,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: equipments
                          .map(
                            (equipment) =>
                                EquipmentChip(equipment: equipment),
                          )
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      "Equipment Used in Today's Workout",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: sw * .050,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...data.map(
                    (item) => _ExerciseEquipmentCard(
                      data: item,
                      sw: sw,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.tips_and_updates,
                          color: Colors.orange,
                          size: 34,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Arrange all required equipment before starting your workout to avoid interruptions and maintain workout intensity.',
                            style: TextStyle(
                              color: Colors.white,
                              height: 1.6,
                              fontSize: sw * .039,
                            ),
                          ),
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
    );
  }
}

class _ExerciseEquipmentData {
  final ExerciseModel geminiExercise;
  final ExerciseCatalogModel? catalog;

  const _ExerciseEquipmentData({
    required this.geminiExercise,
    required this.catalog,
  });

  String get equipment {
    final catalogEquipment = catalog?.equipments ?? const <String>[];

    if (catalogEquipment.isNotEmpty) {
      return catalogEquipment.join(', ');
    }

    return geminiExercise.equipmentRequired;
  }
}

class _HeaderCard extends StatelessWidget {
  final String dayName;
  final String focus;
  final int exerciseCount;
  final int equipmentCount;
  final double sw;

  const _HeaderCard({
    required this.dayName,
    required this.focus,
    required this.exerciseCount,
    required this.equipmentCount,
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
                Icons.fitness_center,
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
          const SizedBox(height: 8),
          Text(
            focus,
            style: TextStyle(
              color: Colors.white70,
              fontSize: sw * .040,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _TopCard(
                  title: 'Exercises',
                  value: exerciseCount.toString(),
                  icon: Icons.sports_gymnastics,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TopCard(
                  title: 'Equipment',
                  value: equipmentCount.toString(),
                  icon: Icons.handyman,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExerciseEquipmentCard extends StatelessWidget {
  final _ExerciseEquipmentData data;
  final double sw;

  const _ExerciseEquipmentCard({
    required this.data,
    required this.sw,
  });

  @override
  Widget build(BuildContext context) {
    final exercise = data.geminiExercise;
    final catalog = data.catalog;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Container(
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              catalog?.exerciseName ?? exercise.exerciseName,
              style: TextStyle(
                color: Colors.white,
                fontSize: sw * .044,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              exercise.exerciseType,
              style: TextStyle(color: Colors.grey.shade200),
            ),
            const SizedBox(height: 16),
            EquipmentChip(
              equipment: data.equipment.isEmpty ? 'No equipment' : data.equipment,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.repeat,
                    title: 'Sets',
                    value: exercise.sets,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.fitness_center,
                    title: 'Reps',
                    value: exercise.reps,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.timer_outlined,
                    title: 'Rest',
                    value: exercise.rest,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TopCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _TopCard({
    required this.title,
    required this.value,
    required this.icon,
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
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value.isEmpty ? '-' : value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
