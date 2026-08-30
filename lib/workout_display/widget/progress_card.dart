import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final int completedExercises;
  final int totalExercises;

  final String elapsedTime;
  final int caloriesBurned;

  const ProgressCard({
    super.key,
    required this.completedExercises,
    required this.totalExercises,
    required this.elapsedTime,
    required this.caloriesBurned,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalExercises == 0
        ? 0.0
        : completedExercises / totalExercises;

    final percentage = (progress * 100).round();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              children: [
                const Icon(Icons.track_changes, size: 28),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    "Workout Progress",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                Text(
                  "$percentage%",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(20),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ProgressTile(
                  icon: Icons.check_circle,
                  title: "Completed",
                  value: completedExercises.toString(),
                  color: Colors.green,
                ),

                _ProgressTile(
                  icon: Icons.pending_actions,
                  title: "Remaining",
                  value: (totalExercises - completedExercises).toString(),
                  color: Colors.orange,
                ),

                _ProgressTile(
                  icon: Icons.fitness_center,
                  title: "Total",
                  value: totalExercises.toString(),
                  color: Colors.blue,
                ),
              ],
            ),

            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.timer, color: Colors.blue),

                        const SizedBox(height: 8),

                        const Text(
                          "Elapsed Time",
                          style: TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          elapsedTime,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: Colors.red,
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "Calories",
                          style: TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          "$caloriesBurned kcal",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (completedExercises == totalExercises) ...[
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    "🎉 Workout Completed!",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProgressTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _ProgressTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color),

        const SizedBox(height: 8),

        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),

        const SizedBox(height: 4),

        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
