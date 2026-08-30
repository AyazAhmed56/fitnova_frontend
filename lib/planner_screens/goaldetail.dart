import 'package:fitnova/planner_screens/goaldetail/athleticperformance.dart';
import 'package:fitnova/planner_screens/goaldetail/buildmuscle.dart';
import 'package:fitnova/planner_screens/goaldetail/generalfitness.dart';
import 'package:fitnova/planner_screens/goaldetail/improve_endurance.dart';
import 'package:fitnova/planner_screens/goaldetail/loseweight.dart';
import 'package:fitnova/planner_screens/goaldetail/weightgain.dart';
import 'package:fitnova/planner_screens/goaldetail/strengthpower.dart';
import 'package:flutter/material.dart';

import 'package:fitnova/models/onboarding_data.dart';

class GoalDetails extends StatelessWidget {
  const GoalDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final goal = OnboardingData.instance.goal;

    switch (goal) {
      case 'Build Muscle':
        return const BuildMuscleDetails();

      case 'Lose Weight':
        return const LoseWeightDetails();

      case 'Weight Gain':
        return const WeightGainDetails();

      case 'Strength & Power':
        return const StrengthPowerDetails();

      case 'Improve Endurance':
        return const ImproveEnduranceDetails();

      case 'General Fitness':
        return const GeneralFitnessDetails();

      case 'Athletic Performance':
        return const AthleticPerformanceDetails();

      default:
        return Scaffold(
          appBar: AppBar(title: const Text("Goal Details"), centerTitle: true),
          body: const Center(
            child: Text(
              "Please select a valid goal.",
              style: TextStyle(fontSize: 18),
            ),
          ),
        );
    }
  }
}
