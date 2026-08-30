import 'package:fitnova/models/onboarding_data.dart';
import 'package:fitnova/planner_screens/goaldetail.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class Goalscreen extends StatefulWidget {
  const Goalscreen({super.key});

  @override
  State<Goalscreen> createState() => _GoalscreenState();
}

class _GoalscreenState extends State<Goalscreen> {
  String selectedGoal = '';

  final List<Map<String, dynamic>> goals = [
    {
      'title': 'Build Muscle',
      'text': 'Increase Lean Muscle',
      'icon': HugeIcons.strokeRoundedDumbbell01,
    },
    {
      'title': 'Lose Weight',
      'text': 'Increase Lean Muscle',
      'icon': HugeIcons.strokeRoundedFire02,
    },
    {
      'title': 'Weight Gain',
      'text': 'Increase Lean Muscle',
      'icon': HugeIcons.strokeRoundedFire02,
    },
    {
      'title': 'Strength & Power',
      'text': 'Increase Lean Muscle',
      'icon': HugeIcons.strokeRoundedGymnasticRings,
    },
    {
      'title': 'Improve Endurance',
      'text': 'Increase Lean Muscle',
      'icon': HugeIcons.strokeRoundedHeartCheck,
    },
    {
      'title': 'General Fitness',
      'text': 'Increase Lean Muscle',
      'icon': HugeIcons.strokeRoundedYogaMat,
    },
    {
      'title': 'Athletic Performance',
      'text': 'Increase Lean Muscle',
      'icon': HugeIcons.strokeRoundedRunningShoes,
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
                    'What is your goal?',
                    style: TextStyle(
                      fontSize: sw * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: sh * 0.01),

                  Text(
                    'Select your primary goal',
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
                              selectedGoal = goal['title'];
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
                                width: 1.4,
                              ),
                            ),
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: goal['icon'],
                                  size: sw * 0.07,
                                  color: Colors.green.shade600,
                                ),

                                SizedBox(width: sw * 0.04),

                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        goal['title'],
                                        style: TextStyle(
                                          fontSize: sw * 0.04,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        goal['text'],
                                        style: TextStyle(
                                          fontSize: sw * 0.03,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey,
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
                            const SnackBar(
                              content: Text('Pleae select your goal'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        final data = OnboardingData.instance;
                        data.goal = selectedGoal.trim();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GoalDetails(),
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
