import 'package:flutter/material.dart';
import 'package:fitnova/models/onboarding_data.dart';
import 'package:fitnova/planner_screens/diet/activity.dart';
import 'package:fitnova/diet_display/widgets/selectable_card.dart';

class StrengthPowerDetails extends StatefulWidget {
  const StrengthPowerDetails({super.key});

  @override
  State<StrengthPowerDetails> createState() => _StrengthPowerDetailsState();
}

class _StrengthPowerDetailsState extends State<StrengthPowerDetails> {
  final _formKey = GlobalKey<FormState>();

  String selectedStrengthGoal = "";
  String selectedLift = "";
  String selectedRepRange = "";

  int selectedWorkoutDays = 0;
  int selectedMonth = 3;

  final List<Map<String, dynamic>> strengthGoals = [
    {
      "title": "General Strength",
      "subtitle": "Increase full-body strength",
      "icon": Icons.fitness_center,
    },
    {
      "title": "Powerlifting",
      "subtitle": "Squat • Bench • Deadlift",
      "icon": Icons.sports_gymnastics,
    },
    {
      "title": "Olympic Weightlifting",
      "subtitle": "Snatch • Clean & Jerk",
      "icon": Icons.emoji_events,
    },
    {
      "title": "Functional Strength",
      "subtitle": "Daily life & athletics",
      "icon": Icons.bolt,
    },
  ];

  final List<Map<String, dynamic>> primaryLifts = [
    {
      "title": "Bench Press",
      "subtitle": "Upper body strength",
      "icon": Icons.fitness_center,
    },
    {
      "title": "Squat",
      "subtitle": "Lower body strength",
      "icon": Icons.accessibility_new,
    },
    {
      "title": "Deadlift",
      "subtitle": "Posterior chain",
      "icon": Icons.arrow_upward,
    },
    {
      "title": "Overhead Press",
      "subtitle": "Shoulders & Triceps",
      "icon": Icons.pan_tool,
    },
    {"title": "Pull-ups", "subtitle": "Back & Grip", "icon": Icons.sports},
  ];

  final List<Map<String, dynamic>> repRanges = [
    {
      "title": "1-5 Reps",
      "subtitle": "Maximum Strength",
      "icon": Icons.looks_one,
    },
    {
      "title": "6-8 Reps",
      "subtitle": "Strength + Size",
      "icon": Icons.looks_two,
    },
    {
      "title": "8-12 Reps",
      "subtitle": "Muscle Hypertrophy",
      "icon": Icons.looks_3,
    },
  ];

  final List<Map<String, dynamic>> workoutOptions = [
    {
      "days": 3,
      "title": "3 Days",
      "subtitle": "Beginner",
      "icon": Icons.looks_3,
    },
    {
      "days": 4,
      "title": "4 Days",
      "subtitle": "Balanced",
      "icon": Icons.looks_4,
    },
    {
      "days": 5,
      "title": "5 Days",
      "subtitle": "Serious Training",
      "icon": Icons.looks_5,
    },
    {
      "days": 6,
      "title": "6 Days",
      "subtitle": "Advanced",
      "icon": Icons.looks_6,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Strength & Power"), centerTitle: true),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sw = constraints.maxWidth;
            final sh = constraints.maxHeight;

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(sw * .05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Icon(
                        Icons.fitness_center,
                        color: const Color(0xFF3A6F4B),
                        size: sw * .16,
                      ),
                    ),

                    SizedBox(height: sh * .02),

                    Center(
                      child: Text(
                        "Strength & Power",
                        style: TextStyle(
                          fontSize: sw * .075,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: sh * .01),

                    Center(
                      child: Text(
                        "Let's build your personalized strength program.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: sw * .038,
                        ),
                      ),
                    ),

                    SizedBox(height: sh * .04),

                    Text(
                      "Primary Training Style",
                      style: TextStyle(
                        fontSize: sw * .045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: sh * .015),

                    Column(
                      children: strengthGoals.map((goal) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SelectableCard(
                            title: goal["title"],
                            subtitle: goal["subtitle"],
                            icon: goal["icon"],
                            selected: selectedStrengthGoal == goal["title"],
                            onTap: () {
                              setState(() {
                                selectedStrengthGoal = goal["title"];
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: sh * .035),

                    Text(
                      "Primary Lift Focus",
                      style: TextStyle(
                        fontSize: sw * .045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: sh * .015),

                    Column(
                      children: primaryLifts.map((lift) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SelectableCard(
                            title: lift["title"],
                            subtitle: lift["subtitle"],
                            icon: lift["icon"],
                            selected: selectedLift == lift["title"],
                            onTap: () {
                              setState(() {
                                selectedLift = lift["title"];
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: sh * .035),
                    Text(
                      "Preferred Rep Range",
                      style: TextStyle(
                        fontSize: sw * .045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: sh * .015),

                    Column(
                      children: repRanges.map((rep) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SelectableCard(
                            title: rep["title"],
                            subtitle: rep["subtitle"],
                            icon: rep["icon"],
                            selected: selectedRepRange == rep["title"],
                            onTap: () {
                              setState(() {
                                selectedRepRange = rep["title"];
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: sh * .035),

                    Text(
                      "Workout Days Per Week",
                      style: TextStyle(
                        fontSize: sw * .045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: sh * .015),

                    Column(
                      children: workoutOptions.map((day) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SelectableCard(
                            title: day["title"],
                            subtitle: day["subtitle"],
                            icon: day["icon"],
                            selected: selectedWorkoutDays == day["days"],
                            onTap: () {
                              setState(() {
                                selectedWorkoutDays = day["days"];
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: sh * .035),

                    Text(
                      "Training Duration",
                      style: TextStyle(
                        fontSize: sw * .045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: sh * .015),

                    DropdownButtonFormField<int>(
                      value: selectedMonth,

                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(sw * .03),
                        ),

                        contentPadding: EdgeInsets.symmetric(
                          horizontal: sw * .04,
                          vertical: sh * .018,
                        ),
                      ),

                      items: List.generate(
                        12,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text(
                            "${index + 1} Month${index == 0 ? "" : "s"}",
                          ),
                        ),
                      ),

                      onChanged: (value) {
                        setState(() {
                          selectedMonth = value!;
                        });
                      },
                    ),

                    SizedBox(height: sh * .05),
                    SizedBox(
                      width: double.infinity,
                      height: sh * .065,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A6F4B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw * .03),
                          ),
                        ),
                        onPressed: () {
                          if (selectedStrengthGoal.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please select a training style.",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (selectedLift.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please select your primary lift.",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (selectedRepRange.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please select your preferred rep range.",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (selectedWorkoutDays == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select workout days."),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final data = OnboardingData.instance;

                          data.strengthGoal = selectedStrengthGoal;

                          data.primaryLift = selectedLift;

                          data.repRange = selectedRepRange;

                          data.workoutDays = selectedWorkoutDays;

                          data.durationMonths = selectedMonth.toDouble();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ActivityLevel(),
                            ),
                          );
                        },
                        child: Text(
                          "Next",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: sw * .045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: sh * .02),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
