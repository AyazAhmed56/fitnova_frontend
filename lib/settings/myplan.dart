import 'package:fitnova/diet_display/display_screen/dailymeal.dart';
import 'package:fitnova/workout_display/display_screen/weekly_workout_plan.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fitnova/services/supabase_service.dart';

class MyPlanScreen extends StatefulWidget {
  const MyPlanScreen({super.key});

  @override
  State<MyPlanScreen> createState() => _MyPlanScreenState();
}

class _MyPlanScreenState extends State<MyPlanScreen> {
  final SupabaseService _service = SupabaseService();

  bool isLoading = true;

  Map<String, dynamic>? dietPlan;
  Map<String, dynamic>? workoutPlan;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    // try {
    //   // Use your existing plan fetching methods here.
    //   //
    //   // If your SupabaseService already exposes dedicated
    //   // methods for meal/workout plans, call them here.

    //   final result = await Supabase.instance.client
    //       .from('users')
    //       .select()
    //       .eq('id', user.id)
    //       .maybeSingle();

    //   if (result != null) {
    //     // Keep this screen available even if plan data
    //     // is stored separately.
    //   }
    // } catch (e) {
    //   _showMessage("Unable to load your plans.", Colors.red);
    // }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _openMealPlan() async {
    // Replace with your existing DailyMeal/meal plan screen.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DailyMeal()),
    );
  }

  Future<void> _openWorkoutPlan() async {
    // Replace with your existing WorkoutHome screen.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WeeklyWorkoutPlan()),
    );
  }

  // void _showMessage(String message, Color color) {
  //   if (!mounted) return;

  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  // }

  Widget _planCard({
    required IconData icon,
    required String title,
    required String subtitle,
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
        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Row(
            children: [
              Container(
                height: 55,
                width: 55,

                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4ED),
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Icon(icon, color: const Color(0xFF3A6F4B), size: 28),
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
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF3A6F4B)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F5),

      appBar: AppBar(
        title: const Text(
          "My Plan",
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
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEAF4ED), Color(0xFFDCEDE1)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: const Color(0xFF3A6F4B),
                      size: 30,
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Your Personalized Plans",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "View the plans created according to your FitNova profile.",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                "Diet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              _planCard(
                icon: Icons.restaurant_menu,
                title: "Meal Plan",
                subtitle: "View your personalized diet and meals",
                onTap: _openMealPlan,
              ),

              const SizedBox(height: 10),

              const Text(
                "Workout",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              _planCard(
                icon: Icons.fitness_center,
                title: "Workout Plan",
                subtitle: "View your personalized training plan",
                onTap: _openWorkoutPlan,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
