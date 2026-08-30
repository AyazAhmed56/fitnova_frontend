import 'package:flutter/material.dart';

class WorkoutSettingsScreen extends StatefulWidget {
  const WorkoutSettingsScreen({super.key});

  @override
  State<WorkoutSettingsScreen> createState() => _WorkoutSettingsScreenState();
}

class _WorkoutSettingsScreenState extends State<WorkoutSettingsScreen> {
  bool workoutReminder = true;
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  bool autoStartRestTimer = true;
  bool showExerciseTips = true;
  bool keepScreenOn = true;
  bool darkWorkoutMode = false;

  int countdown = 5;
  int restDuration = 60;

  final List<int> countdownOptions = [3, 5, 10, 15];

  final List<int> restOptions = [30, 45, 60, 90, 120, 180];

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
          "Workout Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: sh * .03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo, Colors.indigo.shade300],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.settings, color: Colors.white, size: 42),

                  const SizedBox(height: 16),

                  Text(
                    "Workout Preferences",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: sw * .060,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Customize your workout experience.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: sw * .040,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                "General",
                style: TextStyle(
                  fontSize: sw * .050,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    value: workoutReminder,
                    onChanged: (value) {
                      setState(() {
                        workoutReminder = value;
                      });
                    },
                    secondary: const Icon(Icons.notifications),
                    title: const Text("Workout Reminder"),
                  ),

                  const Divider(height: 1),

                  SwitchListTile(
                    value: soundEnabled,
                    onChanged: (value) {
                      setState(() {
                        soundEnabled = value;
                      });
                    },
                    secondary: const Icon(Icons.volume_up),
                    title: const Text("Sound"),
                  ),

                  const Divider(height: 1),

                  SwitchListTile(
                    value: vibrationEnabled,
                    onChanged: (value) {
                      setState(() {
                        vibrationEnabled = value;
                      });
                    },
                    secondary: const Icon(Icons.vibration),
                    title: const Text("Vibration"),
                  ),
                  const Divider(height: 1),

                  SwitchListTile(
                    value: autoStartRestTimer,
                    onChanged: (value) {
                      setState(() {
                        autoStartRestTimer = value;
                      });
                    },
                    secondary: const Icon(Icons.timer),
                    title: const Text("Auto Start Rest Timer"),
                  ),

                  const Divider(height: 1),

                  SwitchListTile(
                    value: showExerciseTips,
                    onChanged: (value) {
                      setState(() {
                        showExerciseTips = value;
                      });
                    },
                    secondary: const Icon(Icons.lightbulb_outline),
                    title: const Text("Show Exercise Tips"),
                  ),

                  const Divider(height: 1),

                  SwitchListTile(
                    value: keepScreenOn,
                    onChanged: (value) {
                      setState(() {
                        keepScreenOn = value;
                      });
                    },
                    secondary: const Icon(Icons.screen_lock_portrait),
                    title: const Text("Keep Screen On"),
                  ),

                  const Divider(height: 1),

                  SwitchListTile(
                    value: darkWorkoutMode,
                    onChanged: (value) {
                      setState(() {
                        darkWorkoutMode = value;
                      });
                    },
                    secondary: const Icon(Icons.dark_mode),
                    title: const Text("Dark Workout Mode"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                "Timers",
                style: TextStyle(
                  fontSize: sw * .050,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    value: countdown,
                    decoration: const InputDecoration(
                      labelText: "Countdown Timer",
                      border: OutlineInputBorder(),
                    ),
                    items: countdownOptions
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text("$e Seconds"),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        countdown = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<int>(
                    value: restDuration,
                    decoration: const InputDecoration(
                      labelText: "Default Rest Time",
                      border: OutlineInputBorder(),
                    ),
                    items: restOptions
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text("$e Seconds"),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        restDuration = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: sh * .04),
          ],
        ),
      ),
    );
  }
}
