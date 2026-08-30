import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import '../models/workout_day_model.dart';
import '../widget/precaution_card.dart';

class WorkoutPrecautionsScreen extends StatelessWidget {
  final WorkoutDayModel workoutDay;

  const WorkoutPrecautionsScreen({super.key, required this.workoutDay});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

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
            "Workout Precautions",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        body: workoutDay.precautions.isEmpty
            ? const Center(
                child: Text(
                  "No Precautions Available",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.only(bottom: sh * .03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    SizedBox(
                      height: 32,
                      child: Marquee(
                        text:
                            "Follow these precautions carefully to avoid injuries and ensure a safe workout session.",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                        scrollAxis: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        blankSpace: 20.0,
                        velocity: 50.0,
                        pauseAfterRound: Duration(seconds: 1),
                        startPadding: 10.0,
                        accelerationDuration: Duration(seconds: 1),
                        accelerationCurve: Curves.linear,
                      ),
                    ),
                    SizedBox(height: 10),

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
                                      Icons.health_and_safety,
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

                                const SizedBox(height: 6),

                                Text(
                                  workoutDay.focus,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: sw * .040,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                Row(
                                  children: [
                                    Expanded(
                                      child: _HeaderCard(
                                        icon: Icons.warning_amber_rounded,
                                        title: "Precautions",
                                        value:
                                            "${workoutDay.precautions.length}",
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: _HeaderCard(
                                        icon: Icons.local_fire_department,
                                        title: "Exercises",
                                        value: "${workoutDay.workout.length}",
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
                        "Safety Guidelines",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw * .050,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    ...List.generate(
                      workoutDay.precautions.length,
                      (index) => PrecautionCard(
                        precaution: workoutDay.precautions[index],
                        index: index,
                      ),
                    ),
                    const SizedBox(height: 18),

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
                              "Always perform each exercise with proper form. Stop immediately if you experience dizziness, sharp pain, or unusual discomfort.",
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

                    const SizedBox(height: 10),

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: Colors.blue,
                              ),

                              const SizedBox(width: 10),

                              Text(
                                "Before Starting",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: sw * .046,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          _SafetyItem(
                            text: "Warm up properly before every workout.",
                          ),

                          _SafetyItem(
                            text: "Drink enough water throughout the session.",
                          ),

                          _SafetyItem(
                            text: "Use appropriate workout shoes and clothing.",
                          ),

                          _SafetyItem(
                            text:
                                "Maintain controlled breathing during every exercise.",
                          ),

                          _SafetyItem(
                            text: "Take the prescribed rest between each set.",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (workoutDay.notes.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, color: Colors.green),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Coach Notes",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    workoutDay.notes,
                                    style: TextStyle(
                                      height: 1.6,
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: sh * .04),
                  ],
                ),
              ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _HeaderCard({
    required this.icon,
    required this.title,
    required this.value,
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
              SizedBox(width: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 6),
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

class _SafetyItem extends StatelessWidget {
  final String text;

  const _SafetyItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,
              style: TextStyle(height: 1.6, fontSize: 14, color: Colors.grey.shade200),
            ),
          ),
        ],
      ),
    );
  }
}
