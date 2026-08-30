import 'package:fitnova/models/onboarding_data.dart';
import 'package:fitnova/planner_screens/workout/bodytype.dart';
// import 'package:dietplan/planner_screens/review.dart';
// import 'package:dietplan/planner_screens/diet/skin.dart';
// import 'package:dietplan/planner_screens/workout/workoutpreferences.dart';
import 'package:flutter/material.dart';

class LifeStyleAndHabits extends StatefulWidget {
  const LifeStyleAndHabits({super.key});

  @override
  State<LifeStyleAndHabits> createState() => _LifeStyleAndHabitsState();
}

class _LifeStyleAndHabitsState extends State<LifeStyleAndHabits> {
  String? selectMeals;
  String? selectSleep;
  String? selectWater;
  final TextEditingController workoutTimeController = TextEditingController();
  final TextEditingController wakeUpController = TextEditingController();
  final TextEditingController officeTimeController = TextEditingController();
  final TextEditingController breakTimeController = TextEditingController();
  String? job;
  String? workoutType;
  String? workoutPrefer;
  String? budgetRange;

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

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(sw * 0.05),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Lifestyle & Habits',
                        style: TextStyle(
                          fontSize: sw * 0.06,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: sh * 0.01),

                    Center(
                      child: Text(
                        'Help us personalize your plan',
                        style: TextStyle(
                          fontSize: sw * 0.04,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),

                    SizedBox(height: sh * 0.03),

                    _buildQuestion(
                      title: 'How many meals do you prefer?',
                      value: selectMeals,
                      label: 'Meals',
                      items: const ['2 Meals', '3 Meals', '4 Meals', '5 Meals'],
                      onChanged: (value) {
                        setState(() {
                          selectMeals = value;
                        });
                      },
                      sw: sw,
                    ),

                    SizedBox(height: sh * 0.025),

                    _buildQuestion(
                      title: 'Sleep (hours per night)',
                      value: selectSleep,
                      label: 'Hours',
                      items: const [
                        '< 5 hours',
                        '5-6 hours',
                        '6-7 hours',
                        '7-8 hours',
                        '8-9 hours',
                        '9+ hours',
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectSleep = value;
                        });
                      },
                      sw: sw,
                    ),

                    SizedBox(height: sh * 0.025),

                    _buildQuestion(
                      title: 'Water Intake (glasses per day)',
                      value: selectWater,
                      label: 'Glasses',
                      items: const [
                        '1 lt',
                        '2 lt',
                        '3 lt',
                        '4 lt',
                        '5 lt',
                        '6 lt',
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectWater = value;
                        });
                      },
                      sw: sw,
                    ),

                    SizedBox(height: sh * 0.025),

                    _buildQuestion(
                      title: 'Workout Type',
                      value: workoutType,
                      label: 'Workout Type',
                      items: const [
                        'No Workout',
                        'Walking',
                        'Home Workout',
                        'Gym Training',
                        'Gym + Cardio',
                        'Strength Training',
                        'Cardio',
                        'Sports',
                      ],
                      onChanged: (value) {
                        setState(() {
                          workoutType = value;
                        });
                      },
                      sw: sw,
                    ),

                    SizedBox(height: sh * 0.025),

                    _buildQuestion(
                      title: 'Workout Location',
                      value: workoutPrefer,
                      label: 'Workout Location',
                      items: const ['At Home', 'At Gym', 'Both'],
                      onChanged: (value) {
                        setState(() {
                          workoutPrefer = value;
                        });
                      },
                      sw: sw,
                    ),

                    SizedBox(height: sh * 0.025),

                    _buildQuestion(
                      title: 'Budget Range (for 2 days)',
                      value: budgetRange,
                      label: 'Budget Range',
                      items: const [
                        'upto 1000',
                        'upto 2000',
                        'upto 3000',
                        'between 3000-5000',
                        'above 5000',
                        'budget free',
                      ],
                      onChanged: (value) {
                        setState(() {
                          budgetRange = value;
                        });
                      },
                      sw: sw,
                    ),

                    SizedBox(height: sh * 0.025),

                    _buildQuestion(
                      title: 'Job Title',
                      value: job,
                      label: 'Job Title',
                      items: const [
                        'Corporte Employee',
                        'Student',
                        'Professor',
                        'Govt. Employee',
                        'Service',
                        'Other',
                      ],
                      onChanged: (value) {
                        setState(() {
                          job = value;
                        });
                      },
                      sw: sw,
                    ),

                    SizedBox(height: sh * 0.025),

                    Text(
                      'Job / Office Time',
                      style: TextStyle(
                        fontSize: sw * 0.04,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: sh * 0.01),

                    TextFormField(
                      controller: officeTimeController,
                      decoration: InputDecoration(
                        hintText: "Eg: 10:00 AM or 06:00 PM",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(sw * 0.03),
                        ),
                      ),
                    ),

                    SizedBox(height: sh * 0.025),

                    Text(
                      'Break / Lunch Time',
                      style: TextStyle(
                        fontSize: sw * 0.04,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: sh * 0.01),

                    TextFormField(
                      controller: breakTimeController,
                      decoration: InputDecoration(
                        hintText: "Eg: 01:00 PM or 02:00 PM",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(sw * 0.03),
                        ),
                      ),
                    ),

                    SizedBox(height: sh * 0.025),

                    Text(
                      'Gym / Workout Time',
                      style: TextStyle(
                        fontSize: sw * 0.04,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: sh * 0.01),

                    TextFormField(
                      controller: workoutTimeController,
                      decoration: InputDecoration(
                        hintText: "Example: 6:00 AM or 7:30 PM",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(sw * 0.03),
                        ),
                      ),
                    ),

                    SizedBox(height: sh * 0.025),

                    Text(
                      'Wake Up Time',
                      style: TextStyle(
                        fontSize: sw * 0.04,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: sh * 0.01),

                    TextFormField(
                      controller: wakeUpController,
                      decoration: InputDecoration(
                        hintText: "Example: 5:45 AM",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(sw * 0.03),
                        ),
                      ),
                    ),

                    SizedBox(height: sh * 0.05),

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
                          final data = OnboardingData.instance;
                          data.mealsPerDay = selectMeals ?? '';
                          data.sleepHours = selectSleep ?? '';
                          data.exercise = workoutType ?? '';
                          data.workoutPrefer = workoutPrefer ?? '';
                          data.wakeUp = wakeUpController.text;
                          data.workoutTime = workoutTimeController.text;
                          data.officeTime = officeTimeController.text;
                          data.job = job ?? '';
                          data.breakTime = breakTimeController.text;
                          data.waterIntake = selectWater ?? '';
                          data.job = job ?? '';
                          data.budget = budgetRange ?? '';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BodyTypeScreen(),
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
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuestion({
    required String title,
    required String? value,
    required String label,
    required List<String> items,
    required Function(String?) onChanged,
    required double sw,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: sw * 0.04, fontWeight: FontWeight.w600),
        ),

        SizedBox(height: sw * 0.02),

        DropdownButtonFormField<String>(
          value: value,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please select one option";
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(sw * 0.03),
            ),
          ),

          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),

          onChanged: onChanged,
        ),
      ],
    );
  }
}
