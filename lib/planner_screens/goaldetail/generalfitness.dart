import 'package:flutter/material.dart';
import 'package:fitnova/models/onboarding_data.dart';
import 'package:fitnova/planner_screens/diet/activity.dart';
import 'package:fitnova/diet_display/widgets/selectable_card.dart';

class GeneralFitnessDetails extends StatefulWidget {
  const GeneralFitnessDetails({super.key});

  @override
  State<GeneralFitnessDetails> createState() => _GeneralFitnessDetailsState();
}

class _GeneralFitnessDetailsState extends State<GeneralFitnessDetails> {
  final _formKey = GlobalKey<FormState>();

  List<String> selectedGoals = [];

  String selectedWorkoutPlace = "";

  int selectedWorkoutDays = 0;

  int selectedMonth = 3;

  final List<Map<String, dynamic>> fitnessGoals = [
    {
      "title": "Stay Active",
      "subtitle": "Maintain an active lifestyle",
      "icon": Icons.directions_walk,
    },

    {
      "title": "Improve Health",
      "subtitle": "Boost overall wellness",
      "icon": Icons.favorite,
    },

    {
      "title": "Better Mobility",
      "subtitle": "Improve flexibility & movement",
      "icon": Icons.accessibility_new,
    },

    {
      "title": "Better Flexibility",
      "subtitle": "Increase body flexibility",
      "icon": Icons.self_improvement,
    },

    {
      "title": "Better Energy",
      "subtitle": "Feel energetic every day",
      "icon": Icons.bolt,
    },

    {
      "title": "Stress Relief",
      "subtitle": "Relax body & mind",
      "icon": Icons.spa,
    },
  ];

  final List<Map<String, dynamic>> workoutPlaces = [
    {"title": "Home", "subtitle": "Workout from home", "icon": Icons.home},

    {
      "title": "Gym",
      "subtitle": "Access to equipment",
      "icon": Icons.fitness_center,
    },

    {"title": "Mixed", "subtitle": "Home + Gym", "icon": Icons.swap_horiz},
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("General Fitness"), centerTitle: true),

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
                        Icons.self_improvement,
                        color: Colors.green,
                        size: sw * .16,
                      ),
                    ),

                    SizedBox(height: sh * .02),

                    Center(
                      child: Text(
                        "General Fitness",
                        style: TextStyle(
                          fontSize: sw * .075,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: sh * .01),

                    Center(
                      child: Text(
                        "Select your fitness goals and let AI create a balanced workout plan.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: sw * .038,
                        ),
                      ),
                    ),

                    SizedBox(height: sh * .04),

                    Text(
                      "What do you want to achieve?",
                      style: TextStyle(
                        fontSize: sw * .045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: sh * .015),

                    Column(
                      children: fitnessGoals.map((goal) {
                        bool selected = selectedGoals.contains(goal["title"]);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),

                          child: SelectableCard(
                            title: goal["title"],

                            subtitle: goal["subtitle"],

                            icon: goal["icon"],

                            selected: selected,

                            onTap: () {
                              setState(() {
                                if (selected) {
                                  selectedGoals.remove(goal["title"]);
                                } else {
                                  selectedGoals.add(goal["title"]);
                                }
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: sh * .035),

                    Text(
                      "Preferred Workout Location",

                      style: TextStyle(
                        fontSize: sw * .045,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: sh * .015),

                    Column(
                      children: workoutPlaces.map((place) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),

                          child: SelectableCard(
                            title: place["title"],

                            subtitle: place["subtitle"],

                            icon: place["icon"],

                            selected: selectedWorkoutPlace == place["title"],

                            onTap: () {
                              setState(() {
                                selectedWorkoutPlace = place["title"];
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
                          if (selectedGoals.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please select at least one fitness goal.",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (selectedWorkoutPlace.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please select your preferred workout location.",
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

                          data.fitnessGoals = selectedGoals;

                          data.workoutPlace = selectedWorkoutPlace;

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
