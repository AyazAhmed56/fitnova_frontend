
import 'package:fitnova/models/onboarding_data.dart';
import 'package:fitnova/planner_screens/diet/lifestyle.dart';
import 'package:fitnova/planner_screens/workout/custom_split.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class SplitPreference extends StatefulWidget {
  const SplitPreference({super.key});

  @override
  State<SplitPreference> createState() => _SplitPreferenceState();
}

class _SplitPreferenceState extends State<SplitPreference> {
  static const Color primaryColor = Color(0xFF3A6F4B);

  String selectedSplit = '';

  final List<Map<String, dynamic>> splits = [
    {
      'title': 'Full Body',
      'text': 'Train all major muscle groups',
      'icon': HugeIcons.strokeRoundedDumbbell01,
    },
    {
      'title': 'Upper / Lower / Rest(or Cardio)',
      'text': 'Alternate upper and lower body',
      'icon': HugeIcons.strokeRoundedBodyArmor,
    },
    {
      'title': 'Push / Pull / Legs',
      'text': 'A structured three-part split',
      'icon': HugeIcons.strokeRoundedGymnasticRings,
    },
    {
      'title': 'Single Muscle Split',
      'text': 'Focus on one muscle group',
      'icon': HugeIcons.strokeRoundedBodyPartMuscle,
    },
    {
      'title': 'Double Muscle Split',
      'text': 'Train two muscle groups together',
      'icon': HugeIcons.strokeRoundedWorkoutRun,
    },
    {
      'title': 'Custom Split',
      'text': 'Choose a workout for each day',
      'icon': HugeIcons.strokeRoundedSettings02,
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedSplit = OnboardingData.instance.split;
  }

  void continueToNext() {
    if (selectedSplit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a workout split.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final data = OnboardingData.instance;
    data.split = selectedSplit;

    if (selectedSplit != 'Custom Split') {
      data.customSplit = {};
    }

    if (selectedSplit == 'Custom Split') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CustomSplitScreen(),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LifeStyleAndHabits(
          flow: 'workout',
        ),
      ),
    );
  }

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
                    textAlign: TextAlign.center,
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
                        final title = split['title'] as String;
                        final isSelected = selectedSplit == title;

                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            setState(() {
                              selectedSplit = title;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                              bottom: sh * 0.015,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.04,
                              vertical: sh * 0.018,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE8F3E9)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : Colors.grey.shade300,
                                width: 1.4,
                              ),
                            ),
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: split['icon'],
                                  size: sw * 0.07,
                                  color: primaryColor,
                                ),
                                SizedBox(width: sw * 0.04),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: TextStyle(
                                          fontSize: sw * 0.04,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        split['text'] as String,
                                        style: TextStyle(
                                          fontSize: sw * 0.03,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Radio<String>(
                                  value: title,
                                  groupValue: selectedSplit,
                                  activeColor: primaryColor,
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() {
                                      selectedSplit = value;
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
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: continueToNext,
                      child: Text(
                        'Next',
                        style: TextStyle(
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
