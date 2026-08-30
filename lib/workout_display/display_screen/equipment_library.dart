import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/exercise_model.dart';
import '../models/workout_day_model.dart';
import '../widget/equipment_chip.dart';

class EquipmentLibraryScreen extends StatelessWidget {
  final WorkoutDayModel workoutDay;

  const EquipmentLibraryScreen({super.key, required this.workoutDay});

  List<String> get equipmentList {
    final equipment = <String>{};

    for (ExerciseModel exercise in workoutDay.workout) {
      if (exercise.equipmentRequired.trim().isEmpty) continue;

      final parts = exercise.equipmentRequired.split(",");

      for (final item in parts) {
        equipment.add(item.trim());
      }
    }

    return equipment.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    final equipments = equipmentList;

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
            "Equipment Library",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        body: equipments.isEmpty
            ? const Center(
                child: Text(
                  "No Equipment Required",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              )
            : SingleChildScrollView(
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
                                      Icons.fitness_center,
                                      color: Colors.white,
                                      size: 42,
                                    ),

                                    SizedBox(width: 16),

                                    Text(
                                      workoutDay.dayName,
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
                                  workoutDay.focus,
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
                                        title: "Exercises",
                                        value: workoutDay.workout.length
                                            .toString(),
                                        icon: Icons.sports_gymnastics,
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: _TopCard(
                                        title: "Equipment",
                                        value: equipments.length.toString(),
                                        icon: Icons.handyman,
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
                        "Required Equipment",
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

                    ...workoutDay.workout.map(
                      (exercise) => Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
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
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          exercise.exerciseName,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: sw * .044,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                        
                                        const SizedBox(height: 8),
                        
                                        Text(
                                          exercise.exerciseType,
                                          style: TextStyle(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                      ],
                                    ),
                        
                                    const SizedBox(height: 16),
                        
                                    EquipmentChip(
                                      equipment: exercise.equipmentRequired,
                                    ),
                        
                                    const SizedBox(height: 18),
                        
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _InfoCard(
                                            icon: Icons.repeat,
                                            title: "Sets",
                                            value: exercise.sets,
                                          ),
                                        ),
                        
                                        const SizedBox(width: 10),
                        
                                        Expanded(
                                          child: _InfoCard(
                                            icon: Icons.fitness_center,
                                            title: "Reps",
                                            value: exercise.reps,
                                          ),
                                        ),
                        
                                        const SizedBox(width: 10),
                        
                                        Expanded(
                                          child: _InfoCard(
                                            icon: Icons.timer_outlined,
                                            title: "Rest",
                                            value: exercise.rest,
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
                      ),
                    ),

                    SizedBox(height: 24),

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
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
                              "Arrange all required equipment before starting your workout to avoid interruptions and maintain workout intensity.",
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
              SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.white70)),
            ],
          ),
          SizedBox(height: 4),
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
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            value.isEmpty ? "-" : value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
