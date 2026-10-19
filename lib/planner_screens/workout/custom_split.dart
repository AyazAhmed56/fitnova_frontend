import 'package:fitnova/models/onboarding_data.dart';
import 'package:fitnova/planner_screens/diet/lifestyle.dart';
import 'package:flutter/material.dart';

class CustomSplitScreen extends StatefulWidget {
  const CustomSplitScreen({super.key});

  @override
  State<CustomSplitScreen> createState() => _CustomSplitScreenState();
}

class _CustomSplitScreenState extends State<CustomSplitScreen> {
  static const Color primaryColor = Color(0xFF3A6F4B);

  final List<String> days = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<String> activities = const [
    'Rest',
    'Full Body',
    'Upper Body',
    'Lower Body',
    'Push',
    'Pull',
    'Legs',
    'Chest',
    'Back',
    'Shoulders',
    'Arms',
    'Core',
    'Cardio',
    'Mobility',
  ];

  late Map<String, String> dailySplit;

  @override
  void initState() {
    super.initState();

    final saved = OnboardingData.instance.customSplit;

    dailySplit = {
      for (final day in days) day: saved[day]?.toString() ?? 'Rest',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Workout Split'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                children: [
                  Text(
                    'Plan Your Week',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Choose a workout or rest day for each day '
                    'of the week.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            day,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: dailySplit[day],
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Workout',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            items: activities.map((activity) {
                              return DropdownMenuItem<String>(
                                value: activity,
                                child: Text(activity),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value == null) return;

                              setState(() {
                                dailySplit[day] = value;
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final data = OnboardingData.instance;

                    data.split = 'Custom Split';
                    data.customSplit = Map<String, dynamic>.from(dailySplit);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const LifeStyleAndHabits(flow: 'workout'),
                      ),
                    );
                  },
                  child: const Text(
                    'Save Split & Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
