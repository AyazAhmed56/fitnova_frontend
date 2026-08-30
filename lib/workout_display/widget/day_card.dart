import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/workout_day_model.dart';

class DayCard extends StatelessWidget {
  final WorkoutDayModel day;

  final bool isCompleted;
  final bool isToday;

  final VoidCallback? onTap;

  const DayCard({
    super.key,
    required this.day,
    this.isCompleted = false,
    this.isToday = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withOpacity(.05), // glass color
              border: Border.all(
                color: Colors.white.withOpacity(.18),
                width: 1.2,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: onTap,
              child: Column(
                children: [
                  /// HEADER
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: isToday
                            ? Theme.of(context).primaryColor.withOpacity(.15)
                            : Colors.grey.shade200,
                        child: Icon(
                          Icons.calendar_today,
                          color: isToday
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              day.dayName,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: sw * .047,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              day.restDay ? day.activity : day.focus,
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),

                      if (isCompleted)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 28,
                        )
                      else
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white54,
                          size: 18,
                        ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Divider(color: Colors.white.withOpacity(.15), thickness: 1),

                  const SizedBox(height: 16),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (day.restDay) ...[
                        _InfoTile(
                          icon: Icons.self_improvement,
                          title: "Activity",
                          value: day.activity,
                        ),

                        _InfoTile(
                          icon: Icons.favorite,
                          title: "Recovery",
                          value: "${day.recoveryTips.length} Tips",
                        ),

                        _InfoTile(
                          icon: Icons.accessibility_new,
                          title: "Stretching",
                          value: "${day.stretching.length}",
                        ),
                      ] else ...[
                        _InfoTile(
                          icon: Icons.schedule,
                          title: "Duration",
                          value: day.estimatedDuration,
                        ),

                        _InfoTile(
                          icon: Icons.bar_chart,
                          title: "Difficulty",
                          value: day.difficulty,
                        ),

                        _InfoTile(
                          icon: Icons.fitness_center,
                          title: "Exercises",
                          value: "${day.workout.length}",
                        ),
                      ],
                    ],
                  ),

                  if (isToday) ...[
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(.15),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          isToday
                              ? day.restDay
                                    ? "Today's Recovery"
                                    : "Today's Workout"
                              : "",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 22, color: const Color.fromARGB(255, 1, 248, 10)),
            
            const SizedBox(width: 10),
            
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),

        const SizedBox(width: 10),

        Text(
          value.trim(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
