import 'package:fitnova/diet_display/widgets/selectable_card.dart';
import 'package:flutter/material.dart';
import 'package:fitnova/models/onboarding_data.dart';
import 'package:fitnova/planner_screens/diet/activity.dart';

class BuildMuscleDetails extends StatefulWidget {
  const BuildMuscleDetails({super.key});

  @override
  State<BuildMuscleDetails> createState() => _BuildMuscleDetailsState();
}

class _BuildMuscleDetailsState extends State<BuildMuscleDetails> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController targetWeightController = TextEditingController();

  String selectedGain = "";
  int selectedWorkoutDays = 0;
  int selectedMonth = 3;

  final gainOptions = [
    {
      "title": "Gain 2 kg",
      "subtitle": "Small Lean Gain",
      "icon": Icons.trending_up,
    },
    {
      "title": "Gain 5 kg",
      "subtitle": "Moderate Muscle Growth",
      "icon": Icons.fitness_center,
    },
    {
      "title": "Gain 8 kg",
      "subtitle": "Advanced Muscle Gain",
      "icon": Icons.sports_gymnastics,
    },
    {
      "title": "Gain 10+ kg",
      "subtitle": "Maximum Bulk",
      "icon": Icons.emoji_events,
    },
  ];

  final workoutOptions = [
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
  void dispose() {
    targetWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = OnboardingData.instance;

    return Scaffold(
      appBar: AppBar(title: const Text("Build Muscle"), centerTitle: true),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sw = constraints.maxWidth;
            final sh = constraints.maxHeight;

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(sw * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Icon(
                        Icons.fitness_center,
                        size: sw * 0.16,
                        color: const Color(0xFF3A6F4B),
                      ),
                    ),

                    SizedBox(height: sh * 0.02),

                    Center(
                      child: Text(
                        "Build Muscle",
                        style: TextStyle(
                          fontSize: sw * 0.075,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: sh * 0.01),

                    Center(
                      child: Text(
                        "Let's create your personalized muscle-building plan.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: sw * 0.038,
                        ),
                      ),
                    ),

                    SizedBox(height: sh * 0.04),

                    Text(
                      "Current Weight",
                      style: TextStyle(
                        fontSize: sw * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: sh * 0.012),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.04,
                        vertical: sh * 0.018,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(sw * 0.03),
                      ),
                      child: Text(
                        "${data.weight} kg",
                        style: TextStyle(
                          fontSize: sw * 0.045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    SizedBox(height: sh * 0.03),

                    // Text(
                    //   "Target Weight",
                    //   style: TextStyle(
                    //     fontSize: sw * 0.045,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),

                    // SizedBox(height: sh * 0.012),

                    // TextFormField(
                    //   controller: targetWeightController,
                    //   keyboardType: TextInputType.number,
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return "Please enter target weight";
                    //     }

                    //     final weight = double.tryParse(value);

                    //     if (weight == null || weight <= data.weight) {
                    //       return "Target weight must be greater than current weight";
                    //     }

                    //     return null;
                    //   },
                    //   decoration: InputDecoration(
                    //     hintText: "Enter Target Weight",
                    //     suffixText: "kg",
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(sw * 0.03),
                    //     ),
                    //   ),
                    // ),

                    // SizedBox(height: sh * 0.035),
                    Text(
                      "Target Muscle Gain",
                      style: TextStyle(
                        fontSize: sw * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: sh * 0.015),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: gainOptions.map((gain) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SelectableCard(
                            title: gain['title'] as String,
                            subtitle: gain['subtitle'] as String,
                            icon: gain['icon'] as IconData,
                            selected: selectedGain == gain['title'],
                            onTap: () {
                              setState(() {
                                selectedGain = gain['title'] as String;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: sh * 0.035),

                    Text(
                      "Workout Days per Week",
                      style: TextStyle(
                        fontSize: sw * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: sh * 0.015),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: workoutOptions.map((option) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SelectableCard(
                            title: option["title"] as String,
                            subtitle: option["subtitle"] as String,
                            icon: option["icon"] as IconData,
                            selected: selectedWorkoutDays == option["days"],
                            onTap: () {
                              setState(() {
                                selectedWorkoutDays = option["days"] as int;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: sh * 0.035),
                    Text(
                      "Target Duration",
                      style: TextStyle(
                        fontSize: sw * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: sh * 0.015),

                    DropdownButtonFormField<int>(
                      value: selectedMonth,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(sw * 0.03),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: sw * 0.04,
                          vertical: sh * 0.018,
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

                    SizedBox(height: sh * 0.06),

                    SizedBox(
                      width: double.infinity,
                      height: sh * 0.065,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A6F4B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw * 0.03),
                          ),
                        ),
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          if (selectedGain.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please select your muscle gain target.",
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

                          data.targetWeight = double.parse(
                            targetWeightController.text,
                          );

                          data.muscleGainTarget = selectedGain;

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
                            fontSize: sw * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
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
