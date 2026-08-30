import 'package:flutter/material.dart';
import 'package:fitnova/models/onboarding_data.dart';
import 'package:fitnova/planner_screens/diet/activity.dart';
import 'package:fitnova/diet_display/widgets/selectable_card.dart';

class AthleticPerformanceDetails extends StatefulWidget {
  const AthleticPerformanceDetails({super.key});

  @override
  State<AthleticPerformanceDetails> createState() =>
      _AthleticPerformanceDetailsState();
}

class _AthleticPerformanceDetailsState
    extends State<AthleticPerformanceDetails> {
  final _formKey = GlobalKey<FormState>();

  String selectedSport = "";

  List<String> selectedPerformanceGoals = [];

  String selectedCompetitionLevel = "";

  int selectedWorkoutDays = 0;

  int selectedMonth = 3;

  final List<Map<String, dynamic>> sports = [
    {
      "title": "Football",
      "subtitle": "Speed • Agility • Endurance",
      "icon": Icons.sports_soccer,
    },

    {
      "title": "Cricket",
      "subtitle": "Power • Speed • Stamina",
      "icon": Icons.sports_cricket,
    },

    {
      "title": "Basketball",
      "subtitle": "Jump • Speed • Agility",
      "icon": Icons.sports_basketball,
    },

    {
      "title": "Badminton",
      "subtitle": "Footwork • Reaction",
      "icon": Icons.sports_tennis,
    },

    {
      "title": "Volleyball",
      "subtitle": "Jump • Explosive Power",
      "icon": Icons.sports_volleyball,
    },

    {
      "title": "Tennis",
      "subtitle": "Speed • Endurance",
      "icon": Icons.sports_tennis,
    },

    {"title": "Other", "subtitle": "Custom Sport", "icon": Icons.sports},
  ];

  final List<Map<String, dynamic>> performanceGoals = [
    {"title": "Speed", "subtitle": "Improve acceleration", "icon": Icons.speed},

    {
      "title": "Agility",
      "subtitle": "Quick direction changes",
      "icon": Icons.directions_run,
    },

    {
      "title": "Strength",
      "subtitle": "Increase force output",
      "icon": Icons.fitness_center,
    },

    {"title": "Power", "subtitle": "Explosive movements", "icon": Icons.bolt},

    {
      "title": "Endurance",
      "subtitle": "Long-lasting performance",
      "icon": Icons.favorite,
    },

    {
      "title": "Reaction Time",
      "subtitle": "Faster reflexes",
      "icon": Icons.flash_on,
    },
  ];

  final List<Map<String, dynamic>> competitionLevels = [
    {
      "title": "Beginner",
      "subtitle": "Learning fundamentals",
      "icon": Icons.school,
    },

    {"title": "Amateur", "subtitle": "Regular training", "icon": Icons.sports},

    {
      "title": "Professional",
      "subtitle": "Competitive athlete",
      "icon": Icons.emoji_events,
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
      "subtitle": "Competitive",
      "icon": Icons.looks_5,
    },

    {
      "days": 6,
      "title": "6 Days",
      "subtitle": "Elite Training",
      "icon": Icons.looks_6,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Athletic Performance"),
        centerTitle: true,
      ),

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
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: sw * .16,
                      ),
                    ),

                    SizedBox(height: sh * .02),

                    Center(
                      child: Text(
                        "Athletic Performance",
                        style: TextStyle(
                          fontSize: sw * .075,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: sh * .01),

                    Center(
                      child: Text(
                        "Train like an athlete with sport-specific AI workouts.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: sw * .038,
                        ),
                      ),
                    ),

                    SizedBox(height: sh * .04),

                    Text(
                      "Choose Your Sport",
                      style: TextStyle(
                        fontSize: sw * .045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: sh * .015),

                    Column(
                      children: sports.map((sport) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SelectableCard(
                            title: sport["title"],
                            subtitle: sport["subtitle"],
                            icon: sport["icon"],
                            selected: selectedSport == sport["title"],
                            onTap: () {
                              setState(() {
                                selectedSport = sport["title"];
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: sh * .035),

                    Text(
                      "Performance Goals",
                      style: TextStyle(
                        fontSize: sw * .045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: sh * .015),
                    Column(
                      children: performanceGoals.map((goal) {
                        bool selected = selectedPerformanceGoals.contains(
                          goal["title"],
                        );

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
                                  selectedPerformanceGoals.remove(
                                    goal["title"],
                                  );
                                } else {
                                  selectedPerformanceGoals.add(goal["title"]);
                                }
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: sh * .035),

                    Text(
                      "Competition Level",
                      style: TextStyle(
                        fontSize: sw * .045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: sh * .015),

                    Column(
                      children: competitionLevels.map((level) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),

                          child: SelectableCard(
                            title: level["title"],
                            subtitle: level["subtitle"],
                            icon: level["icon"],
                            selected:
                                selectedCompetitionLevel == level["title"],
                            onTap: () {
                              setState(() {
                                selectedCompetitionLevel = level["title"];
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
                          backgroundColor: Colors.amber.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw * .03),
                          ),
                        ),
                        onPressed: () {
                          if (selectedSport.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select your sport."),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (selectedPerformanceGoals.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please select at least one performance goal.",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (selectedCompetitionLevel.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please select your competition level.",
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

                          data.sportName = selectedSport;

                          data.performanceGoals = selectedPerformanceGoals;

                          data.competitionLevel = selectedCompetitionLevel;

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
