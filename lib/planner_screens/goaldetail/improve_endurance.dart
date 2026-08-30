import 'package:fitnova/diet_display/widgets/selectable_card.dart';
import 'package:flutter/material.dart';
import 'package:fitnova/models/onboarding_data.dart';
import 'package:fitnova/planner_screens/diet/activity.dart';

class ImproveEnduranceDetails extends StatefulWidget {
  const ImproveEnduranceDetails({super.key});

  @override
  State<ImproveEnduranceDetails> createState() =>
      _ImproveEnduranceDetailsState();
}

class _ImproveEnduranceDetailsState extends State<ImproveEnduranceDetails> {
  final _formKey = GlobalKey<FormState>();

  String selectedEnduranceGoal = "";
  String selectedCardio = "";

  int selectedWorkoutDays = 0;
  int selectedMonth = 3;

  final List<Map<String, dynamic>> enduranceGoals = [
    {
      "title": "Run 5 km",
      "subtitle": "Improve basic running endurance",
      "icon": Icons.directions_run,
    },

    {
      "title": "Run 10 km",
      "subtitle": "Intermediate cardio training",
      "icon": Icons.directions_run,
    },

    {
      "title": "Half Marathon",
      "subtitle": "21.1 km endurance challenge",
      "icon": Icons.emoji_events,
    },

    {
      "title": "Marathon",
      "subtitle": "42.2 km elite endurance",
      "icon": Icons.workspace_premium,
    },

    {
      "title": "Improve Daily Stamina",
      "subtitle": "Increase everyday energy",
      "icon": Icons.favorite,
    },
  ];

  final List<Map<String, dynamic>> cardioOptions = [
    {
      "title": "Running",
      "subtitle": "Best overall endurance",
      "icon": Icons.directions_run,
    },

    {
      "title": "Cycling",
      "subtitle": "Low impact cardio",
      "icon": Icons.pedal_bike,
    },

    {
      "title": "Swimming",
      "subtitle": "Full body endurance",
      "icon": Icons.pool,
    },

    {
      "title": "Jump Rope",
      "subtitle": "HIIT cardio training",
      "icon": Icons.sports_gymnastics,
    },

    {"title": "Rowing", "subtitle": "Strength + Cardio", "icon": Icons.rowing},
  ];

  @override
  Widget build(BuildContext context) {
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
        "subtitle": "Intermediate",
        "icon": Icons.looks_5,
      },
      {
        "days": 6,
        "title": "6 Days",
        "subtitle": "Advanced",
        "icon": Icons.looks_6,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Improve Endurance"), centerTitle: true),

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
                        Icons.favorite,
                        color: Colors.red,
                        size: sw * .16,
                      ),
                    ),

                    SizedBox(height: sh * .02),

                    Center(
                      child: Text(
                        "Improve Endurance",

                        style: TextStyle(
                          fontSize: sw * .075,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: sh * .01),

                    Center(
                      child: Text(
                        "Build stamina, improve cardio and increase your endurance performance.",

                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: sw * .038,
                        ),
                      ),
                    ),

                    SizedBox(height: sh * .04),

                    Text(
                      "Endurance Goal",

                      style: TextStyle(
                        fontSize: sw * .045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: sh * .015),

                    Column(
                      children: enduranceGoals.map((goal) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),

                          child: SelectableCard(
                            title: goal["title"],

                            subtitle: goal["subtitle"],

                            icon: goal["icon"],

                            selected: selectedEnduranceGoal == goal["title"],

                            onTap: () {
                              setState(() {
                                selectedEnduranceGoal = goal["title"];
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: sh * .035),

                    Text(
                      "Preferred Cardio",

                      style: TextStyle(
                        fontSize: sw * .045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: sh * .015),
                    Column(
                      children: cardioOptions.map((cardio) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SelectableCard(
                            title: cardio["title"],
                            subtitle: cardio["subtitle"],
                            icon: cardio["icon"],
                            selected: selectedCardio == cardio["title"],
                            onTap: () {
                              setState(() {
                                selectedCardio = cardio["title"];
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
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw * .03),
                          ),
                        ),
                        onPressed: () {
                          if (selectedEnduranceGoal.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please select an endurance goal.",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (selectedCardio.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please select your preferred cardio activity.",
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

                          data.enduranceGoal = selectedEnduranceGoal;

                          data.cardioPreference = selectedCardio;

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
                            fontWeight: FontWeight.bold,
                            fontSize: sw * .045,
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
