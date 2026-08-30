import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fitnova/services/supabase_service.dart';

class GeneratePlanScreen extends StatefulWidget {
  const GeneratePlanScreen({super.key});

  @override
  State<GeneratePlanScreen> createState() => _GeneratePlanScreenState();
}

class _GeneratePlanScreenState extends State<GeneratePlanScreen> {
  final SupabaseService _service = SupabaseService();

  bool generatingMeal = false;
  bool generatingWorkout = false;
  bool generatingBoth = false;

  Color primary = const Color(0xFF3A6F4B);

  Future<void> _generateMealPlan(String userId) async {
    final confirm = await _confirm(
      "Generate Meal Plan",
      "Your current meal plan may be replaced with a new personalized meal plan. Continue?",
    );

    if (!confirm) return;

    setState(() {
      generatingMeal = true;
    });

    try {
      // Use your existing meal-plan generation method here.
      //
      // If your SupabaseService currently has a dedicated
      // generateMealPlan() method, call it here.

      await _service.generateAndSavePlans(userId);

      if (!mounted) return;

      _message("Meal plan generated successfully.", Colors.green);
    } catch (e) {
      if (!mounted) return;

      _message("Failed to generate meal plan.", Colors.red);
    }

    if (mounted) {
      setState(() {
        generatingMeal = false;
      });
    }
  }

  Future<void> _generateWorkoutPlan(String userId) async {
    final confirm = await _confirm(
      "Generate Workout Plan",
      "Your current workout plan may be replaced with a new personalized workout plan. Continue?",
    );

    if (!confirm) return;

    setState(() {
      generatingWorkout = true;
    });

    try {
      // Use your existing workout-only generation method here.
      //
      // If your SupabaseService currently has a dedicated
      // generateWorkoutPlan() method, call it here.

      await _service.generateAndSavePlans(userId);

      if (!mounted) return;

      _message("Workout plan generated successfully.", Colors.green);
    } catch (e) {
      if (!mounted) return;

      _message("Failed to generate workout plan.", Colors.red);
    }

    if (mounted) {
      setState(() {
        generatingWorkout = false;
      });
    }
  }

  Future<void> _generateBoth(String userId) async {
    final confirm = await _confirm(
      "Generate New Plan",
      "This will generate a new meal plan and workout plan. Continue?",
    );

    if (!confirm) return;

    setState(() {
      generatingBoth = true;
    });

    try {
      await _service.generateAndSavePlans(userId);

      if (!mounted) return;

      _message(
        "New meal and workout plans generated successfully.",
        Colors.green,
      );
    } catch (e) {
      if (!mounted) return;

      _message("Failed to generate plans.", Colors.red);
    }

    if (mounted) {
      setState(() {
        generatingBoth = false;
      });
    }
  }

  Future<bool> _confirm(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: Text(title),

          content: Text(message),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Generate"),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _message(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Widget _generateCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool loading,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: loading ? null : onTap,

        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,

                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4ED),
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Icon(icon, color: primary, size: 28),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              if (loading)
                SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: primary,
                    strokeWidth: 2,
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please login first.")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F5),

      appBar: AppBar(
        title: const Text(
          "Generate Plans",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F8F5),
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEAF4ED), Color(0xFFDCEDE1)],
                  ),

                  borderRadius: BorderRadius.circular(22),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Icon(Icons.auto_awesome, color: primary, size: 32),

                    const SizedBox(height: 12),

                    const Text(
                      "Create Your Plan",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      "FitNova will use your current profile information to create a personalized plan.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                "Choose what you want to generate",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              _generateCard(
                icon: Icons.restaurant_menu,
                title: "Generate Meal Plan",
                subtitle: "Create a personalized diet and meal plan.",
                loading: generatingMeal,
                onTap: () => _generateMealPlan(user.id),
              ),

              _generateCard(
                icon: Icons.fitness_center,
                title: "Generate Workout Plan",
                subtitle: "Create a personalized training plan.",
                loading: generatingWorkout,
                onTap: () => _generateWorkoutPlan(user.id),
              ),

              _generateCard(
                icon: Icons.auto_awesome,
                title: "Generate New Plan",
                subtitle: "Generate both meal and workout plans.",
                loading: generatingBoth,
                onTap: () => _generateBoth(user.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
