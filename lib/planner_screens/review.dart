import 'package:fitnova/models/onboarding_data.dart';
import 'package:fitnova/planner_screens/plangenerator.dart';
import 'package:fitnova/diet_display/widgets/review_card.dart';
import 'package:flutter/material.dart';

class ReviewInfo extends StatefulWidget {
  const ReviewInfo({super.key});

  @override
  State<ReviewInfo> createState() => _ReviewInfoState();
}

class _ReviewInfoState extends State<ReviewInfo> {
  bool isLoading = false;

  Widget buildRow(String title, String value, double sw) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: sw * .012),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: sw * .036,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            flex: 5,
            child: Text(
              value.isEmpty ? "-" : value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: sw * .036,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = OnboardingData.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Information"),
        centerTitle: true,
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sw = constraints.maxWidth;
            final sh = constraints.maxHeight;

            return SingleChildScrollView(
              padding: EdgeInsets.all(sw * .05),

              child: Column(
                children: [
                  Text(
                    "Review Your Profile",
                    style: TextStyle(
                      fontSize: sw * .065,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: sh * .01),

                  Text(
                    "Please verify all your information before generating your AI meal plan.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: sw * .04,
                    ),
                  ),

                  SizedBox(height: sh * .03),

                  /// BASIC INFO
                  ReviewCard(
                    title: "Basic Information",

                    icon: Icons.person,

                    child: Column(
                      children: [
                        buildRow("Name", data.fullName, sw),

                        buildRow("Age", "${data.age} Years", sw),

                        buildRow("Gender", data.gender, sw),

                        buildRow("Phone", data.phone.toString(), sw),

                        buildRow("Height", "${data.height} cm", sw),

                        buildRow("Weight", "${data.weight} kg", sw),
                      ],
                    ),
                  ),

                  SizedBox(height: sh * .02),

                  /// GOAL
                  ReviewCard(
                    title: "Goal",

                    icon: Icons.flag,

                    child: Column(
                      children: [
                        buildRow("Goal", data.goal, sw),
                        if (data.goal == "Build Muscle") ...[
                          buildRow(
                            "Muscle Gain Target",
                            "${data.muscleGainTarget} kg",
                            sw,
                          ),
                          buildRow(
                            "Duration",
                            "${data.durationMonths} Months",
                            sw,
                          ),
                        ],
                        if (data.goal == "Lose Weight") ...[
                          buildRow(
                            "Target Weight",
                            "${data.targetWeight} kg",
                            sw,
                          ),
                          buildRow(
                            "Duration",
                            "${data.durationMonths} Months",
                            sw,
                          ),
                        ],
                        if (data.goal == "Strength & Power") ...[
                          buildRow("Strength Goal", data.strengthGoal, sw),
                          buildRow("Primary Lift", data.primaryLift, sw),
                          buildRow("Rep Range", data.repRange, sw),
                          buildRow(
                            "Workout Days",
                            "${data.workoutDays} Days",
                            sw,
                          ),
                        ],
                        if (data.goal == "Improve Endurance") ...[
                          buildRow("Endurance Goal", data.enduranceGoal, sw),
                          buildRow(
                            "Cardio Preference",
                            data.cardioPreference,
                            sw,
                          ),
                          buildRow("Workout Days", "${data.workoutDays}", sw),
                        ],

                        if (data.goal == "General Fitness") ...[
                          buildRow(
                            "Fitness Goals",
                            data.fitnessGoals.join(", "),
                            sw,
                          ),
                          buildRow("Workout Place", data.workoutPlace, sw),
                          buildRow("Workout Days", "${data.workoutDays}", sw),
                        ],

                        if (data.goal == "Athletic Performance") ...[
                          buildRow("Sport", data.sportName, sw),
                          buildRow(
                            "Performance Goals",
                            data.performanceGoals.join(", "),
                            sw,
                          ),
                          buildRow(
                            "Competition Level",
                            data.competitionLevel,
                            sw,
                          ),
                          buildRow("Workout Days", "${data.workoutDays}", sw),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: sh * .02),

                  /// LIFESTYLE
                  ReviewCard(
                    title: "Lifestyle",

                    icon: Icons.self_improvement,

                    child: Column(
                      children: [
                        buildRow("Activity", data.activityLevel, sw),
                        buildRow("Meals", data.mealsPerDay, sw),
                        buildRow("Sleep", data.sleepHours, sw),
                        buildRow("Water", data.waterIntake, sw),
                        buildRow("Workout", data.exercise, sw),
                        buildRow("Workout Location", data.workoutPrefer, sw),
                        buildRow("Budget", data.budget, sw),
                        buildRow("Job", data.job, sw),
                        buildRow("Job Time", data.officeTime, sw),
                        buildRow("Break Time", data.breakTime, sw),
                        buildRow("Workout Time", data.workoutTime, sw),
                        buildRow("Wake Up", data.wakeUp, sw),
                      ],
                    ),
                  ),

                  SizedBox(height: sh * .02),

                  /// DIET
                  ReviewCard(
                    title: "Diet",
                    icon: Icons.restaurant_menu,
                    child: Column(
                      children: [
                        buildRow(
                          "Preference",
                          data.dietaryPreferences.join(", "),
                          sw,
                        ),

                        buildRow(
                          "Allergies",
                          data.allergies.isEmpty ? "None" : data.allergies,
                          sw,
                        ),

                        buildRow(
                          "Comments",
                          data.comments.isEmpty ? "None" : data.comments,
                          sw,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: sh * .02),

                  /// SKIN
                  ReviewCard(
                    title: "Skin Profile",
                    icon: Icons.face_retouching_natural,
                    child: Column(
                      children: [
                        buildRow("Skin Tone", data.skinTone, sw),

                        buildRow(
                          "Concerns",
                          data.skinConcerns.isEmpty
                              ? "None"
                              : data.skinConcerns.join(", "),
                          sw,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: sh * .02),

                  /// HAIR
                  ReviewCard(
                    title: "Hair & Scalp",
                    icon: Icons.content_cut,
                    child: Column(
                      children: [
                        buildRow("Hair Type", data.hairType, sw),

                        buildRow("Scalp Type", data.scalpType, sw),

                        buildRow(
                          "Concerns",
                          data.hairConcerns.isEmpty
                              ? "None"
                              : data.hairConcerns.join(", "),
                          sw,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: sh * .02),

                  /// BODY
                  ReviewCard(
                    title: "Body Profile",
                    icon: Icons.fitness_center,
                    child: Column(
                      children: [
                        buildRow("Body Type", data.bodyType, sw),

                        buildRow("Body Goal", data.bodyGoal, sw),

                        buildRow("Fitness Level", data.fitnessLevel, sw),
                      ],
                    ),
                  ),

                  SizedBox(height: sh * .04),

                  SizedBox(
                    width: double.infinity,
                    height: sh * .065,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff3A6F4B),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),

                      onPressed: isLoading
                          ? null
                          : () async {
                              setState(() {
                                isLoading = true;
                              });

                              await Future.delayed(
                                const Duration(milliseconds: 300),
                              );

                              if (!mounted) return;

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PlanGenerator(),
                                ),
                              );
                            },

                      child: isLoading
                          ? SizedBox(
                              width: sw * .06,
                              height: sw * .06,
                              child: const CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "Generate My AI Diet Plan",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: sw * .043,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: sh * .02),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
