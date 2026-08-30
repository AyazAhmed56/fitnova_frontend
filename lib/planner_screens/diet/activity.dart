import 'package:fitnova/models/onboarding_data.dart';
import 'package:fitnova/planner_screens/diet/dietprefer.dart';
import 'package:flutter/material.dart';

class ActivityLevel extends StatefulWidget {
  const ActivityLevel({super.key});

  @override
  State<ActivityLevel> createState() => _ActivityLevelState();
}

class _ActivityLevelState extends State<ActivityLevel> {
  String selectedGoal = '';

  final List<Map<String, dynamic>> goals = [
    {
      'title': 'Sedentary',
      'text': 'Little or no exercise',
      'icon': Icons.chair_alt,
    },
    {
      'title': 'Lightly Active',
      'text': '1-3 days per week',
      'icon': Icons.directions_walk,
    },
    {
      'title': 'Moderately Active',
      'text': '3-5 days per week',
      'icon': Icons.hiking,
    },
    {
      'title': 'Very Active',
      'text': '6-7 days per week',
      'icon': Icons.directions_run,
    },
    {
      'title': 'Extra Active',
      'text': 'Very intense exercise',
      'icon': Icons.fitness_center,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Information Details'),
        centerTitle: true,
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sw = constraints.maxWidth;
            final sh = constraints.maxHeight;

            return Padding(
              padding: EdgeInsets.all(sw * 0.05),

              child: Column(
                children: [
                  Text(
                    'Activity Level',
                    style: TextStyle(
                      fontSize: sw * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: sh * 0.01),

                  Text(
                    'How active are you?',
                    style: TextStyle(
                      fontSize: sw * 0.04,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  SizedBox(height: sh * 0.03),

                  Expanded(
                    child: ListView.builder(
                      itemCount: goals.length,

                      itemBuilder: (context, index) {
                        final goal = goals[index];

                        return InkWell(
                          borderRadius: BorderRadius.circular(sw * 0.035),
                          onTap: () {
                            setState(() {
                              selectedGoal = goal["title"];
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: sh * 0.015),

                            padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.04,
                              vertical: sh * 0.018,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.white,

                              borderRadius: BorderRadius.circular(sw * 0.035),

                              border: Border.all(
                                color: selectedGoal == goal['title']
                                    ? const Color(0xFF3A6F4B)
                                    : Colors.grey.shade300,
                                width: 1.3,
                              ),
                            ),

                            child: Row(
                              children: [
                                Icon(
                                  goal['icon'],
                                  size: sw * 0.07,
                                  color: Colors.green.shade600,
                                ),

                                SizedBox(width: sw * 0.04),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        goal['title'],
                                        style: TextStyle(
                                          fontSize: sw * 0.04,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      SizedBox(height: sh * 0.004),

                                      Text(
                                        goal['text'],
                                        style: TextStyle(
                                          fontSize: sw * 0.03,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Radio<String>(
                                  value: goal['title'],
                                  groupValue: selectedGoal,
                                  activeColor: const Color(0xFF3A6F4B),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedGoal = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: sh * 0.02),

                  SizedBox(
                    width: double.infinity,
                    height: sh * 0.06,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A6F4B),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(sw * 0.03),
                        ),
                      ),

                      onPressed: () {
                        if (selectedGoal.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Please select your activity level",
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        final data = OnboardingData.instance;
                        data.activityLevel = selectedGoal;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DietPreference(),
                          ),
                        );
                      },

                      child: Text(
                        'Next',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw * 0.04,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
