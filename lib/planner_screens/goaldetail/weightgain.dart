import 'package:fitnova/diet_display/widgets/selectable_card.dart';
import 'package:flutter/material.dart';
import 'package:fitnova/models/onboarding_data.dart';
import 'package:fitnova/planner_screens/diet/activity.dart';

class WeightGainDetails extends StatefulWidget {
  const WeightGainDetails({super.key});

  @override
  State<WeightGainDetails> createState() => _WeightGainDetailsState();
}

class _WeightGainDetailsState extends State<WeightGainDetails> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController targetWeightController = TextEditingController();

  int selectedWorkoutDays = 0;

  int selectedMonth = 3;

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
      "subtitle": "Fat Burning",
      "icon": Icons.looks_5,
    },
    {
      "days": 6,
      "title": "6 Days",
      "subtitle": "Intensive",
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
      appBar: AppBar(title: const Text("Weight Gain"), centerTitle: true),

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
                        Icons.local_fire_department,
                        size: sw * .16,
                        color: Colors.orange,
                      ),
                    ),

                    SizedBox(height: sh * .02),

                    Center(
                      child: Text(
                        "Weight Gain",
                        style: TextStyle(
                          fontSize: sw * .075,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: sh * .01),

                    Center(
                      child: Text(
                        "Let's build your personalized weight-gain journey.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: sw * .038,
                        ),
                      ),
                    ),

                    SizedBox(height: sh * .04),

                    Text(
                      "Current Weight",
                      style: TextStyle(
                        fontSize: sw * .045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: sh * .012),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * .04,
                        vertical: sh * .018,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(sw * .03),
                      ),
                      child: Text(
                        "${data.weight} kg",
                        style: TextStyle(
                          fontSize: sw * .045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    SizedBox(height: sh * .03),

                    Text(
                      "Target Weight",
                      style: TextStyle(
                        fontSize: sw * .045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: sh * .012),

                    TextFormField(
                      controller: targetWeightController,
                      keyboardType: TextInputType.number,

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter target weight";
                        }

                        final weight = double.tryParse(value);

                        if (weight == null) {
                          return "Invalid weight";
                        }

                        if (weight <= data.weight) {
                          return "Target weight must be greater than current weight";
                        }

                        return null;
                      },

                      decoration: InputDecoration(
                        hintText: "Enter Target Weight",
                        suffixText: "kg",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(sw * .03),
                        ),
                      ),
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
                      "Target Duration",
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
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw * .03),
                          ),
                        ),
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
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
