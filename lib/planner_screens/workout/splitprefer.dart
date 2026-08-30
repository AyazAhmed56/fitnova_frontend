import 'package:fitnova/models/onboarding_data.dart';
import 'package:fitnova/planner_screens/diet/skin.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class SplitPreference extends StatefulWidget {
  const SplitPreference({super.key});

  @override
  State<SplitPreference> createState() => _SplitPreferenceState();
}

class _SplitPreferenceState extends State<SplitPreference> {
  String selectedSplit = '';

  final List<Map<String, dynamic>> splits = [
    {
      'title': 'Full Body',
      'text': 'Train all muscle groups',
      'icon': HugeIcons.strokeRoundedDumbbell01,
    },
    {
      'title': 'Upper / Lower',
      'text': 'Split upper & lower body',
      'icon': HugeIcons.strokeRoundedBodyArmor,
    },
    {
      'title': 'Push / Pull / Legs',
      'text': 'Advanced split',
      'icon': HugeIcons.strokeRoundedGymnasticRings,
    },
    {
      'title': 'Single Muscle Split',
      'text': 'Focus on one body part',
      'icon': HugeIcons.strokeRoundedBodyPartMuscle,
    },
    {
      'title': 'Double Muscle Split',
      'text': 'Focus on two body part',
      'icon': HugeIcons.strokeRoundedWorkoutRun,
    },
    {
      'title': 'Custom Split',
      'text': 'I want a custom plans',
      'icon': HugeIcons.strokeRoundedSettings02,
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
                    'How do you prefer to train?',
                    style: TextStyle(
                      fontSize: sw * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: sh * 0.01),

                  Text(
                    'Choose your workout split',
                    style: TextStyle(
                      fontSize: sw * 0.04,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  SizedBox(height: sh * 0.03),

                  Expanded(
                    child: ListView.builder(
                      itemCount: splits.length,
                      itemBuilder: (context, index) {
                        final split = splits[index];

                        return InkWell(
                          borderRadius: BorderRadius.circular(sw * 0.035),
                          onTap: () {
                            setState(() {
                              selectedSplit = split['title'];
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
                                color: selectedSplit == split['title']
                                    ? const Color(0xFF3A6F4B)
                                    : Colors.grey.shade300,
                                width: 1.4,
                              ),
                            ),
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: split['icon'],
                                  size: sw * 0.07,
                                  color: Colors.green.shade600,
                                ),

                                SizedBox(width: sw * 0.04),

                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        split['title'],
                                        style: TextStyle(
                                          fontSize: sw * 0.04,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        split['text'],
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
                                  value: split['title'],
                                  groupValue: selectedSplit,
                                  activeColor: const Color(0xFF3A6F4B),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedSplit = value!;
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
                        if (selectedSplit.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pleae select your goal'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        final data = OnboardingData.instance;
                        data.split = selectedSplit.trim();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SkinScreen()),
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
