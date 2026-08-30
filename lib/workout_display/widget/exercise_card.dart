import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/exercise_model.dart';
import 'equipment_chip.dart';
import 'muscle_chip.dart';

class ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final VoidCallback? onTap;

  const ExerciseCard({super.key, required this.exercise, this.onTap});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Container(
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
            child: InkWell(
              onTap: onTap,
              child: Card(
                color: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey,
                          child: Text(
                            exercise.exerciseOrder,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.exerciseName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: sw * .045,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                exercise.exerciseType,
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: exercise.isCompound
                                ? const Color.fromARGB(
                                    255,
                                    2,
                                    248,
                                    10,
                                  ).withOpacity(.15)
                                : Colors.orange.withOpacity(.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            exercise.isCompound ? "Compound" : "Isolation",
                            style: TextStyle(
                              color: exercise.isCompound
                                  ? const Color.fromARGB(255, 1, 247, 9)
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    MuscleChip(muscle: exercise.muscleGroup),
                    const SizedBox(height: 10),
                    EquipmentChip(equipment: exercise.equipmentRequired),

                    const SizedBox(height: 18),

                    Divider(),

                    const SizedBox(height: 10),

                    /// Workout Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatTile(
                          icon: Icons.fitness_center,
                          title: "Sets",
                          value: exercise.sets,
                        ),

                        _StatTile(
                          icon: Icons.repeat,
                          title: "Reps",
                          value: exercise.reps,
                        ),

                        _StatTile(
                          icon: Icons.timer_outlined,
                          title: "Rest",
                          value: exercise.rest,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    /// Difficulty
                    Row(
                      children: [
                        const Icon(
                          Icons.bar_chart,
                          size: 18,
                          color: Colors.white,
                        ),

                        const SizedBox(width: 8),

                        Text(
                          "Difficulty",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),

                        const Spacer(),

                        Text(
                          exercise.difficulty,
                          style: TextStyle(
                            color: const Color.fromARGB(255, 2, 247, 10),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.visibility_outlined),
                        label: const Text("View Details"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white),

            const SizedBox(width: 4),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        Text(
          value.isEmpty ? "-" : value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
